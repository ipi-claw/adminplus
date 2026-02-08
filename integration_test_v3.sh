#!/bin/bash

# AdminPlus 前后端联调测试脚本 V3
# 改进版本：更好的响应处理

BASE_URL="http://localhost:8081/api"
TOKEN=""
CAPTCHA_ID=""
CAPTCHA_CODE=""
TEST_RESULTS=()

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Redis 容器名称
REDIS_CONTAINER="adminplus-redis"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    TEST_RESULTS+=("✓ $1")
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    TEST_RESULTS+=("✗ $1")
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# API 请求函数（不输出日志，只返回响应）
api_request() {
    local method="$1"
    local url="$2"
    local data="$3"
    local auth="$4"

    local cmd="curl -s -X $method"
    cmd="$cmd -H 'Content-Type: application/json'"

    if [ -n "$auth" ] && [ "$auth" = "true" ]; then
        cmd="$cmd -H 'Authorization: Bearer $TOKEN'"
    fi

    if [ -n "$data" ]; then
        cmd="$cmd -d '$data'"
    fi

    cmd="$cmd $BASE_URL$url"

    eval $cmd
}

# 测试函数
test_api() {
    local name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local expected_code="${5:-200}"
    local auth="$6"

    log_info "测试: $name"

    local response=$(api_request "$method" "$url" "$data" "$auth")
    local http_code=$(echo "$response" | jq -r '.code // empty')

    echo "响应码: $http_code"

    if [ "$http_code" = "$expected_code" ]; then
        log_success "$name"
        echo "$response"
        return 0
    else
        log_error "$name (期望: $expected_code, 实际: $http_code)"
        echo "响应: $response"
        return 1
    fi
}

# 从 Redis 获取验证码
get_captcha_from_redis() {
    local captcha_id="$1"
    local redis_key="captcha:$captcha_id"

    # 从 Redis 容器中获取验证码
    local code=$(docker exec $REDIS_CONTAINER redis-cli GET "$redis_key" 2>/dev/null)

    if [ -n "$code" ]; then
        echo "$code"
        return 0
    else
        echo ""
        return 1
    fi
}

# 生成测试报告
generate_report() {
    echo ""
    echo "=========================================="
    echo "           测试报告"
    echo "=========================================="
    echo ""

    local passed=0
    local failed=0

    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == ✓* ]]; then
            echo -e "${GREEN}$result${NC}"
            ((passed++))
        else
            echo -e "${RED}$result${NC}"
            ((failed++))
        fi
    done

    echo ""
    echo "=========================================="
    echo "总计: ${#TEST_RESULTS[@]} | 通过: $passed | 失败: $failed"
    echo "=========================================="

    # 保存到文件
    {
        echo "# AdminPlus API 集成测试报告"
        echo ""
        echo "测试时间: $(date)"
        echo ""
        echo "## 测试结果"
        echo ""
        echo "| 测试项 | 结果 |"
        echo "|--------|------|"
        for result in "${TEST_RESULTS[@]}"; do
            if [[ $result == ✓* ]]; then
                echo "| ${result:2} | ✅ 通过 |"
            else
                echo "| ${result:2} | ❌ 失败 |"
            fi
        done
        echo ""
        echo "## 统计"
        echo "- 总计: ${#TEST_RESULTS[@]}"
        echo "- 通过: $passed"
        echo "- 失败: $failed"
        echo "- 成功率: $(echo "scale=2; $passed * 100 / ${#TEST_RESULTS[@]}" | bc)%"
    } > /root/.openclaw/workspace/AdminPlus/INTEGRATION_TEST_REPORT.md
}

echo "=========================================="
echo "  AdminPlus 前后端联调测试 V3"
echo "=========================================="
echo ""

# 检查 Redis 容器是否运行
if ! docker ps | grep -q $REDIS_CONTAINER; then
    log_error "Redis 容器未运行: $REDIS_CONTAINER"
    exit 1
fi

