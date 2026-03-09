#!/bin/bash
set -e

# ===================== 配置项（仅需修改这部分）=====================
# SDK 环境配置文件路径（根据你的安装路径修改）
SDK_ENV_FILE="/opt/poky/5.0.14/environment-setup-cortexa72-poky-linux"
# 交叉编译器前缀（用于验证）
COMPILER_PREFIX="aarch64-poky-linux-"
# =========================================================================

# 彩色输出函数
print_info() { echo -e "\033[32m[INFO] $1\033[0m"; }
print_warn() { echo -e "\033[33m[WARN] $1\033[0m"; }
print_error() { echo -e "\033[31m[ERROR] $1\033[0m"; }

# 第一步：检查环境文件是否存在
check_env_file() {
    print_info "===== 第一步：检查 SDK 环境文件 ====="
    if [ ! -f "$SDK_ENV_FILE" ]; then
        print_error "SDK 环境文件不存在：$SDK_ENV_FILE"
        print_error "请检查安装路径是否正确，或修改脚本顶部的 SDK_ENV_FILE 配置项"
        exit 1
    fi
    print_info "✅ 环境文件检测通过：$SDK_ENV_FILE"
}

# 第二步：加载 SDK 环境
load_sdk_env() {
    print_info "\n===== 第二步：加载 SDK 环境 ====="
    # 关键：用 source 加载环境（仅这一步需要 source）
    print_info "执行：source $SDK_ENV_FILE"
    source "$SDK_ENV_FILE"
    print_info "✅ SDK 环境加载完成！"
}

# 第三步：验证环境是否生效
verify_env() {
    print_info "\n===== 第三步：验证 SDK 环境 ====="
    # 检查核心环境变量
    if [ -z "$OECORE_TARGET_SYSROOT" ]; then
        print_warn "⚠️  OECORE_TARGET_SYSROOT 环境变量未配置，加载可能异常！"
    else
        print_info "✅ 系统根目录：$OECORE_TARGET_SYSROOT"
    fi

    # 检查编译器
    COMPILER="${COMPILER_PREFIX}gcc"
    if which "$COMPILER" >/dev/null 2>&1; then
        print_info "✅ 编译器路径：$(which $COMPILER)"
        print_info "✅ 编译器版本：$($COMPILER -v 2>&1 | grep 'gcc version' | awk '{print $3}')"
    else
        print_error "❌ 未找到编译器 $COMPILER，环境加载失败！"
        exit 1
    fi

    # 检查 CC 变量（关键：确保包含 --sysroot）
    if echo "$CC" | grep -q "--sysroot"; then
        print_info "✅ CC 环境变量（含 sysroot）：$CC"
    else
        print_warn "⚠️  CC 变量未包含 --sysroot，编译时请手动指定或使用 \$CC 命令"
    fi
}

# 第四步：输出使用提示
print_usage() {
    print_info "\n===== 加载完成 - 使用提示 =====
1. 编译代码推荐使用：\$CC 源文件.c -o 可执行文件
   示例：\$CC test.c -o test
2. 本次环境仅在当前终端生效，新开终端需重新运行本脚本
3. 卸载 SDK 可使用之前的 uninstall-yocto-sdk.sh 脚本"
}

# 主流程
main() {
    print_info "===== 开始加载 Yocto SDK 环境 ====="
    check_env_file
    load_sdk_env
    verify_env
    print_usage
    print_info "\n🎉 SDK 环境加载脚本执行完毕！可直接开始交叉编译～"
}

# 启动
main