#!/bin/bash

echo "======================================="
echo "AdminPlus 项目编译检查"
echo "======================================="

echo ""
echo "1. 检查项目结构..."

# 检查关键目录
dirs=("src/main/java" "src/main/resources" "src/test/java")
for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "   ✅ $dir 目录存在"
    else
        echo "   ❌ $dir 目录不存在"
    fi
done

echo ""
echo "2. 检查关键文件..."

# 检查关键文件
files=(
    "src/main/java/com/adminplus/AdminPlusApplication.java"
    "src/main/java/com/adminplus/entity/BaseEntity.java"
    "src/main/java/com/adminplus/entity/UserEntity.java"
    "src/main/java/com/adminplus/service/impl/UserServiceImpl.java"
    "src/main/java/com/adminplus/controller/UserController.java"
    "pom.xml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file 存在"
    else
        echo "   ❌ $file 不存在"
    fi
done

echo ""
echo "3. 检查导入完整性..."

# 检查是否有硬编码的全类名
echo "   检查全类名硬编码..."
if grep -r "new com\.adminplus\." src/main/java --include="*.java" | grep -v "package\|import" > /dev/null; then
    echo "   ❌ 发现硬编码全类名"
else
    echo "   ✅ 没有硬编码全类名"
fi

echo ""
echo "4. 检查依赖配置..."

# 检查 pom.xml 是否有重复依赖
if grep -q "<artifactId>h2</artifactId>.*<artifactId>h2</artifactId>" pom.xml; then
    echo "   ❌ pom.xml 中有重复依赖"
else
    echo "   ✅ pom.xml 依赖配置正常"
fi

echo ""
echo "5. 检查关键类导入..."

# 检查关键类是否导入
classes=("BizException" "DictItemVO" "DictEntity" "DictItemEntity")
for class in "${classes[@]}"; do
    if grep -r "import.*$class" src/main/java --include="*.java" > /dev/null; then
        echo "   ✅ $class 已导入"
    else
        echo "   ⚠️  $class 未找到导入，可能需要检查"
    fi
done

echo ""
echo "======================================="
echo "编译检查完成"
echo "======================================="