# 1. 登录功能测试
echo ""
echo "=========================================="
echo "1. 登录功能测试"
echo "=========================================="

# 1.1 获取验证码
log_info "1.1 获取验证码"
CAPTCHA_RESPONSE=$(api_request "GET" "/v1/captcha")
CAPTCHA_ID=$(echo $CAPTCHA_RESPONSE | jq -r '.data.captchaId')
log_info "Captcha ID: $CAPTCHA_ID"

# 1.2 从 Redis 获取验证码
log_info "1.2 从 Redis 获取验证码"
CAPTCHA_CODE=$(get_captcha_from_redis "$CAPTCHA_ID")

if [ -z "$CAPTCHA_CODE" ]; then
    log_error "无法从 Redis 获取验证码"
    exit 1
fi

log_info "验证码: $CAPTCHA_CODE"

# 1.3 登录测试 - 正确的用户名密码
log_info "1.3 登录测试 - 正确的用户名密码"
LOGIN_DATA=$(cat <<EOF
{
    "username": "admin",
    "password": "admin123",
    "captchaId": "$CAPTCHA_ID",
    "captchaCode": "$CAPTCHA_CODE"
}
EOF
)

LOGIN_RESPONSE=$(api_request "POST" "/v1/auth/login" "$LOGIN_DATA" "false")
TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.data.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" = "null" ]; then
    log_error "登录失败，无法获取 Token"
    log_info "登录响应: $LOGIN_RESPONSE"
    exit 1
fi

log_success "用户登录"
log_info "Token: ${TOKEN:0:50}..."

# 1.4 获取当前用户信息
test_api "获取当前用户信息" "GET" "/v1/auth/me" "" "200" "true"

# 1.5 获取当前用户权限
test_api "获取当前用户权限" "GET" "/v1/auth/permissions" "" "200" "true"

# 1.6 登录测试 - 错误的用户名密码
log_info "1.6 登录测试 - 错误的用户名密码"

# 获取新的验证码
NEW_CAPTCHA_RESPONSE=$(api_request "GET" "/v1/captcha")
NEW_CAPTCHA_ID=$(echo $NEW_CAPTCHA_RESPONSE | jq -r '.data.captchaId')
NEW_CAPTCHA_CODE=$(get_captcha_from_redis "$NEW_CAPTCHA_ID")

LOGIN_DATA_ERROR=$(cat <<EOF
{
    "username": "admin",
    "password": "wrongpassword",
    "captchaId": "$NEW_CAPTCHA_ID",
    "captchaCode": "$NEW_CAPTCHA_CODE"
}
EOF
)

test_api "用户登录-错误密码" "POST" "/v1/auth/login" "$LOGIN_DATA_ERROR" "500" "false"

# 2. 用户管理功能测试
echo ""
echo "=========================================="
echo "2. 用户管理功能测试"
echo "=========================================="

# 2.1 查询用户列表
test_api "查询用户列表" "GET" "/v1/sys/users?page=1&size=10" "" "200" "true"

# 2.2 创建用户
CREATE_USER_DATA='{
    "username": "testuser",
    "password": "test123",
    "nickname": "测试用户",
    "email": "test@example.com",
    "phone": "13800138000",
    "status": 1
}'
USER_CREATE_RESPONSE=$(test_api "创建用户" "POST" "/v1/sys/users" "$CREATE_USER_DATA" "200" "true")
USER_ID=$(echo $USER_CREATE_RESPONSE | jq -r '.data.id')
log_info "创建的用户ID: $USER_ID"

