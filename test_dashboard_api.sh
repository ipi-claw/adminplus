#!/bin/bash

# AdminPlus Dashboard API 测试脚本
# 用于测试 Dashboard API 是否正常工作

echo "========================================="
echo "AdminPlus Dashboard API 测试脚本"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# API 基础 URL
API_BASE_URL="${API_BASE_URL:-http://localhost:8081/api}"

if [ -n "$1" ]; then
    API_BASE_URL="$1"
fi

echo "API 基础 URL: $API_BASE_URL"
echo ""

# 测试函数
test_api() {
    local endpoint=$1
    local description=$2
    local url="$API_BASE_URL$endpoint"

    echo -n "测试 $description... "

    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓${NC} (HTTP $http_code)"
        echo "  响应: $body" | head -c 200
        echo ""
        return 0
    else
        echo -e "${RED}✗${NC} (HTTP $http_code)"
        echo "  响应: $body" | head -c 200
        echo ""
        return 1
    fi
}

echo "========================================="
echo "测试 Dashboard API"
echo "========================================="
echo ""

# 测试统计接口
test_api "/v1/sys/dashboard/stats" "统计数据"

# 测试用户增长趋势
test_api "/v1/sys/dashboard/user-growth" "用户增长趋势"

# 测试角色分布
test_api "/v1/sys/dashboard/role-distribution" "角色分布"

# 测试菜单类型分布
test_api "/v1/sys/dashboard/menu-distribution" "菜单类型分布"

# 测试最近操作日志
test_api "/v1/sys/dashboard/recent-logs" "最近操作日志"

# 测试系统信息
test_api "/v1/sys/dashboard/system-info" "系统信息"

# 测试在线用户
test_api "/v1/sys/dashboard/online-users" "在线用户"

echo ""
echo "========================================="
echo "测试完成"
echo "========================================="
echo ""
echo "如果所有测试都显示 ${GREEN}✓${NC}，说明 API 正常工作。"
echo ""
echo "如果显示 ${RED}✗${NC}，请检查："
echo "1. 后端服务是否启动: docker ps | grep adminplus-backend"
echo "2. 后端日志: docker logs adminplus-backend"
echo "3. API 路径是否正确: $API_BASE_URL"
echo ""
echo "使用方法："
echo "  ./test_dashboard_api.sh                    # 测试本地 API"
echo "  ./test_dashboard_api.sh http://localhost:8081/api  # 测试指定 API"
echo ""