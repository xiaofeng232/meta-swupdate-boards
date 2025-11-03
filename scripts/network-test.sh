#!/bin/bash
set -euo pipefail

# 配置参数（需与 eth0.network 中的配置一致）
STATIC_IP="192.168.8.55"    # 静态IP
GATEWAY="192.168.8.1"       # 网关
DNS_SERVER="192.168.8.1"    # 主DNS服务器
TEST_DOMAIN="baidu.com"     # 测试DNS解析的域名
INTERFACE="eth0"            # 网络接口（有线网口）

# 颜色定义
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# 函数：打印标题
print_title() {
    echo -e "\n${BLUE}===== $1 =====${RESET}"
}

# 1. 检查静态IP配置
print_title "1. 验证静态IP配置"
if ip addr show "$INTERFACE" | grep -q "inet $STATIC_IP/24"; then
    echo -e "${GREEN}✓ 静态IP配置正确：$STATIC_IP/24（接口 $INTERFACE）${RESET}"
else
    echo -e "${RED}✗ 静态IP配置错误！当前 $INTERFACE 的IP：${RESET}"
    ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}'
    exit 1
fi

# 2. 检查网关连通性
print_title "2. 验证网关连通性（$GATEWAY）"
if ping -c 3 -W 2 "$GATEWAY" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 网关 $GATEWAY 可达${RESET}"
else
    echo -e "${RED}✗ 网关 $GATEWAY 不可达！请检查网线或网关配置${RESET}"
    exit 1
fi

# 3. 检查DNS解析功能
print_title "3. 验证DNS解析（服务器：$DNS_SERVER，测试域名：$TEST_DOMAIN）"
if nslookup "$TEST_DOMAIN" "$DNS_SERVER" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ DNS解析正常：$TEST_DOMAIN 已解析${RESET}"
    # 打印解析结果（可选）
    echo -e "${YELLOW}解析结果：${RESET}"
    nslookup "$TEST_DOMAIN" "$DNS_SERVER" | grep "Address" | tail -n +2
else
    echo -e "${RED}✗ DNS解析失败！请检查DNS服务器配置或网络${RESET}"
    exit 1
fi

# 4. 检查外网连通性（可选，依赖网关和DNS正常）
print_title "4. 验证外网连通性（$TEST_DOMAIN）"
if ping -c 3 -W 2 "$TEST_DOMAIN" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ 外网访问正常：$TEST_DOMAIN 可达${RESET}"
else
    echo -e "${YELLOW}⚠️ 外网访问失败，但静态IP和网关配置正常（可能是路由器限制）${RESET}"
fi

# 所有测试完成
print_title "网络测试全部完成"
echo -e "${GREEN}✓ 静态IP、网关和DNS功能正常，可访问网页更新界面：http://$STATIC_IP:8080${RESET}"