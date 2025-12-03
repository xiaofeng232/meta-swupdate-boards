#!/bin/bash
set -e

# ==================== 配置 ====================
KAS_FILE="${KAS_FILE:-kas/kas-poky-swupdate-rpi.yml}"
KAS_SWU_FILE="${KAS_SWU_FILE:-kas/kas-poky-swupdate.yml}"
MACHINE="${MACHINE:-raspberrypi4-64}"
BUILD_DIR="build"

# SDK 配置
SDKMACHINE="${SDKMACHINE:-x86_64}"
SDKIMAGE="${SDKIMAGE:-core-image-minimal}"  # 用于生成 SDK 的镜像名

# ==================== 主流程 ====================
pkill -9 -f bitbake || true
sleep 2  # 等待资源释放

find "${BUILD_DIR}" -name "*.lock" -delete 2>/dev/null || true
find "${BUILD_DIR}" -name "bitbake.*" -delete 2>/dev/null || true

echo "=== Step 1: 清理构建产物 ==="
case "$1" in
    --clean)
        # 彻底清理：删除整个 tmp（包括 work/deploy）
        rm -rf "${BUILD_DIR}"/tmp
        ;;
    --cleansstate)
        # 清理 sstate（加速下次重建）
        rm -rf "${BUILD_DIR}"/sstate-cache
        ;;
    --cleanall)
        # 彻底清理：删除整个 build 目录
        rm -rf "${BUILD_DIR}"/tmp
        rm -rf "${BUILD_DIR}"/sstate-cache
        rm -rf "${BUILD_DIR}"/buildhistory
        rm -rf "${BUILD_DIR}"/cache
        ;;
    *)
        echo "增量构建（无清理）"
        ;;
esac

echo "=== Step 2: 开始主镜像构建 ==="
kas build "${KAS_FILE}"

# ==================== SDK 生成 ====================
if [[ "$1" == "--sdk" || "$2" == "--sdk" ]]; then
    echo "=== Step 2.5: 生成 SDK ==="
    
    # 进入构建环境执行 SDK 生成
    cd "${BUILD_DIR}"
    
    # 方法1：使用 kas shell 生成 SDK（推荐）
    kas shell "${KAS_FILE}" -c "bitbake -c populate_sdk ${SDKIMAGE}"
    
    # 方法2：直接调用 bitbake（如果已在环境中）
    # bitbake -c populate_sdk ${SDKIMAGE}
    
    cd ..
    
    echo "=== SDK 生成完成 ==="
    SDK_DIR="${BUILD_DIR}/tmp/deploy/sdk"
    ls -lh "${SDK_DIR}"/*.sh 2>/dev/null || echo "⚠️ SDK 未找到"
fi

echo "=== Step 3: 构建 SWU 更新包 ==="
kas build "${KAS_SWU_FILE}"

echo "=== Step 4: 验证输出 ==="
IMAGE_DIR="${BUILD_DIR}/tmp/deploy/images/${MACHINE}"

# 检查 WIC 镜像
ls -lh "${IMAGE_DIR}"/*.wic.bz2 2>/dev/null || echo "❌ WIC镜像未找到"

# 检查 .swu（需配置 swupdate-image）
ls -lh "${IMAGE_DIR}"/*.swu 2>/dev/null || echo "⚠️  .swu未生成（需在kas.yml配置）"

# 检查 SDK（如果生成了）
if [[ "$1" == "--sdk" || "$2" == "--sdk" ]]; then
    SDK_DIR="${BUILD_DIR}/tmp/deploy/sdk"
    echo "=== SDK 信息 ==="
    ls -lh "${SDK_DIR}"/*.sh 2>/dev/null || echo "⚠️ SDK 脚本未找到"
fi

echo "✅ 构建完成！"
echo "镜像位置: ${IMAGE_DIR}"
echo "SDK位置: ${BUILD_DIR}/tmp/deploy/sdk (如已生成)"