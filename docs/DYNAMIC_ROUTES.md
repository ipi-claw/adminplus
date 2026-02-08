# AdminPlus 动态路由系统文档

## 概述

AdminPlus 实现了基于用户权限的动态路由系统，前端根据后端返回的权限数据动态加载路由。这样可以实现不同角色看到不同的菜单和页面，提高系统的安全性和灵活性。

## 架构设计

### 后端部分

#### 1. 数据结构

**菜单实体 (MenuEntity)**

```java
@Entity
@Table(name = "sys_menu")
public class MenuEntity extends BaseEntity {
    private Long parentId;          // 父菜单ID
    private Integer type;           // 类型（0=目录，1=菜单，2=按钮）
    private String name;            // 菜单名称
    private String path;            // 路由路径
    private String component;       // 组件路径
    private String permKey;         // 权限标识符（如 user:add）
    private String icon;            // 图标
    private Integer sortOrder;      // 排序
    private Integer visible;        // 是否可见（1=显示，0=隐藏）
    private Integer status;         // 状态（1=正常，0=禁用）
}
```

#### 2. 核心接口

**MenuController**

```java
@GetMapping("/user/tree")
@Operation(summary = "获取当前用户的菜单树")
@PreAuthorize("isAuthenticated()")
public ApiResponse<List<MenuVO>> getUserMenuTree()
```

**MenuService**

```java
/**
 * 获取用户的菜单树（根据用户权限过滤）
 */
List<MenuVO> getUserMenuTree(Long userId);
```

#### 3. 权限过滤逻辑

1. 查询用户的角色ID列表
2. 查询这些角色的菜单ID列表（去重）
3. 查询所有菜单，包括父菜单
4. 递归添加所有父菜单到可访问菜单集合
5. 过滤出用户可访问的菜单（可见且启用状态）
6. 转换为 VO 并构建树形结构

### 前端部分

#### 1. 数据结构

**后端返回的菜单对象**

```javascript
{
  id: 1,
  parentId: 0,
  type: 0,              // 0=目录，1=菜单，2=按钮
  name: "系统管理",
  path: "/system",
  component: null,
  permKey: "system:list",
  icon: "Setting",
  sortOrder: 1,
  visible: 1,
  status: 1,
  children: [...],
  createTime: "2026-02-08T00:00:00Z",
  updateTime: "2026-02-08T00:00:00Z"
}
```

**前端路由对象**

```javascript
{
  path: "/system/user",
  name: "SystemUser",
  component: () => import('@/views/system/User.vue'),
  meta: {
    title: "用户管理",
    icon: "User",
    permission: "user:list",
    hidden: false,
    type: 1
  }
}
```

#### 2. 核心文件

**router/index.js**

- 定义静态路由（登录页、404 页面）
- 实现动态路由加载函数 `addDynamicRoutes()`
- 实现路由重置函数 `resetRouter()`
- 实现路由守卫，在用户登录后获取菜单数据并动态添加路由

**utils/dynamic-routes.js**

- `menusToRoutes()`: 将菜单数据转换为路由配置
- `flattenRoutes()`: 生成扁平化路由列表
- `filterRoutesByPermissions()`: 根据权限过滤路由

**stores/user.js**

- 添加 `hasLoadedRoutes` 状态，标记路由是否已加载
- 添加 `setRoutesLoaded()` 方法，设置路由加载状态
- 登录成功后重置路由加载状态
- 登出时清除路由加载状态

**layout/Layout.vue**

- 从后端获取用户菜单树
- 根据菜单树动态生成菜单
- 支持多层嵌套菜单

#### 3. 组件映射表

**utils/dynamic-routes.js 中的 componentMap**

```javascript
const componentMap = {
  // 系统管理模块
  '/views/system/User.vue': () => import('@/views/system/User.vue'),
  '/views/system/Role.vue': () => import('@/views/system/Role.vue'),
  '/views/system/Menu.vue': () => import('@/views/system/Menu.vue'),
  '/views/system/Dict.vue': () => import('@/views/system/Dict.vue'),
  '/views/system/DictItem.vue': () => import('@/views/system/DictItem.vue'),
  // 其他模块
  '/views/Dashboard.vue': () => import('@/views/Dashboard.vue'),
  '/views/Profile.vue': () => import('@/views/Profile.vue')
}
```

## 使用流程

### 1. 用户登录

```
用户输入账号密码 → 后端验证 → 返回 token 和用户信息 → 前端存储 token
```

### 2. 路由守卫触发

```
用户访问需要认证的路由 → 路由守卫检查 token → 检查路由是否已加载
```

### 3. 动态加载路由

```
路由未加载 → 调用 getUserMenuTree() → 获取用户菜单树 → 转换为路由配置 → 动态添加路由 → 标记路由已加载
```

### 4. 生成菜单

```
Layout 组件加载 → 调用 getUserMenuTree() → 根据菜单树生成菜单 → 渲染到侧边栏
```

## 配置说明

### 后端配置

#### 菜单数据初始化

在数据库中初始化菜单数据时，需要注意以下几点：

