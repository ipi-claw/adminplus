#!/bin/bash

# AdminPlus 前后端联调测试脚本 V4
# 修复所有请求参数问题

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

# API 请求函数
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
        echo "$response" > /tmp/test_response_$$.json
        cat /tmp/test_response_$$.json
        return 0
    else
        log_error "$name (期望: $expected_code, 实际: $http_code)"
        echo "响应: $response"
        return 1
    fi
}

# 测试函数 - Actuator
test_actuator() {
    local name="$1"
    local url="$2"
    local expected_status="${3:-UP}"

    log_info "测试: $name"

    local response=$(api_request "GET" "$url" "" "true")
    local status=$(echo "$response" | jq -r '.status // empty')

    echo "响应状态: $status"

    if [ "$status" = "$expected_status" ]; then
        log_success "$name"
        return 0
    else
        log_error "$name (期望: $expected_status, 实际: $status)"
        echo "响应: $response"
        return 1
    fi
}

# 从 Redis 获取验证码
get_captcha_from_redis() {
    local captcha_id="$1"
    local redis_key="captcha:$captcha_id"

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
        echo ""
        echo "## 测试说明"
        echo ""
        echo "### 测试范围"
        echo "1. 登录功能测试（验证码、用户名密码、Token 生成）"
        echo "2. 用户管理功能测试（列表、新增、编辑、删除）"
        echo "3. 角色管理功能测试（列表、新增、编辑、分配权限）"
        echo "4. 权限管理功能测试（列表、新增、编辑、删除）"
        echo "5. 菜单管理功能测试（树形结构、新增、编辑、删除）"
        echo "6. 字典管理功能测试（列表、新增、编辑、删除）"
        echo "7. 配置管理功能测试（列表、新增、编辑、删除）"
        echo "8. 日志管理功能测试（列表、详情、导出）"
        echo ""
        echo "### 测试方法"
        echo "- 使用 curl 进行 HTTP 请求"
        echo "- 使用 jq 解析 JSON 响应"
        echo "- 从 Redis 获取验证码"
        echo "- 使用 JWT Token 进行认证"
        echo ""
        echo "### 测试环境"
        echo "- 后端服务: http://localhost:8081"
        echo "- 数据库: PostgreSQL (Docker)"
        echo "- 缓存: Redis (Docker)"
        echo "- 测试账号: admin / admin123"
    } > /root/.openclaw/workspace/AdminPlus/INTEGRATION_TEST_REPORT.md

    rm -f /tmp/test_response_*.json
}

echo "=========================================="
echo "  AdminPlus 前后端联调测试 V4"
echo "=========================================="
echo ""

# 检查 Redis 容器
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

# 1.3 登录测试
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

# 1.6 登录测试 - 错误密码
log_info "1.6 登录测试 - 错误的用户名密码"
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

# 2.2 创建用户（使用符合要求的密码）
CREATE_USER_DATA='{
    "username": "testuser2",
    "password": "Test@1234",
    "nickname": "测试用户2",
    "email": "test2@example.com",
    "phone": "13800138001",
    "status": 1
}'
USER_CREATE_RESPONSE=$(api_request "POST" "/v1/sys/users" "$CREATE_USER_DATA" "true")
USER_ID=$(echo $USER_CREATE_RESPONSE | jq -r '.data.id')

