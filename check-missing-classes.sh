#!/bin/bash

echo "=== 检查可能缺失的类 ==="

cd adminplus/backend

# 检查所有import的类是否存在
IMPORTED_CLASSES=$(grep -r "import com.adminplus" src/main/java | cut -d' ' -f2 | sed 's/;//' | sort | uniq)

echo "检查自定义类的存在性..."
for class in $IMPORTED_CLASSES; do
    # 将包名转换为文件路径
    file_path=$(echo "$class" | sed 's/\./\//g').java
    full_path="src/main/java/$file_path"
    
    if [ ! -f "$full_path" ]; then
        echo "❌ 缺失: $class"
        echo "  文件路径: $full_path"
    fi
done

echo ""
echo "检查Spring框架类..."
SPRING_CLASSES=(
    "org.springframework.transaction.annotation.Transactional"
    "org.springframework.data.domain.PageRequest"
    "org.springframework.data.domain.Pageable"
    "org.springframework.data.domain.Sort"
    "org.springframework.security.crypto.password.PasswordEncoder"
    "org.springframework.scheduling.annotation.Async"
    "org.springframework.stereotype.Service"
)

for class in "${SPRING_CLASSES[@]}"; do
    count=$(grep -r "import $class" src/main/java | wc -l)
    if [ $count -gt 0 ]; then
        echo "✅ $class: $count 次引用"
    fi
done

echo ""
echo "检查Lombok注解..."
LOMBOK_ANNOTATIONS=(
    "@Slf4j"
    "@Service"
    "@RequiredArgsConstructor"
    "@Transactional"
    "@Async"
)

for annotation in "${LOMBOK_ANNOTATIONS[@]}"; do
    count=$(grep -r "$annotation" src/main/java | wc -l)
    echo "  $annotation: $count 次使用"
done

echo ""
echo "=== 检查完成 ==="