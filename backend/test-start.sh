#!/bin/bash

# AdminPlus 后端测试启动脚本
# 用于验证修复后的代码能否正常启动

set -e

echo "=========================================="
echo "AdminPlus 后端测试启动"
echo "=========================================="

# 进入项目目录
cd "$(dirname "$0")"

# 检查 Java 版本
echo ""
echo "检查 Java 版本..."
java -version

# 检查 Maven 版本
echo ""
echo "检查 Maven 版本..."
mvn --version

# 清理并编译项目
echo ""
echo "=========================================="
echo "开始编译项目..."
echo "=========================================="
mvn clean compile -DskipTests

# 打包项目
echo ""
echo "=========================================="
echo "开始打包项目..."
echo "=========================================="
mvn package -DskipTests

# 检查是否生成了 JAR 文件
if [ -f "target/adminplus-backend-1.0.0.jar" ]; then
    echo ""
    echo "✅ JAR 文件生成成功: target/adminplus-backend-1.0.0.jar"
else
    echo ""
    echo "❌ JAR 文件生成失败"
    exit 1
fi

# 检查是否有编译错误
if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 编译成功！"
    echo "=========================================="
    echo ""
    echo "可以使用以下命令启动应用："
    echo "  java -jar target/adminplus-backend-1.0.0.jar"
    echo ""
    echo "或者使用 Docker Compose 启动完整服务："
    echo "  cd .. && docker-compose up -d"
    echo ""
else
    echo ""
    echo "=========================================="
    echo "❌ 编译失败！"
    echo "=========================================="
    exit 1
fi