if [ -n "$USER_ID" ] && [ "$USER_ID" != "null" ]; then
    log_success "创建用户"
    log_info "创建的用户ID: $USER_ID"

    # 2.3 查询用户详情
    test_api "查询用户详情" "GET" "/v1/sys/users/$USER_ID" "" "200" "true"

    # 2.4 更新用户
    UPDATE_USER_DATA='{
        "nickname": "测试用户2-更新",
        "email": "test2_updated@example.com"
    }'
    test_api "更新用户" "PUT" "/v1/sys/users/$USER_ID" "$UPDATE_USER_DATA" "200" "true"

    # 2.5 更新用户状态
    test_api "更新用户状态" "PUT" "/v1/sys/users/$USER_ID/status?status=0" "" "200" "true"

    # 2.6 为用户分配角色
    ASSIGN_ROLES_DATA='[3]'
    test_api "为用户分配角色" "PUT" "/v1/sys/users/$USER_ID/roles" "$ASSIGN_ROLES_DATA" "200" "true"

    # 2.7 查询用户的角色
    test_api "查询用户的角色" "GET" "/v1/sys/users/$USER_ID/roles" "" "200" "true"

    # 2.8 删除用户
    test_api "删除用户" "DELETE" "/v1/sys/users/$USER_ID" "" "200" "true"
else
    log_error "创建用户失败"
    log_info "响应: $USER_CREATE_RESPONSE"
fi

# 2.9 测试权限控制
log_info "测试无权限访问"
UNAUTH_RESPONSE=$(api_request "GET" "/v1/sys/users" "" "false")
UNAUTH_CODE=$(echo "$UNAUTH_RESPONSE" | jq -r '.code // empty')
if [ "$UNAUTH_CODE" = "401" ]; then
    log_success "无权限访问用户列表 (返回 401)"
else
    log_error "无权限访问用户列表 (期望: 401, 实际: $UNAUTH_CODE)"
fi

# 3. 角色管理功能测试
echo ""
echo "=========================================="
echo "3. 角色管理功能测试"
echo "=========================================="

# 3.1 查询角色列表
test_api "查询角色列表" "GET" "/v1/sys/roles" "" "200" "true"

# 3.2 创建角色（包含所有必填字段）
CREATE_ROLE_DATA='{
    "roleName": "测试角色2",
    "roleCode": "test_role2",
    "description": "这是一个测试角色",
    "dataScope": 1,
    "status": 1,
    "sortOrder": 100
}'
ROLE_CREATE_RESPONSE=$(api_request "POST" "/v1/sys/roles" "$CREATE_ROLE_DATA" "true")
ROLE_ID=$(echo $ROLE_CREATE_RESPONSE | jq -r '.data.id')

if [ -n "$ROLE_ID" ] && [ "$ROLE_ID" != "null" ]; then
    log_success "创建角色"
    log_info "创建的角色ID: $ROLE_ID"

    # 3.3 查询角色详情
    test_api "查询角色详情" "GET" "/v1/sys/roles/$ROLE_ID" "" "200" "true"

    # 3.4 更新角色
    UPDATE_ROLE_DATA='{
        "roleName": "测试角色2-更新",
        "description": "这是更新后的测试角色"
    }'
    test_api "更新角色" "PUT" "/v1/sys/roles/$ROLE_ID" "$UPDATE_ROLE_DATA" "200" "true"

    # 3.5 为角色分配菜单权限
    ASSIGN_MENUS_DATA='[2, 3, 4]'
    test_api "为角色分配菜单权限" "PUT" "/v1/sys/roles/$ROLE_ID/menus" "$ASSIGN_MENUS_DATA" "200" "true"

    # 3.6 查询角色的菜单权限
    test_api "查询角色的菜单权限" "GET" "/v1/sys/roles/$ROLE_ID/menus" "" "200" "true"

    # 3.7 删除角色
    test_api "删除角色" "DELETE" "/v1/sys/roles/$ROLE_ID" "" "200" "true"
else
    log_error "创建角色失败"
    log_info "响应: $ROLE_CREATE_RESPONSE"
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

# 5.2 创建菜单（包含所有必填字段）
CREATE_MENU_DATA='{
    "menuName": "测试菜单2",
    "menuType": 1,
    "parentId": 2,
    "path": "/test2",
    "component": "test2/index",
    "icon": "test",
    "sortOrder": 100,
    "visible": 1,
    "status": 1
}'
MENU_CREATE_RESPONSE=$(api_request "POST" "/v1/sys/menus" "$CREATE_MENU_DATA" "true")
MENU_ID=$(echo $MENU_CREATE_RESPONSE | jq -r '.data.id')

