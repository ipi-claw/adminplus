#!/bin/bash

# AdminPlus 字典项树形结构改造 - 验证脚本

echo "======================================"
echo "AdminPlus 字典项树形结构改造验证"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
TOTAL=0
PASSED=0
FAILED=0

# 检查函数
check_file() {
    local file=$1
    local description=$2

    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] 检查 $description... "

    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ 通过${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

check_content() {
    local file=$1
    local pattern=$2
    local description=$3

    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] 检查 $description... "

    if grep -q "$pattern" "$file" 2>/dev/null; then
        echo -e "${GREEN}✓ 通过${NC}"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ 失败${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

echo "1. 检查后端文件"
echo "------------------------------------"
check_file "backend/src/main/java/com/adminplus/entity/DictItemEntity.java" "DictItemEntity.java"
check_file "backend/src/main/java/com/adminplus/vo/DictItemVO.java" "DictItemVO.java"
check_file "backend/src/main/java/com/adminplus/dto/DictItemCreateReq.java" "DictItemCreateReq.java"
check_file "backend/src/main/java/com/adminplus/dto/DictItemUpdateReq.java" "DictItemUpdateReq.java"
check_file "backend/src/main/java/com/adminplus/service/DictItemService.java" "DictItemService.java"
check_file "backend/src/main/java/com/adminplus/service/impl/DictItemServiceImpl.java" "DictItemServiceImpl.java"
check_file "backend/src/main/java/com/adminplus/controller/DictItemController.java" "DictItemController.java"
echo ""

echo "2. 检查前端文件"
echo "------------------------------------"
check_file "frontend/src/api/dict.js" "dict.js API"
check_file "frontend/src/views/system/DictItem.vue" "DictItem.vue 视图"
echo ""

echo "3. 检查文档文件"
echo "------------------------------------"
check_file "DICT_ITEM_TREE_CHANGES.md" "完成报告"
check_file "DICT_ITEM_TREE_TEST_PLAN.md" "测试计划"
check_file "DICT_ITEM_TREE_QUICK_REF.md" "快速参考"
check_file "DICT_ITEM_TREE_SUMMARY.md" "完成总结"
echo ""

echo "4. 检查后端代码修改"
echo "------------------------------------"
check_content "backend/src/main/java/com/adminplus/entity/DictItemEntity.java" "private Long parentId" "DictItemEntity parentId 字段"
check_content "backend/src/main/java/com/adminplus/vo/DictItemVO.java" "List<DictItemVO> children" "DictItemVO children 字段"
check_content "backend/src/main/java/com/adminplus/vo/DictItemVO.java" "Long parentId" "DictItemVO parentId 字段"
check_content "backend/src/main/java/com/adminplus/dto/DictItemCreateReq.java" "Long parentId" "DictItemCreateReq parentId 参数"
check_content "backend/src/main/java/com/adminplus/dto/DictItemUpdateReq.java" "Long parentId" "DictItemUpdateReq parentId 参数"
check_content "backend/src/main/java/com/adminplus/service/DictItemService.java" "getDictItemTreeByDictId" "DictItemService 树形方法"
check_content "backend/src/main/java/com/adminplus/controller/DictItemController.java" '"/tree"' "DictItemController /tree 端点"
echo ""

echo "5. 检查前端代码修改"
echo "------------------------------------"
check_content "frontend/src/api/dict.js" "getDictItemTree" "dict.js getDictItemTree 方法"
check_content "frontend/src/views/system/DictItem.vue" 'tree-props' "DictItem.vue 树形表格"
check_content "frontend/src/views/system/DictItem.vue" "el-tree-select" "DictItem.vue 父节点选择器"
check_content "frontend/src/views/system/DictItem.vue" "新增子项" "DictItem.vue 新增子项按钮"
echo ""

echo "======================================"
echo "验证结果汇总"
echo "======================================"
echo -e "总计: $TOTAL"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 所有检查通过！${NC}"
    echo ""
    echo "下一步："
    echo "1. 执行数据库迁移：ALTER TABLE sys_dict_item ADD COLUMN parent_id BIGINT"
    echo "2. 编译后端项目：cd backend && mvn clean package"
    echo "3. 构建前端项目：cd frontend && npm run build"
    echo "4. 启动项目并测试"
    echo "5. 参考 DICT_ITEM_TREE_TEST_PLAN.md 进行测试"
    exit 0
else
    echo -e "${RED}✗ 部分检查失败，请检查上述错误${NC}"
    exit 1
fi