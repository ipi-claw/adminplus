#!/bin/bash

# AdminPlus Dashboard 修复验证脚本
# 用于验证所有修复是否正确应用

echo "========================================="
echo "AdminPlus Dashboard 修复验证脚本"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_file() {
    local file=$1
    local description=$2

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description: $file"
        return 0
    else
        echo -e "${RED}✗${NC} $description: $file (文件不存在)"
        return 1
    fi
}

# 检查文件内容
check_content() {
    local file=$1
    local pattern=$2
    local description=$3

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        return 0
    else
        echo -e "${RED}✗${NC} $description"
        return 1
    fi
}

# 进入项目目录
cd /root/.openclaw/workspace/AdminPlus

echo "1. 检查后端文件"
echo "----------------------------------------"

# 检查后端文件是否存在
check_file "backend/src/main/java/com/adminplus/controller/DashboardController.java" "DashboardController"
check_file "backend/src/main/java/com/adminplus/service/impl/DashboardServiceImpl.java" "DashboardServiceImpl"
check_file "backend/src/main/java/com/adminplus/vo/ChartDataVO.java" "ChartDataVO"
check_file "backend/src/main/java/com/adminplus/repository/UserRepository.java" "UserRepository"
check_file "backend/src/main/java/com/adminplus/repository/RoleRepository.java" "RoleRepository"
check_file "backend/src/main/java/com/adminplus/repository/MenuRepository.java" "MenuRepository"
check_file "backend/src/main/java/com/adminplus/repository/LogRepository.java" "LogRepository"
check_file "backend/src/main/java/com/adminplus/repository/UserRoleRepository.java" "UserRoleRepository"

echo ""
echo "2. 检查后端代码优化"
echo "----------------------------------------"

# 检查后端日志优化
check_content "backend/src/main/java/com/adminplus/controller/DashboardController.java" \
    'log.info("获取用户增长趋势数据 - 开始");' \
    "DashboardController 添加了详细日志"

check_content "backend/src/main/java/com/adminplus/controller/DashboardController.java" \
    'log.error("获取用户增长趋势数据 - 失败", e);' \
    "DashboardController 添加了错误日志"

check_content "backend/src/main/java/com/adminplus/service/impl/DashboardServiceImpl.java" \
    'log.debug("获取用户增长趋势数据 - 开始");' \
    "DashboardServiceImpl 添加了详细日志"

check_content "backend/src/main/java/com/adminplus/service/impl/DashboardServiceImpl.java" \
    'log.debug("日期: {}, 新增用户数: {}", date, count);' \
    "DashboardServiceImpl 添加了数据日志"

echo ""
echo "3. 检查前端文件"
echo "----------------------------------------"

# 检查前端文件是否存在
check_file "frontend/src/views/Dashboard.vue" "Dashboard.vue"
check_file "frontend/src/api/dashboard.js" "dashboard.js"
check_file "frontend/src/utils/request.js" "request.js"
check_file "frontend/vite.config.js" "vite.config.js"
check_file "frontend/nginx.conf" "nginx.conf"

echo ""
echo "4. 检查前端代码优化"
echo "----------------------------------------"

# 检查前端日志优化
check_content "frontend/src/views/Dashboard.vue" \
    "console.log('\[Dashboard\] 开始获取用户增长趋势数据')" \
    "Dashboard.vue 添加了调试日志"

check_content "frontend/src/views/Dashboard.vue" \
    "console.log('\[Dashboard\] 用户增长趋势数据:', data)" \
    "Dashboard.vue 添加了数据日志"

check_content "frontend/src/api/dashboard.js" \
    "console.log('\[API Dashboard\] 获取用户增长趋势')" \
    "dashboard.js 添加了 API 调用日志"

check_content "frontend/src/utils/request.js" \
    "console.log('\[Request\] 响应成功:', response.config.url" \
    "request.js 添加了响应日志"

check_content "frontend/src/utils/request.js" \
    "console.error('\[Request\] 请求错误:', error.config?.url, error)" \
    "request.js 添加了错误日志"

echo ""
echo "5. 检查配置文件"
echo "----------------------------------------"

# 检查 vite.config.js
check_content "frontend/vite.config.js" \
    '// drop_console: true,' \
    "vite.config.js 禁用了 console 移除"

# 检查 nginx.conf
check_content "frontend/nginx.conf" \
    'location = /index.html' \
    "nginx.conf 添加了 index.html 不缓存配置"

check_content "frontend/nginx.conf" \
    'add_header Cache-Control "no-cache, no-store, must-revalidate";' \
    "nginx.conf 配置了不缓存"

