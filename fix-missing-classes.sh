#!/bin/bash

echo "=== 检查并修复缺失的类 ==="

cd adminplus/backend

# 检查常见的可能缺失的Spring类
MISSING_CLASSES=(
    "org.springframework.transaction.annotation.Transactional"
    "org.springframework.data.domain.PageRequest"
    "org.springframework.data.domain.Pageable"
    "org.springframework.data.domain.Sort"
    "org.springframework.security.crypto.password.PasswordEncoder"
    "org.springframework.scheduling.annotation.Async"
    "org.springframework.stereotype.Service"
    "lombok.RequiredArgsConstructor"
    "lombok.extern.slf4j.Slf4j"
)

echo "检查导入的类..."
for class in "${MISSING_CLASSES[@]}"; do
    count=$(grep -r "import $class" src/main/java | wc -l)
    echo "  $class: $count 次引用"
done

echo ""
echo "检查注解使用..."
ANNOTATIONS=(
    "@Transactional"
    "@Service"
    "@Slf4j"
    "@RequiredArgsConstructor"
    "@Async"
)

for annotation in "${ANNOTATIONS[@]}"; do
    count=$(grep -r "$annotation" src/main/java | wc -l)
    echo "  $annotation: $count 次使用"
done

echo ""
echo "=== 检查完成 ==="