1. **path**: 路由路径，如 `/system/user`
2. **component**: 组件路径，如 `/views/system/User.vue`
3. **permKey**: 权限标识符，如 `user:list`
4. **icon**: 图标名称，如 `User`
5. **type**: 类型（0=目录，1=菜单，2=按钮）
6. **visible**: 是否可见（1=显示，0=隐藏）
7. **status**: 状态（1=正常，0=禁用）

#### 角色菜单关联

在 `sys_role_menu` 表中关联角色和菜单，只有关联的菜单才会返回给用户。

### 前端配置

#### 组件映射表

当添加新的页面时，需要在 `utils/dynamic-routes.js` 的 `componentMap` 中添加映射：

```javascript
const componentMap = {
  // ... 现有映射
  '/views/new/NewPage.vue': () => import('@/views/new/NewPage.vue')
}
```

#### 图标映射表

当使用新图标时，需要在 `layout/Layout.vue` 的 `iconMap` 中添加映射：

```javascript
const iconMap = {
  // ... 现有映射
  'NewIcon': NewIcon
}
```

## 数据流程图

```
┌─────────────┐
│   用户登录   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  后端验证    │
│  返回 token  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 前端存储     │
│ token 和用户 │
│ 信息        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 用户访问     │
│ 需要认证的  │
│ 路由        │
└──────┬──────┘
       │
       ▼
┌──────────────────────────┐
│      路由守卫触发         │
│  检查 token 和路由状态    │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   路由未加载              │
│  调用 getUserMenuTree()   │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│      后端处理             │
│  1. 查询用户角色          │
│  2. 查询角色菜单          │
│  3. 递归添加父菜单        │
│  4. 过滤可见启用菜单      │
│  5. 构建树形结构          │
└──────┬───────────────���───┘
       │
       ▼
┌──────────────────────────┐
│    前端接收菜单数据        │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   menusToRoutes()         │
│  转换为路由配置           │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   addDynamicRoutes()      │
│   动态添加路由到 Router   │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   setRoutesLoaded(true)   │
│   标记路由已加载          │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   重新进入当前路由        │
│   next({ ...to, replace: true }) │
└──────┬───────────────────┘
       │
       ▼
┌──────────────────────────┐
│   Layout 组件加载         │
│   调用 getUserMenuTree()  │
│   生成侧边栏菜单          │
└──────────────────────────┘
```

## 测试指南

### 1. 测试动态路由加载

1. 使用不同角色的账号登录
2. 检查侧边栏菜单是否正确显示
3. 检查路由是否正确加载
4. 尝试访问未授权的页面，应该跳转到 404

### 2. 测试权限控制

1. 使用普通用户账号登录
2. 尝试访问管理员页面，应该跳转到 404
3. 检查页面中的按钮是否根据权限显示/隐藏

### 3. 测试登出功能

1. 登录后访问需要认证的页面
2. 点击退出登录
3. 检查是否跳转到登录页
4. 检查 sessionStorage 是否已清除
5. 检查动态路由是否已清除

## 常见问题

### 1. 菜单不显示

**可能原因：**
- 菜单的 `visible` 字段为 0
- 菜单的 `status` 字段为 0
- 用户角色没有关联该菜单
- 组件路径不正确

**解决方案：**
- 检查菜单数据是否正确
- 检查角色菜单关联是否正确
- 检查组件映射表是否配置正确

### 2. 路由 404

**可能原因：**
- 组件路径不正确
- 组件映射表中没有配置
- 菜单的 `path` 字段不正确

**解决方案：**
- 检查组件路径是否正确
- 在 `componentMap` 中添加映射
- 检查菜单的 `path` 字段

### 3. 菜单图标不显示

**可能原因：**
- 图标名称不正确
- 图标映射表中没有配置
- 图标组件未引入

**解决方案：**
- 检查菜单的 `icon` 字段
- 在 `iconMap` 中添加映射
- 在 `layout/Layout.vue` 中引入图标组件

## 注意事项

1. **组件路径必须以 `/views/` 开头**，或者在 `componentMap` 中配置完整路径
2. **图标名称必须与 `iconMap` 中的键名一致**
3. **菜单的 `path` 字段必须唯一**
4. **按钮类型的菜单（type=2）不会生成路由**
5. **登录成功后会重置路由加载状态，确保下次登录重新加载路由**
6. **登出时会清除路由加载状态和动态路由**

## 扩展功能

### 1. 添加面包屑导航

根据当前路由的 `meta.title` 生成面包屑导航。

### 2. 添加标签页导航

支持多标签页切换，提高用户体验。

### 3. 添加路由缓存

使用 `<keep-alive>` 缓存路由组件，提高页面加载速度。

### 4. 添加路由权限指令

创建自定义指令 `v-permission`，根据权限控制元素显示/隐藏。

```javascript
// 使用示例
<el-button v-permission="'user:add'">添加用户</el-button>
```

## 总结

AdminPlus 的动态路由系统实现了基于用户权限的路由控制，具有以下特点：

1. **安全性**：根据用户权限动态加载路由，防止未授权访问
2. **灵活性**：通过配置菜单数据即可控制路由和菜单
3. **可维护性**：前后端分离，职责清晰
4. **可扩展性**：支持多层嵌套菜单，易于扩展新功能

通过合理配置菜单数据和角色权限，可以实现不同角色看到不同的菜单和页面，提高系统的安全性和用户体验。