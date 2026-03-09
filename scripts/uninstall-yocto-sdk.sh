#!/bin/bash
set -e  # 遇到错误立即退出

# ===================== 配置项（根据你的实际情况修改）=====================
# 默认 SDK 安装路径（如果安装时自定义了路径，修改这里）
SDK_DEFAULT_PATH="/opt/poky/5.0.14"
# 交叉编译器前缀（根据你的 SDK 调整，比如 arm-poky-linux-gnueabi- 或 aarch64-poky-linux-）
COMPILER_PREFIX="arm-poky-linux-gnueabi-"
# =========================================================================

# 函数：打印彩色提示
print_info() {
    echo -e "\033[32m[INFO] $1\033[0m"
}

print_warn() {
    echo -e "\033[33m[WARN] $1\033[0m"
}

print_error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
}

# 第一步：确认 SDK 路径
print_info "===== 第一步：检测 SDK 路径 ====="
if [ -d "$SDK_DEFAULT_PATH" ]; then
    SDK_PATH="$SDK_DEFAULT_PATH"
    print_info "检测到默认 SDK 路径：$SDK_PATH"
else
    print_warn "默认路径 $SDK_DEFAULT_PATH 不存在，开始搜索系统中的 poky SDK..."
    # 修复：简化 grep 正则，避免语法兼容问题
    SDK_SEARCH_RESULT=$(find /opt -name "poky*" -type d | grep "poky/" | head -1)
    if [ -n "$SDK_SEARCH_RESULT" ]; then
        SDK_PATH="$SDK_SEARCH_RESULT"
        print_info "搜索到 SDK 路径：$SDK_PATH"
    else
        print_error "未找到任何 Yocto SDK 目录！"
        exit 1
    fi
fi

# 第二步：确认删除操作
confirm_delete() {
    print_info "\n===== 第二步：确认删除 ====="
    read -p "是否确认删除 SDK 目录 $SDK_PATH？(y/N) " -n 1 -r
    echo    # 换行
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "用户取消删除操作，脚本退出。"
        exit 0
    fi
}

# 第三步：删除 SDK 目录
delete_sdk() {
    print_info "\n===== 第三步：删除 SDK 目录 ====="
    if [ -w "$(dirname "$SDK_PATH")" ]; then
        # 有写入权限，直接删除
        rm -rf "$SDK_PATH"
    else
        # 无权限，使用 sudo
        print_warn "需要 sudo 权限删除系统目录，即将执行：sudo rm -rf $SDK_PATH"
        sudo rm -rf "$SDK_PATH"
    fi

    # 验证删除结果
    if [ ! -d "$SDK_PATH" ]; then
        print_info "✅ SDK 目录删除成功！"
    else
        print_error "❌ SDK 目录删除失败，请手动检查权限。"
        exit 1
    fi
}

# 第四步：清理环境变量
clean_env() {
    print_info "\n===== 第四步：清理环境变量 ====="
    # 清理交叉编译相关环境变量
    unset CC CXX LD AR AS CFLAGS LDFLAGS
    unset TARGET_PREFIX TARGET_SYS ROOTFS
    unset POKY_HOME OECORE_NATIVE_SYSROOT OECORE_TARGET_SYSROOT
    print_info "✅ 环境变量清理完成！"
}

# 第五步：验证卸载结果
verify_uninstall() {
    print_info "\n===== 第五步：验证卸载结果 ====="
    # 检查编译器是否存在
    COMPILER="${COMPILER_PREFIX}gcc"
    if which "$COMPILER" >/dev/null 2>&1; then
        print_warn "⚠️  检测到编译器 $COMPILER 仍存在，可能是其他版本 SDK 或系统自带。"
    else
        print_info "✅ 未检测到 $COMPILER，编译器已清理！"
    fi

    # 检查 SDK 目录是否存在
    if [ -d "$SDK_PATH" ]; then
        print_error "❌ SDK 目录仍存在，卸载失败！"
    else
        print_info "✅ 所有检查通过，SDK 卸载完成！"
    fi
}

# 主执行流程
main() {
    print_info "===== 开始卸载 Yocto SDK ====="
    print_info "脚本版本：1.0 | 适用场景：Yocto 生成的 Raspberry Pi 4 64位 SDK"
    
    confirm_delete
    delete_sdk
    clean_env
    verify_uninstall

    print_info "\n🎉 SDK 卸载脚本执行完毕！"
}

# 启动主流程
main