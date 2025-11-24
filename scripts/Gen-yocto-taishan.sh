#!/bin/bash
set -e

# ==================== 配置 ====================
KAS_FILE="${KAS_FILE:-kas/kas-poky-taishan.yml}"
KAS_SWU_FILE="${KAS_SWU_FILE:-kas/kas-poky-swupdate.yml}"
MACHINE="${MACHINE:-raspberrypi4-64}"
BUILD_DIR="build"

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

echo "=== Step 2: 开始构建 ==="
kas build "${KAS_FILE}"

echo "=== Step 3: 构建完成SWU ==="
kas build "${KAS_SWU_FILE}"

echo "=== Step 4: 验证输出 ==="
IMAGE_DIR="${BUILD_DIR}/tmp/deploy/images/${MACHINE}"

# 检查 WIC 镜像
ls -lh "${IMAGE_DIR}"/*.wic.bz2 2>/dev/null || echo "❌ WIC镜像未找到"

# 检查 .swu（需配置 swupdate-image）
ls -lh "${IMAGE_DIR}"/*.swu 2>/dev/null || echo "⚠️  .swu未生成（需在kas.yml配置）"

echo "✅ 完成！ls -lh ${IMAGE_DIR}"