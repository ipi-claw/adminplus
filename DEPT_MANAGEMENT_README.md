# 部门管理功能实现说明

## 修复问题

### 1. 修复异步日志保存失败问题

**问题描述：**
用户登出后，异步日志保存任务尝试获取用户信息，但用户已登出，SecurityContext 可能已清空，导致抛出异常。

**修复方案：**
在 `LogServiceImpl` 的所有 `log` 方法中，添加了 `SecurityUtils.isAuthenticated()` 检查。如果用户已登出（SecurityContext 为空），则跳过日志保存，避免异常。

**修改文件：**
- `backend/src/main/java/com/adminplus/service/impl/LogServiceImpl.java`

**修改内容：**
在每个 `log` 方法的开始处添加：
```java
// 检查 SecurityContext 是否包含用户信息，如果为空则跳过日志保存
if (!SecurityUtils.isAuthenticated()) {
    log.debug("用户已登出，跳过日志保存: module={}, operationType={}, description={}", module, operationType, description);
    return;
}
```

## 新增功能

### 2. 实现部门管理功能

#### 2.1 数据库表结构

**表名：** `sys_dept`

**字段说明：**
- `id`: 主键
- `parent_id`: 父部门ID（用于构建树形结构）
- `name`: 部门名称
- `code`: 部门编码
- `leader`: 负责人
- `phone`: 联系电话
- `email`: 邮箱
- `sort_order`: 排序
- `status`: 状态（1=正常，0=禁用）
- `create_time`: 创建时间
- `update_time`: 更新时间
- `deleted`: 是否删除

**SQL 脚本：**
- `backend/docs/init_dept.sql` - 部门表创建及初始数据
- `backend/docs/init_dept_menu.sql` - 部门管理菜单权限

#### 2.2 实体类

**文件：** `backend/src/main/java/com/adminplus/entity/DeptEntity.java`

```java
@Entity
@Table(name = "sys_dept")
public class DeptEntity extends BaseEntity {
    private Long parentId;
    private String name;
    private String code;
    private String leader;
    private String phone;
    private String email;
    private Integer sortOrder;
    private Integer status;
}
```

#### 2.3 Repository

**文件：** `backend/src/main/java/com/adminplus/repository/DeptRepository.java`

提供以下方法：
- `findAllByOrderBySortOrderAsc()` - 查询所有部门（按排序）
- `countByDeletedFalse()` - 统计未删除的部门数量
- `findByParentIdOrderBySortOrderAsc(Long parentId)` - 根据父部门ID查询子部门
- `existsByNameAndIdNotAndDeletedFalse(String name, Long id)` - 检查部门名称是否存在（排除指定ID）
- `existsByNameAndDeletedFalse(String name)` - 检查部门名称是否存在

#### 2.4 VO（视图对象）

**文件：** `backend/src/main/java/com/adminplus/vo/DeptVO.java`

```java
public record DeptVO(
    Long id,
    Long parentId,
    String name,
    String code,
    String leader,
    String phone,
    String email,
    Integer sortOrder,
    Integer status,
    List<DeptVO> children,
    Instant createTime,
    Instant updateTime
) {}
```

#### 2.5 DTO（数据传输对象）

**DeptCreateReq** - 创建部门请求
**文件：** `backend/src/main/java/com/adminplus/dto/DeptCreateReq.java`

**DeptUpdateReq** - 更新部门请求
**文件：** `backend/src/main/java/com/adminplus/dto/DeptUpdateReq.java`

#### 2.6 Service

**接口：** `backend/src/main/java/com/adminplus/service/DeptService.java`

**实现：** `backend/src/main/java/com/adminplus/service/impl/DeptServiceImpl.java`

**核心功能：**
1. `getDeptTree()` - 查询部门树形列表
2. `getDeptById(Long id)` - 根据ID查询部门
3. `createDept(DeptCreateReq req)` - 创建部门
4. `updateDept(Long id, DeptUpdateReq req)` - ���新部门
5. `deleteDept(Long id)` - 删除部门