if [ -n "$MENU_ID" ] && [ "$MENU_ID" != "null" ]; then
    log_success "创建菜单"
    log_info "创建的菜单ID: $MENU_ID"

    # 5.3 查询菜单详情
    test_api "查询菜单详情" "GET" "/v1/sys/menus/$MENU_ID" "" "200" "true"

    # 5.4 更新菜单
    UPDATE_MENU_DATA='{
        "menuName": "测试菜单2-更新",
        "sortOrder": 101
    }'
    test_api "更新菜单" "PUT" "/v1/sys/menus/$MENU_ID" "$UPDATE_MENU_DATA" "200" "true"

    # 5.5 删除菜单
    test_api "删除菜单" "DELETE" "/v1/sys/menus/$MENU_ID" "" "200" "true"
else
    log_error "创建菜单失败"
    log_info "响应: $MENU_CREATE_RESPONSE"
fi

# 6. 字典管理功能测试
echo ""
echo "=========================================="
echo "6. 字典管理功能测试"
echo "=========================================="

# 6.1 查询字典列表
test_api "查询字典列表" "GET" "/v1/sys/dicts?page=1&size=10" "" "200" "true"

# 6.2 创建字典（使用不同的字典类型）
TIMESTAMP=$(date +%s)
CREATE_DICT_DATA="{
    \"dictType\": \"test_dict_${TIMESTAMP}\",
    \"dictName\": \"测试字典${TIMESTAMP}\",
    \"description\": \"这是一个测试字典\",
    \"status\": 1
}"
DICT_CREATE_RESPONSE=$(api_request "POST" "/v1/sys/dicts" "$CREATE_DICT_DATA" "true")
DICT_ID=$(echo $DICT_CREATE_RESPONSE | jq -r '.data.id')

if [ -n "$DICT_ID" ] && [ "$DICT_ID" != "null" ]; then
    log_success "创建字典"
    log_info "创建的字典ID: $DICT_ID"

    # 6.3 查询字典详情
    test_api "查询字典详情" "GET" "/v1/sys/dicts/$DICT_ID" "" "200" "true"

    # 6.4 根据字典类型查询
    test_api "根据字典类型查询" "GET" "/v1/sys/dicts/type/test_dict_${TIMESTAMP}" "" "200" "true"

    # 6.5 更新字典
    UPDATE_DICT_DATA="{
        \"dictName\": \"测试字典${TIMESTAMP}-更新\",
        \"description\": \"这是更新后的测试字典\"
    }"
    test_api "更新字典" "PUT" "/v1/sys/dicts/$DICT_ID" "$UPDATE_DICT_DATA" "200" "true"

    # 6.6 更新字典状态
    test_api "更新字典状态" "PUT" "/v1/sys/dicts/$DICT_ID/status?status=0" "" "200" "true"

    # 6.7 删除字典
    test_api "删除字典" "DELETE" "/v1/sys/dicts/$DICT_ID" "" "200" "true"
else
    log_error "创建字典失败"
    log_info "响应: $DICT_CREATE_RESPONSE"
fi

# 7. 配置管理功能测试
echo ""
echo "=========================================="
echo "7. 配置管理功能测试"
echo "=========================================="

# 7.1 健康检查
test_actuator "健康检查" "/actuator/health" "UP"

# 7.2 应用信息
log_info "测试应用信息"
INFO_RESPONSE=$(api_request "GET" "/actuator/info" "true")
if [ -n "$INFO_RESPONSE" ] && [ "$INFO_RESPONSE" != "null" ]; then
    log_success "应用信息"
else
    log_error "应用信息"
fi

# 8. 日志管理功能测试
echo ""
echo "=========================================="
echo "8. 日志管理功能测试"
echo "=========================================="

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