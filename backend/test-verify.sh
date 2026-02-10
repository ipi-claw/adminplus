#!/bin/bash

echo "======================================="
echo "AdminPlus 测试验证脚本"
echo "======================================="

echo ""
echo "1. 检查测试依赖..."

# 检查测试依赖是否下载
if [ -d "~/.m2/repository/org/junit" ]; then
    echo "   ✅ JUnit 依赖存在"
else
    echo "   ❌ JUnit 依赖缺失"
fi

if [ -d "~/.m2/repository/org/mockito" ]; then
    echo "   ✅ Mockito 依赖存在"
else
    echo "   ❌ Mockito 依赖缺失"
fi

echo ""
echo "2. 检查测试代码语法..."

# 检查测试文件语法
test_files=$(find src/test/java -name "*.java" | head -5)
for file in $test_files; do
    echo "   检查: $(basename $file)"
    if javac -cp "" -sourcepath src/test/java $file 2>/dev/null; then
        echo "   ✅ 语法正确"
    else
        echo "   ❌ 语法错误"
    fi
done

echo ""
echo "3. 检查测试配置..."

if [ -f "src/test/resources/application-test.yml" ]; then
    echo "   ✅ 测试配置文件存在"
else
    echo "   ❌ 测试配置文件缺失"
fi

echo ""
echo "4. 运行简单测试验证..."

# 尝试运行最简单的测试
echo "   尝试运行 RedisConnectionTest..."
timeout 30s mvn test -Dtest=RedisConnectionTest -q
if [ $? -eq 0 ]; then
    echo "   ✅ RedisConnectionTest 通过"
else
    echo "   ❌ RedisConnectionTest 失败"
fi

echo ""
echo "======================================="
echo "测试验证完成"
echo "======================================="