**特殊处理：**
- 树形结构构建：使用递归方式构建部门树
- 循环引用检测：防止将部门设置为自己的子部门
- 子部门检查：删除部门前检查是否有子部门
- 名称唯一性检查：创建和更新时检查部门名称是否重复

#### 2.7 Controller

**文件：** `backend/src/main/java/com/adminplus/controller/DeptController.java`

**API 接口：**
- `GET /v1/sys/depts/tree` - 查询部门树形列表
- `GET /v1/sys/depts/{id}` - 根据ID查询部门
- `POST /v1/sys/depts` - 创建部门
- `PUT /v1/sys/depts/{id}` - 更新部门
- `DELETE /v1/sys/depts/{id}` - 删除部门

**权限控制：**
- `dept:list` - 查询部门列表
- `dept:query` - 查询部门详情
- `dept:add` - 新增部门
- `dept:edit` - 编辑部门
- `dept:delete` - 删除部门

## 初始数据

### 部门初始数据

```
AdminPlus 总部 (HQ)
├── 技术研发部 (RD)
│   ├── 后端开发组 (RD-BE)
│   └── 前端开发组 (RD-FE)
└── 市场运营部 (MK)
    ├── 市场推广组 (MK-MKT)
    └── 客户服务组 (MK-CS)
```

### 菜单权限

在"系统管理"模块下添加了"部门管理"菜单：
- 部门管理（菜单）
  - 新增部门（按钮权限）
  - 编辑部门（按钮权限）
  - 删除部门（按钮权限）
  - 查询部门（按钮权限）
  - 部门列表（按钮权限）

## 使用说明

### 1. 执行数据库脚本

```bash
# 创建部门表
psql -U postgres -d adminplus -f backend/docs/init_dept.sql

# 添加部门管理菜单权限
psql -U postgres -d adminplus -f backend/docs/init_dept_menu.sql
```

### 2. API 使用示例

#### 查询部门树形列表
```bash
curl -X GET http://localhost:8080/v1/sys/depts/tree \
  -H "Authorization: Bearer {token}"
```

#### 创建部门
```bash
curl -X POST http://localhost:8080/v1/sys/depts \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "parentId": 0,
    "name": "测试部门",
    "code": "TEST",
    "leader": "测试负责人",
    "phone": "13800138000",
    "email": "test@example.com",
    "sortOrder": 1,
    "status": 1
  }'
```

#### 更新部门
```bash
curl -X PUT http://localhost:8080/v1/sys/depts/{id} \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新后的部门名称",
    "leader": "新负责人"
  }'
```

#### 删除部门
```bash
curl -X DELETE http://localhost:8080/v1/sys/depts/{id} \
  -H "Authorization: Bearer {token}"
```

## 开发规范

所有代码均按照 AdminPlus 开发规范进行开发：
1. 使用 Lombok 简化代码
2. 使用 Record 作为 VO 和 DTO
3. 使用 Optional 处理可选字段
4. 使用 Jakarta Validation 进行参数校验
5. 使用 Spring Security 进行权限控制
6. 使用 Swagger/OpenAPI 进行 API 文档
7. 使用 @Transactional 进行事务管理
8. 使用 @Async 进行异步处理
9. 使用 ApiResponse 统一响应格式
10. 使用 BizException 处理业务异常

## 注意事项

1. **删除部门限制**：不能删除有子部门的部门
2. **循环引用检测**：更新部门时，不能将部门设置为自己的子部门
3. **名称唯一性**：部门名称必须唯一
4. **权限控制**：所有接口都需要相应的权限
5. **异步日志**：已修复异步日志保存时的用户信息检查问题

## 测试建议

1. 测试部门树形结构的正确性
2. 测试创建部门时的名称唯一性检查
3. 测试更新部门时的循环引用检测
4. 测试删除部门时的子部门检查
5. 测试权限控制是否生效
6. 测试异步日志保存是否正常

## 后续优化建议

1. 添加部门批量导入功能
2. 添加部门批量状态更新功能
3. 添加部门数据权限控制（基于部门的数据范围）
4. 添加部门与用户的关联管理
5. 添加部门数据的导出功能