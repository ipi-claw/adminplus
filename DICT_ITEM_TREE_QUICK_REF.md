# 字典项树形结构改造 - 快速参考

## 快速开始

### 1. 数据库迁移
```sql
-- 添加 parent_id 字段到 sys_dict_item 表
ALTER TABLE sys_dict_item ADD COLUMN parent_id BIGINT COMMENT '父节点ID';

-- 可选：添加索引以提升查询性能
CREATE INDEX idx_dict_item_parent_id ON sys_dict_item(parent_id);
```

### 2. 后端 API 端点

#### 获取字典项树
```
GET /sys/dicts/{dictId}/items/tree
```

**响应示例**:
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "dictId": 1,
      "dictType": "region",
      "parentId": null,
      "label": "省份",
      "value": "province",
      "sortOrder": 0,
      "status": 1,
      "remark": null,
      "children": [
        {
          "id": 2,
          "dictId": 1,
          "dictType": "region",
          "parentId": 1,
          "label": "广东省",
          "value": "guangdong",
          "sortOrder": 0,
          "status": 1,
          "remark": null,
          "children": [
            {
              "id": 3,
              "dictId": 1,
              "dictType": "region",
              "parentId": 2,
              "label": "广州市",
              "value": "guangzhou",
              "sortOrder": 0,
              "status": 1,
              "remark": null,
              "children": null,
              "createTime": "2026-02-07T08:00:00Z",
              "updateTime": "2026-02-07T08:00:00Z"
            }
          ],
          "createTime": "2026-02-07T08:00:00Z",
          "updateTime": "2026-02-07T08:00:00Z"
        }
      ],
      "createTime": "2026-02-07T08:00:00Z",
      "updateTime": "2026-02-07T08:00:00Z"
    }
  ]
}
```

#### 创建字典项
```
POST /sys/dicts/{dictId}/items
```

**请求体**:
```json
{
  "dictId": 1,
  "parentId": 1,  // 可选，不传则为顶级节点
  "label": "深圳市",
  "value": "shenzhen",
  "sortOrder": 1,
  "status": 1,
  "remark": null
}
```

#### 更新字典项
```
PUT /sys/dicts/{dictId}/items/{id}
```

**请求体**:
```json
{
  "parentId": 2,  // 可选，可修改父节点
  "label": "深圳市",
  "value": "shenzhen",
  "sortOrder": 1,
  "status": 1,
  "remark": null
}
```

### 3. 前端使用

#### 调用树形 API
```javascript
import { getDictItemTree } from '@/api/dict'

// 获取字典项树
const treeData = await getDictItemTree(dictId)
```

#### 树形表格配置
```vue
<el-table
  :data="tableData"
  row-key="id"
  :tree-props="{ children: 'children' }"
  default-expand-all
>
  <el-table-column prop="label" label="字典标签" />
  <el-table-column prop="value" label="字典值" />
</el-table>
```

#### 父节点选择器
```vue
<el-tree-select
  v-model="form.parentId"
  :data="parentTreeData"
  :props="{ label: 'label', value: 'id' }"
  placeholder="请选择父节点"
  clearable
  check-strictly
/>
```

## 核心功能

### 1. 树形结构构建
- **后端方法**: `DictItemServiceImpl.buildTree()`
- **递归构建**: `DictItemServiceImpl.buildTreeNode()`
- **支持无限层级**: 理论上支持任意深度嵌套

### 2. 循环引用防护
- **检测方法**: `DictItemServiceImpl.isCircularReference()`
- **防护策略**: 防止将节点设置为自己的子节点或后代节点
- **最大深度**: 100 层（防止无限循环）

### 3. 父节点验证
- 验证父节点是否存在
- 验证父节点是否属于同一字典
- 验证父节点是否已删除

## 数据结构

### DictItemEntity
```java
@Entity
@Table(name = "sys_dict_item")
public class DictItemEntity extends BaseEntity {
    private Long dictId;
    private Long parentId;  // 新增
    private String label;
    private String value;
    private Integer sortOrder;
    private Integer status;
    private String remark;
}
```

### DictItemVO
```java
public record DictItemVO(
    Long id,
    Long dictId,
    String dictType,
    Long parentId,           // 新增
    String label,
    String value,
    Integer sortOrder,
    Integer status,
    String remark,
    List<DictItemVO> children,  // 新增
    Instant createTime,
    Instant updateTime
) {}
```

## 常见问题

### Q1: 如何创建顶级节点？
A: 新增时不选择父节点，或在表单中将 parentId 留空。

### Q2: 如何修改父节点？
A: 编辑字典项时，在"父节点"选择器中选择新的父节点。

### Q3: 为什么不能将节点设置为自己的子节点？
A: 后端实现了循环引用检测，防止数据结构异常。

### Q4: 删除父节点会怎样？
A: 当前实现中，删除父节点不会级联删除子节点。子节点的 parentId 仍指向已删除的父节点 ID。建议在业务层面处理此情况。

### Q5: 如何支持拖拽排序？
A: 当前版本未实现拖拽排序。可以集成第三方库如 `vuedraggable` 或 `SortableJS` 实现。

### Q6: 树形结构支持搜索吗？
A: 当前版本不支持搜索。实现需要递归过滤树形结构，较复杂。

## 性能优化建议

### 1. 数据库索引
```sql
CREATE INDEX idx_dict_item_parent_id ON sys_dict_item(parent_id);
CREATE INDEX idx_dict_item_dict_id ON sys_dict_item(dict_id);
```

### 2. 缓存策略
- 使用 Spring Cache 缓存树形结构
- 修改字典项时自动清理缓存
- 缓存键: `dictItem:tree:dictId:{dictId}`

### 3. 前端优化
- 对于大量数据，考虑使用虚拟滚动
- 默认不展开所有节点，改为按需展开
- 使用懒加载子节点

## 安全考虑

### 1. 权限控制
- 所有 API 端点需要相应权限
- 树形结构 API 使用 `dictitem:list` 权限

### 2. 数据验证
- 验证父节点存在性
- 验证父节点属于同一字典
- 验证循环引用

### 3. XSS 防护
- 前端使用 Vue 的数据绑定自动转义
- 后端返回 JSON 格式，避免 XSS

## 参考文档

- Element Plus 树形表格: https://element-plus.org/zh-CN/component/table.html#树形数据
- Element Plus 树选择器: https://element-plus.org/zh-CN/component/tree-select.html
- Spring Boot JPA: https://spring.io/projects/spring-data-jpa
- Vue 3 文档: https://vuejs.org/

## 修改清单

### 后端文件
- ✅ `DictItemEntity.java` - 添加 parentId 字段
- ✅ `DictItemVO.java` - 添加 parentId 和 children 字段
- ✅ `DictItemCreateReq.java` - 添加 parentId 参数
- ✅ `DictItemUpdateReq.java` - 添加 parentId 参数
- ✅ `DictItemService.java` - 添加 getDictItemTreeByDictId 方法
- ✅ `DictItemServiceImpl.java` - 实现树形构建和循环引用检测
- ✅ `DictItemController.java` - 添加 /tree 端点

### 前端文件
- ✅ `DictItem.vue` - 使用树形表格，添加父节点选择器
- ✅ `dict.js` - 添加 getDictItemTree API，修复 API 路径

## 联系支持

如有问题，请联系开发团队或查看详细文档：
- 完成报告: `DICT_ITEM_TREE_CHANGES.md`
- 测试计划: `DICT_ITEM_TREE_TEST_PLAN.md`