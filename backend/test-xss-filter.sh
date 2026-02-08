#!/bin/bash

# XssFilter 修复验证脚本

set -e

echo "=========================================="
echo "XssFilter 修复验证"
echo "=========================================="

# 进入项目目录
cd "$(dirname "$0")"

echo ""
echo "步骤 1: 清理并编译项目..."
mvn clean compile -DskipTests

echo ""
echo "步骤 2: 打包项目..."
mvn package -DskipTests

echo ""
echo "=========================================="
echo "✅ 编译成功！"
echo "=========================================="
echo ""
echo "现在可以启动应用进行测试："
echo ""
echo "  方式一：使用 Maven 启动"
echo "  mvn spring-boot:run"
echo ""
echo "  方式二：使用 JAR 包启动"
echo "  java -jar target/adminplus-backend-1.0.0.jar"
echo ""
echo "  方式三：使用 Docker Compose"
echo "  cd .. && docker-compose up -d"
echo ""
echo "启动后，检查日志中是否出现以下错误："
echo "  ❌ Failed to register 'filter xssFilter'"
echo ""
echo "如果没有出现该错误，说明修复成功！"
echo ""
echo "=========================================="