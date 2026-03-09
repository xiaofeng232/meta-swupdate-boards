#!/bin/bash
# set -e  # 遇到错误立即退出

# ===================== 配置项（根据你的实际情况修改）=====================
# SDK 安装脚本路径（替换为你的 .sh 二进制脚本路径）
SDK_SCRIPT_PATH="/home/xiaofeng/Workspace/yocto-taishan/build/tmp/deploy/sdk/poky-glibc-x86_64-rpi-test-image-cortexa72-raspberrypi4-64-toolchain-5.0.14.sh"
# SDK 默认安装路径（可在运行时修改）
DEFAULT_INSTALL_DIR="/opt/poky/5.0.14"
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

# 第一步：检查 SDK 脚本是否存在
check_sdk_file() {
    print_info "===== 第一步：检查 SDK 安装脚本 ====="
    if [ ! -f "$SDK_SCRIPT_PATH" ]; then
        print_error "SDK 脚本文件不存在：$SDK_SCRIPT_PATH"
        print_info "请检查文件路径是否正确，或修改脚本顶部的 SDK_SCRIPT_PATH 配置项"
        exit 1
    fi

    # 检查文件类型（确认是可执行二进制文件）
    FILE_TYPE=$(file "$SDK_SCRIPT_PATH" | grep -c "ELF 64-bit LSB executable")
    if [ $FILE_TYPE -eq 0 ]; then
        print_warn "⚠️  文件类型检测：该文件可能不是 Yocto SDK 二进制安装包"
        print_info "继续安装前请确认文件路径正确，按 Enter 继续（或 Ctrl+C 退出）..."
        read -r
    fi
    print_info "✅ SDK 脚本文件检测通过：$SDK_SCRIPT_PATH"
}

# 第二步：添加可执行权限
add_exec_permission() {
    print_info "\n===== 第二步：添加可执行权限 ====="
    if [ ! -x "$SDK_SCRIPT_PATH" ]; then
        print_info "为 SDK 脚本添加可执行权限：chmod +x $SDK_SCRIPT_PATH"
        chmod +x "$SDK_SCRIPT_PATH"
    else
        print_info "✅ SDK 脚本已具备可执行权限"
    fi
}

# 第三步：选择安装路径并执行安装
install_sdk() {
    print_info "\n===== 第三步：执行 SDK 安装 ====="
    read -p "请输入 SDK 安装路径（默认：$DEFAULT_INSTALL_DIR）：" CUSTOM_INSTALL_DIR
    INSTALL_DIR=${CUSTOM_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}

    # 检查安装目录是否已存在
    if [ -d "$INSTALL_DIR" ]; then
        print_warn "⚠️  安装目录 $INSTALL_DIR 已存在！"
        read -p "是否覆盖该目录？(y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "用户取消覆盖，脚本退出。"
            exit 0
        fi
        print_info "即将删除原有目录：sudo rm -rf $INSTALL_DIR"
        sudo rm -rf "$INSTALL_DIR"
    fi

    # 执行 SDK 安装（核心命令，避免用 source）
    print_info "开始安装 SDK 到 $INSTALL_DIR..."
    print_info "执行命令：$SDK_SCRIPT_PATH -d $INSTALL_DIR"
    "$SDK_SCRIPT_PATH" -d "$INSTALL_DIR"

    # 验证安装是否成功
    if [ -f "$INSTALL_DIR/environment-setup-cortexa72-poky-linux" ]; then
        print_info "✅ SDK 安装成功！"
        SDK_ENV_FILE="$INSTALL_DIR/environment-setup-cortexa72-poky-linux"
    else
        print_error "❌ SDK 安装失败！未找到环境配置文件"
        exit 1
    fi
}

# 第四步：加载 SDK 环境
load_sdk_env() {
    print_info "\n===== 第四步：加载 SDK 环境 ====="
    print_info "加载 SDK 环境变量：source $SDK_ENV_FILE"
    source "$SDK_ENV_FILE"

    # 验证环境是否加载成功
    COMPILER="aarch64-poky-linux-gcc"  # 适配 raspberrypi4-64 的编译器前缀
    if which "$COMPILER" >/dev/null 2>&1; then
        print_info "✅ SDK 环境加载成功！编译器路径：$(which $COMPILER)"
        print_info "编译器版本：$($COMPILER -v 2>&1 | grep 'gcc version' | awk '{print $3}')"
    else
        print_warn "⚠️  未检测到交叉编译器，可能是编译器前缀不匹配"
        print_info "请手动执行：source $SDK_ENV_FILE 后，用 which 命令检查编译器"
    fi
}

# 第五步：输出使用提示
print_usage_tips() {
    print_info "\n===== 安装完成 - 使用提示 ====="
    print_info "1. 每次新开终端使用 SDK，需加载环境："
    print_info "   source $SDK_ENV_FILE"
    print_info "2. 验证 SDK：$COMPILER -v"
    print_info "3. 卸载 SDK：可使用之前的 uninstall-yocto-sdk.sh 脚本（需修改路径配置）"
}

# 主执行流程
main() {
    print_info "===== 开始安装 Yocto SDK ====="
    print_info "脚本版本：1.0 | 适用场景：Raspberry Pi 4 64位 Yocto SDK"
    
    check_sdk_file
    add_exec_permission
    install_sdk
    load_sdk_env
    print_usage_tips

    print_info "\n🎉 SDK 安装脚本执行完毕！"
}

# 启动主流程
main