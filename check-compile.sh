#!/bin/bash

echo "=== 检查编译错误 ==="
cd adminplus/backend

# 清理并编译
echo "清理target目录..."
rm -rf target

echo "开始编译..."
mvn compile -DskipTests 2>&1 | tee compile.log

echo ""
echo "=== 编译错误汇总 ==="
grep -E "(ERROR|cannot find symbol)" compile.log | head -20

echo ""
echo "=== 编译状态 ==="
if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译��败"
    echo "详细错误请查看 compile.log 文件"
fi