echo ""
echo "6. 检查 API 路径"
echo "----------------------------------------"

# 检查后端 API 路径
check_content "backend/src/main/java/com/adminplus/controller/DashboardController.java" \
    '@GetMapping("/user-growth")' \
    "后端 API 路径: /user-growth"

check_content "backend/src/main/java/com/adminplus/controller/DashboardController.java" \
    '@GetMapping("/role-distribution")' \
    "后端 API 路径: /role-distribution"

check_content "backend/src/main/java/com/adminplus/controller/DashboardController.java" \
    '@GetMapping("/menu-distribution")' \
    "后端 API 路径: /menu-distribution"

# 检查前端 API 调用路径
check_content "frontend/src/api/dashboard.js" \
    "url: '/v1/sys/dashboard/user-growth'" \
    "前端 API 调用: /v1/sys/dashboard/user-growth"

check_content "frontend/src/api/dashboard.js" \
    "url: '/v1/sys/dashboard/role-distribution'" \
    "前端 API 调用: /v1/sys/dashboard/role-distribution"

check_content "frontend/src/api/dashboard.js" \
    "url: '/v1/sys/dashboard/menu-distribution'" \
    "前端 API 调用: /v1/sys/dashboard/menu-distribution"

echo ""
echo "7. 检查环境配置"
echo "----------------------------------------"

# 检查后端配置
check_content "backend/src/main/resources/application.yml" \
    'context-path: /api' \
    "后端 context-path: /api"

# 检查前端配置
check_content "frontend/.env.production" \
    'VITE_API_BASE_URL=/api' \
    "前端 API 基础路径: /api"

echo ""
echo "8. 检查 Repository 方法"
echo "----------------------------------------"

# 检查 UserRepository 方法
check_content "backend/src/main/java/com/adminplus/repository/UserRepository.java" \
    'long countByCreateTimeBetweenAndDeletedFalse(Instant startTime, Instant endTime);' \
    "UserRepository: countByCreateTimeBetweenAndDeletedFalse"

# 检查 RoleRepository 方法
check_content "backend/src/main/java/com/adminplus/repository/RoleRepository.java" \
    'List<RoleEntity> findByDeletedFalse();' \
    "RoleRepository: findByDeletedFalse"

# 检查 MenuRepository 方法
check_content "backend/src/main/java/com/adminplus/repository/MenuRepository.java" \
    'long countByTypeAndDeletedFalse(Integer type);' \
    "MenuRepository: countByTypeAndDeletedFalse"

# 检查 LogRepository 方法
check_content "backend/src/main/java/com/adminplus/repository/LogRepository.java" \
    'List<LogEntity> findTop10ByDeletedFalseOrderByCreateTimeDesc();' \
    "LogRepository: findTop10ByDeletedFalseOrderByCreateTimeDesc"

# 检查 UserRoleRepository 方法
check_content "backend/src/main/java/com/adminplus/repository/UserRoleRepository.java" \
    'List<UserRoleEntity> findByRoleId(Long roleId);' \
    "UserRoleRepository: findByRoleId"

echo ""
echo "9. 检查数据格式"
echo "----------------------------------------"

# 检查 ChartDataVO 格式
check_content "backend/src/main/java/com/adminplus/vo/ChartDataVO.java" \
    'List<String> labels,' \
    "ChartDataVO: labels 字段"

check_content "backend/src/main/java/com/adminplus/vo/ChartDataVO.java" \
    'List<Long> values' \
    "ChartDataVO: values 字段"

echo ""
echo "10. 检查空数据处理"
echo "----------------------------------------"

# 检查前端空数据处理
check_content "frontend/src/views/Dashboard.vue" \
    "if (!data || !data.labels || data.labels.length === 0 || !data.values || data.values.length === 0)" \
    "Dashboard.vue: 空数据检查"

check_content "frontend/src/views/Dashboard.vue" \
    "text: '暂无数据'" \
    "Dashboard.vue: 空数据提示"

echo ""
echo "========================================="
echo "验证完成"
echo "========================================="
echo ""
echo "如果所有检查都显示 ${GREEN}✓${NC}，说明修复已正确应用。"
echo "如果显示 ${RED}✗${NC}，请检查对应的文件或内容。"
echo ""
echo "下一步："
echo "1. 重新编译前端: cd frontend && npm run build"
echo "2. 重新构建后端: cd backend && mvn clean package -DskipTests"
echo "3. 重启服务: docker-compose restart"
echo ""