#!/bin/bash

# AdminPlus 测试运行脚本

echo "======================================="
echo "AdminPlus 项目测试运行"
echo "======================================="

# 检查是否在项目根目录
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "错误：请在 AdminPlus 项目根目录运行此脚本"
    exit 1
fi

echo ""
echo "1. 运行后端测试..."
echo ""

cd backend

# 运行单元测试
echo "运行单元测试..."
mvn test -Dtest=**/*Test

# 检查测试结果
if [ $? -eq 0 ]; then
    echo "✅ 后端单元测试通过"
else
    echo "❌ 后端单元测试失败"
    exit 1
fi

echo ""
echo "2. 运行前端测试..."
echo ""

cd ../frontend

# 检查是否安装了测试依赖
if [ ! -d "node_modules" ]; then
    echo "安装前端依赖..."
    npm install
fi

# 运行前端测试
echo "运行前端测试..."
npm run test:run

if [ $? -eq 0 ]; then
    echo "✅ 前端测试通过"
else
    echo "❌ 前端测试失败"
    exit 1
fi

echo ""
echo "======================================="
echo "所有测试通过！✅"
echo "======================================="