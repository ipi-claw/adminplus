#!/bin/bash

# AdminPlus 数据初始化测试脚本
# 用于验证应用启动时的数据初始化功能

set -e

echo "=========================================="
echo "AdminPlus 数据初始化测试"
echo "=========================================="

# 进入项目目录
cd "$(dirname "$0")"

# 检查 Docker 是否运行
echo ""
echo "检查 Docker 状态..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请启动 Docker"
    exit 1
fi
echo "✅ Docker 正在运行"

# 检查 Docker Compose 文件
echo ""
echo "检查 Docker Compose 配置..."
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ docker-compose.yml 文件不存在"
    exit 1
fi
echo "✅ docker-compose.yml 文件存在"

# 停止并清理现有容器
echo ""
echo "清理现有容器..."
docker-compose down -v

# 启动数据库服务
echo ""
echo "启动数据库服务..."
docker-compose up -d postgres redis

# 等待数据��启动
echo ""
echo "等待数据库启动..."
sleep 10

# 检查数据库连接
echo ""
echo "检查数据库连接..."
if docker-compose exec -T postgres pg_isready -U postgres; then
    echo "✅ 数据库连接正常"
else
    echo "❌ 数据库连接失败"
    exit 1
fi

# 编译后端项目
echo ""
echo "编译后端项目..."
cd backend
mvn clean compile -DskipTests

# 打包项目
echo ""
echo "打包项目..."
mvn package -DskipTests

# 检查 JAR 文件
echo ""
echo "检查 JAR 文件..."
if [ -f "target/adminplus-backend-1.0.0.jar" ]; then
    echo "✅ JAR 文件生成成功"
else
    echo "❌ JAR 文件生成失败"
    exit 1
fi

# 启动应用
echo ""
echo "启动应用进行数据初始化测试..."
cd ..
docker-compose up -d

# 等待应用启动
echo ""
echo "等待应用启动..."
sleep 30

# 检查应用健康状态
echo ""
echo "检查应用健康状态..."
if curl -f http://localhost:8081/api/actuator/health > /dev/null 2>&1; then
    echo "✅ 应用健康检查通过"
else
    echo "❌ 应用健康检查失败"
    exit 1
fi

# 验证数据初始化结果
echo ""
echo "验证数据初始化结果..."
echo ""
echo "1. 检查用户数据..."
USER_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_user WHERE deleted = false" | tr -d ' \n')
echo "   用户数量: $USER_COUNT"

if [ "$USER_COUNT" -ge 1 ]; then
    echo "   ✅ 用户数据初始化成功"
else
    echo "   ❌ 用户数据初始化失败"
fi

echo ""
echo "2. 检查角色数据..."
ROLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_role WHERE deleted = false" | tr -d ' \n')
echo "   角色数量: $ROLE_COUNT"

if [ "$ROLE_COUNT" -ge 1 ]; then
    echo "   ✅ 角色数据初始化成功"
else
    echo "   ❌ 角色数据初始化失败"
fi

echo ""
echo "3. 检查菜单数据..."
MENU_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_menu WHERE deleted = false" | tr -d ' \n')
echo "   菜单数量: $MENU_COUNT"

if [ "$MENU_COUNT" -ge 1 ]; then
    echo "   ✅ 菜单数据初始化成功"
else
    echo "   ❌ 菜单数据初始化失败"
fi

echo ""
echo "4. 检查部门数据..."
DEPT_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_dept WHERE deleted = false" | tr -d ' \n')
echo "   部门数量: $DEPT_COUNT"

if [ "$DEPT_COUNT" -ge 1 ]; then
    echo "   ✅ 部门数据初始化成功"
else
    echo "   ❌ 部门数据初始化失败"
fi

echo ""
echo "5. 检查权限关联..."
ROLE_MENU_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_role_menu" | tr -d ' \n')
echo "   权限关联数量: $ROLE_MENU_COUNT"

if [ "$ROLE_MENU_COUNT" -ge 1 ]; then
    echo "   ✅ 权限关联初始化成功"
else
    echo "   ❌ 权限关联初始化失败"
fi

echo ""
echo "6. 检查用户角色关联..."
USER_ROLE_COUNT=$(docker-compose exec -T postgres psql -U postgres -d adminplus -t -c "SELECT COUNT(*) FROM sys_user_role" | tr -d ' \n')
echo "   用户角色关联数量: $USER_ROLE_COUNT"

if [ "$USER_ROLE_COUNT" -ge 1 ]; then
    echo "   ✅ 用户角色关联初始化成功"
else
    echo "   ❌ 用户角色关联初始化失败"
fi

echo ""
echo "=========================================="
echo "数据初始化测试完成"
echo "=========================================="
echo ""
echo "测试结果总结："
echo "- 用户数据: $USER_COUNT"
echo "- 角色数据: $ROLE_COUNT"
echo "- 菜单数据: $MENU_COUNT"
echo "- 部门数据: $DEPT_COUNT"
echo "- 权限关联: $ROLE_MENU_COUNT"
echo "- 用户角色关联: $USER_ROLE_COUNT"
echo ""

# 如果所有检查都通过，则测试成功
if [ "$USER_COUNT" -ge 1 ] && [ "$ROLE_COUNT" -ge 1 ] && [ "$MENU_COUNT" -ge 1 ] && [ "$DEPT_COUNT" -ge 1 ] && [ "$ROLE_MENU_COUNT" -ge 1 ] && [ "$USER_ROLE_COUNT" -ge 1 ]; then
    echo "🎉 数据初始化测试通过！"
    echo ""
    echo "应用已成功启动并完成数据初始化"
    echo "访问地址: http://localhost:8081/api"
    echo "API 文档: http://localhost:8081/api/swagger-ui.html"
    echo ""
    echo "测试账号:"
    echo "- admin / 123456 (超级管理员)"
    echo "- manager / 123456 (部门经理)"
    echo "- user1 / 123456 (普通用户)"
else
    echo "❌ 数据初始化测试失败！"
    echo ""
    echo "请检查以下内容："
    echo "1. 应用日志: docker-compose logs backend"
    echo "2. 数据库连接: docker-compose exec postgres psql -U postgres -d adminplus"
    echo "3. 数据初始化服务配置"
    exit 1
fi