# 2.3 查询用户详情
if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
    test_api "查询用户详情" "GET" "/v1/sys/users/$USER_ID" "" "200" "true"

    # 2.4 更新用户
    UPDATE_USER_DATA='{
        "nickname": "测试用户-更新",
        "email": "test_updated@example.com"
    }'
    test_api "更新用户" "PUT" "/v1/sys/users/$USER_ID" "$UPDATE_USER_DATA" "200" "true"

    # 2.5 更新用户状态
    test_api "更新用户状态" "PUT" "/v1/sys/users/$USER_ID/status?status=0" "" "200" "true"

    # 2.6 为用户分配角色
    ASSIGN_ROLES_DATA='[1]'
    test_api "为用户分配角色" "PUT" "/v1/sys/users/$USER_ID/roles" "$ASSIGN_ROLES_DATA" "200" "true"

    # 2.7 查询用户的角色
    test_api "查询用户的角色" "GET" "/v1/sys/users/$USER_ID/roles" "" "200" "true"

    # 2.8 删除用户
    test_api "删除用户" "DELETE" "/v1/sys/users/$USER_ID" "" "200" "true"
else
    log_warning "用户创建失败，跳过后续用户测试"
fi

# 2.9 测试权限控制 - 无权限访问
test_api "无权限访问用户列表" "GET" "/v1/sys/users" "" "403" "false"

# 3. 角色管理功能测试
echo ""
echo "=========================================="
echo "3. 角色管理功能测试"
echo "=========================================="

# 3.1 查询角色列表
test_api "查询角色列表" "GET" "/v1/sys/roles" "" "200" "true"

# 3.2 创建角色
CREATE_ROLE_DATA='{
    "roleName": "测试角色",
    "roleCode": "test_role",
    "description": "这是一个测试角色",
    "status": 1
}'
ROLE_CREATE_RESPONSE=$(test_api "创建角色" "POST" "/v1/sys/roles" "$CREATE_ROLE_DATA" "200" "true")
ROLE_ID=$(echo $ROLE_CREATE_RESPONSE | jq -r '.data.id')
log_info "创建的角色ID: $ROLE_ID"

# 3.3 查询角色详情
if [ -n "$ROLE_ID" ] && [ "$ROLE_ID" != "null" ]; then
    test_api "查询角色详情" "GET" "/v1/sys/roles/$ROLE_ID" "" "200" "true"

    # 3.4 更新角色
    UPDATE_ROLE_DATA='{
        "roleName": "测试角色-更新",
        "description": "这是更新后的测试角色"
    }'
    test_api "更新角色" "PUT" "/v1/sys/roles/$ROLE_ID" "$UPDATE_ROLE_DATA" "200" "true"

    # 3.5 为角色分配菜单权限
    ASSIGN_MENUS_DATA='[1, 2, 3]'
    test_api "为角色分配菜单权限" "PUT" "/v1/sys/roles/$ROLE_ID/menus" "$ASSIGN_MENUS_DATA" "200" "true"

    # 3.6 查询角色的菜单权限
    test_api "查询角色的菜单权限" "GET" "/v1/sys/roles/$ROLE_ID/menus" "" "200" "true"

    # 3.7 删除角色
    test_api "删除角色" "DELETE" "/v1/sys/roles/$ROLE_ID" "" "200" "true"
else
    log_warning "角色创建失败，跳过后续角色测试"
fi

# 4. 权限管理功能测试
echo ""
echo "=========================================="
echo "4. 权限管理功能测试"
echo "=========================================="

# 4.1 获取当前用户权限
test_api "获取当前用户权限" "GET" "/v1/sys/permissions/current" "" "200" "true"

# 4.2 获取当前用户角色
test_api "获取当前用户角色" "GET" "/v1/sys/permissions/current/roles" "" "200" "true"

# 4.3 获取所有可用权限
test_api "获取所有可用权限" "GET" "/v1/sys/permissions/all" "" "200" "true"

# 5. 菜单管理功能测试
echo ""
echo "=========================================="
echo "5. 菜单管理功能测试"
echo "=========================================="

# 5.1 查询菜单树
test_api "查询菜单树" "GET" "/v1/sys/menus/tree" "" "200" "true"

