#!/bin/bash

echo "=== 监控编译过程 ==="
echo "开始时间: $(date)"

cd adminplus/backend

# 开始编译并捕获输出
mvn clean compile -DskipTests 2>&1 | tee compile.log

# 检查编译结果
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 编译成功！"
else
    echo ""
    echo "❌ 编译失败！"
    echo ""
    echo "=== 编译错误汇总 ==="
    grep -E "(ERROR|cannot find symbol|symbol)" compile.log | head -30
fi

echo ""
echo "结束时间: $(date)"