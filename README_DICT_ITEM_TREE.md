# AdminPlus 字典项树形结构功能

## 功能概述

字典项树形结构功能允许字典项之间建立父子关系，实现层级化管理。例如，可以创建"省份-城市-区县"的层级结构。

## 快速开始

### 1. 数据库迁移

```sql
-- 添加 parent_id 字段
ALTER TABLE sys_dict_item ADD COLUMN parent_id BIGINT COMMENT '父节点ID';

-- 添加索引以提升性能
CREATE INDEX idx_dict_item_parent_id ON sys_dict_item(parent_id);
```

### 2. 编译和部署

```bash
# 后端
cd backend
mvn clean package
java -jar target/adminplus.jar

# 前端
cd frontend
npm run build
```

### 3. 使用示例

#### 创建顶级节点
1. 进入字典项管理页面
2. 点击"新增字典项"
3. 不选择父节点
4. 输入标签和值
5. 点击确定

#### 创建子节点
1. 在树形表格中找到父节点
2. 点击"新增子项"按钮
3. 输入标签和值
4. 点击确定

#### 修改父节点
1. 点击字典项的"编辑"按钮
2. 在"父节点"选择器中选择新的父节点
3. 点击确定

## 核心功能

### ✅ 树形结构展示
- 使用 Element Plus 树形表格
- 支持展开/折叠节点
- 默认展开所有节点

### ✅ 父节点管理
- 新增时选择父节点
- 编辑时修改父节点
- 自动排除当前节点及其子节点

### ✅ 新增子项
- 快速创建子字典项
- 自动设置父节点

### ✅ 循环引用防护
- 防止将节点设置为自己的子节点
- 防止将节点设置为自己的后代节点

### ✅ 数据验证
- 验证父节点存在性
- 验证父节点属于同一字典

## API 文档

### 获取字典项树

```http
GET /sys/dicts/{dictId}/items/tree
```

**响应示例**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "label": "省份",
      "value": "province",
      "parentId": null,
      "children": [
        {
          "id": 2,
          "label": "广东省",
          "value": "guangdong",
          "parentId": 1,
          "children": [
            {
              "id": 3,
              "label": "广州市",
              "value": "guangzhou",
              "parentId": 2,
              "children": null
            }
          ]
        }
      ]
    }
  ]
}
```

### 创建字典项

```http
POST /sys/dicts/{dictId}/items
```

**请求体**:
```json
{
  "dictId": 1,
  "parentId": 1,
  "label": "深圳市",
  "value": "shenzhen",
  "sortOrder": 1,
  "status": 1
}
```

## 文档

- **详细报告**: [DICT_ITEM_TREE_CHANGES.md](./DICT_ITEM_TREE_CHANGES.md)
- **测试计划**: [DICT_ITEM_TREE_TEST_PLAN.md](./DICT_ITEM_TREE_TEST_PLAN.md)
- **快速参考**: [DICT_ITEM_TREE_QUICK_REF.md](./DICT_ITEM_TREE_QUICK_REF.md)
- **完成总结**: [DICT_ITEM_TREE_SUMMARY.md](./DICT_ITEM_TREE_SUMMARY.md)

## 验证

运行验证脚本检查所有修改：

```bash
./verify_tree_changes.sh
```

## 注意事项

1. **数据库迁移**: 必须先添加 parent_id 字段
2. **删除行为**: 删除父节点不会级联删除子节点
3. **权限控制**: 需要 dictitem:list 权限
4. **缓存**: 修改字典项会自动清理缓存

## 常见问题

### Q: 如何创建顶级节点？
A: 新增时不选择父节点，或将 parentId 留空。

### Q: 为什么不能将节点设置为自己的子节点？
A: 系统实现了循环引用检测，防止数据结构异常。

### Q: 删除父节点会怎样？
A: 子节点不会被删除，但 parentId 仍指向已删除的父节点 ID。

### Q: 支持拖拽排序吗？
A: 当前版本不支持，后续版本会考虑添加。

## 技术栈

- **后端**: Spring Boot + JPA + Spring Cache
- **前端**: Vue 3 + Element Plus
- **数据库**: MySQL/PostgreSQL

## 版本信息

- **版本**: 1.0.0
- **完成时间**: 2026-02-07
- **开发团队**: AdminPlus Team

## 许可证

本项目遵循 AdminPlus 项目许可证。