# 5.2 创建菜单
CREATE_MENU_DATA='{
    "menuName": "测试菜单",
    "menuType": "menu",
    "parentId": 0,
    "path": "/test",
    "component": "test/index",
    "icon": "test",
    "orderNum": 100,
    "status": 1
}'
MENU_CREATE_RESPONSE=$(test_api "创建菜单" "POST" "/v1/sys/menus" "$CREATE_MENU_DATA" "200" "true")
MENU_ID=$(echo $MENU_CREATE_RESPONSE | jq -r '.data.id')
log_info "创建的菜单ID: $MENU_ID"

# 5.3 查询菜单详情
if [ -n "$MENU_ID" ] && [ "$MENU_ID" != "null" ]; then
    test_api "查询菜单详情" "GET" "/v1/sys/menus/$MENU_ID" "" "200" "true"

    # 5.4 更新菜单
    UPDATE_MENU_DATA='{
        "menuName": "测试菜单-更新",
        "orderNum": 101
    }'
    test_api "更新菜单" "PUT" "/v1/sys/menus/$MENU_ID" "$UPDATE_MENU_DATA" "200" "true"

    # 5.5 删除菜单
    test_api "删除菜单" "DELETE" "/v1/sys/menus/$MENU_ID" "" "200" "true"
else
    log_warning "菜单创建失败，跳过后续菜单测试"
fi

# 6. 字典管理功能测试
echo ""
echo "=========================================="
echo "6. 字典管理功能测试"
echo "=========================================="

# 6.1 查询字典列表
test_api "查询字典列表" "GET" "/v1/sys/dicts?page=1&size=10" "" "200" "true"

# 6.2 创建字典
CREATE_DICT_DATA='{
    "dictType": "test_dict",
    "dictName": "测试字典",
    "description": "这是一个测试字典",
    "status": 1
}'
DICT_CREATE_RESPONSE=$(test_api "创建字典" "POST" "/v1/sys/dicts" "$CREATE_DICT_DATA" "200" "true")
DICT_ID=$(echo $DICT_CREATE_RESPONSE | jq -r '.data.id')
log_info "创建的字典ID: $DICT_ID"

# 6.3 查询字典详情
if [ -n "$DICT_ID" ] && [ "$DICT_ID" != "null" ]; then
    test_api "查询字典详情" "GET" "/v1/sys/dicts/$DICT_ID" "" "200" "true"

    # 6.4 根据字典类型查询
    test_api "根据字典类型查询" "GET" "/v1/sys/dicts/type/test_dict" "" "200" "true"

    # 6.5 更新字典
    UPDATE_DICT_DATA='{
        "dictName": "测试字典-更新",
        "description": "这是更新后的测试字典"
    }'
    test_api "更新字典" "PUT" "/v1/sys/dicts/$DICT_ID" "$UPDATE_DICT_DATA" "200" "true"

    # 6.6 更新字典状态
    test_api "更新字典状态" "PUT" "/v1/sys/dicts/$DICT_ID/status?status=0" "" "200" "true"

    # 6.7 删除字典
    test_api "删除字典" "DELETE" "/v1/sys/dicts/$DICT_ID" "" "200" "true"
else
    log_warning "字典创建失败���跳过后续字典测试"
fi

# 7. 配置管理功能测试
echo ""
echo "=========================================="
echo "7. 配置管理功能测试"
echo "=========================================="

# 7.1 获取应用配置（通过 Actuator）
test_api "健康检查" "GET" "/actuator/health" "" "200" "true"

# 7.2 获取应用信息
test_api "应用信息" "GET" "/actuator/info" "" "200" "true"

# 8. 日志管理功能测试
echo ""
echo "=========================================="
echo "8. 日志管理功能测试"
echo "=========================================="

# 8.1 查询日志列表（注意：这里可能需要实际的日志管理 API，暂时跳过）
log_info "日志管理功能 - 需要专门的日志管理 API"

# 9. 登出测试
echo ""
echo "=========================================="
echo "9. 登出测试"
echo "=========================================="

test_api "用户登出" "POST" "/v1/auth/logout" "" "200" "true"

# 生成测试报告
generate_report

echo ""
echo "测试完成！详细报告已保存到 INTEGRATION_TEST_REPORT.md"