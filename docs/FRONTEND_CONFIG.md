# AdminPlus 前端动态路由配置指南

## 概述

本文档说明如何在 AdminPlus 前端配置动态路由，包括组件映射表、图标映射表的配置方法。

## 组件映射表配置

### 位置

`/frontend/src/utils/dynamic-routes.js`

### 说���

组件映射表用于将后端返回的组件路径转换为实际的 Vue 组件加载函数。

### 配置方法

当添加新的页面时，需要在 `componentMap` 中添加映射：

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
  '/views/Profile.vue': () => import('@/views/Profile.vue'),

  // 新增页面示例
  '/views/new/NewPage.vue': () => import('@/views/new/NewPage.vue'),
  '/views/new/AnotherPage.vue': () => import('@/views/new/AnotherPage.vue')
}
```

### 注意事项

1. **组件路径必须以 `/views/` 开头**，或者使用完整路径（以 `/` 开头）
2. **组件路径必须与后端菜单表中的 `component` 字段一致**
3. **使用动态导入 `() => import(...)`**，实现按需加载
4. **如果组件不存在，会自动跳转到 NotFound 页面**

### 示例

假设你在后端菜单表中添加了一个新菜单：

```sql
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status)
VALUES (0, 1, '新页面', '/new/page', '/views/new/NewPage.vue', 'new:list', 'NewIcon', 10, 1, 1);
```

那么你需要在前端的 `componentMap` 中添加：

```javascript
'/views/new/NewPage.vue': () => import('@/views/new/NewPage.vue')
```

## 图标映射表配置

### 位置

`/frontend/src/layout/Layout.vue`

### 说明

图标映射表用于将后端返回的图标名称转换为 Element Plus 的图标组件。

### 配置方法

当使用新图标时，需要在 `iconMap` 中添加映射：

```javascript
const iconMap = {
  'HomeFilled': HomeFilled,
  'Setting': Setting,
  'User': User,
  'UserFilled': UserFilled,
  'Menu': Menu,
  'Document': Document,
  'Tools': Tools,
  'DataAnalysis': DataAnalysis,
  'Monitor': Monitor,
  'Avatar': Avatar,

  // 新增图标示例
  'NewIcon': NewIcon,
  'AnotherIcon': AnotherIcon
}
```

### 注意事项

1. **图标名称必须与后端菜单表中的 `icon` 字段一致**
2. **需要先在 `<script setup>` 中引入图标组件**
3. **使用 Element Plus 的图标组件，参考 [Element Plus Icons](https://element-plus.org/zh-CN/component/icon.html)**

### 示例

假设你要使用 Element Plus 的 `Calendar` 图标：

1. 在 `<script setup>` 中引入：

```javascript
import {
  // ... 现有图标
  Calendar
} from '@element-plus/icons-vue'
```

2. 在 `iconMap` 中添加：

```javascript
const iconMap = {
  // ... 现有映射
  'Calendar': Calendar
}
```

3. 在后端菜单表中设置图标：

```sql
UPDATE sys_menu SET icon = 'Calendar' WHERE id = 1;
```

## 常用图标列表

以下是 Element Plus 常用的图标，可以直接使用：

### 基础图标

- `HomeFilled` - 首页
- `Setting` - 设置
- `User` - 用户
- `UserFilled` - 用户（填充）
- `Menu` - 菜单
- `Document` - 文档
- `Tools` - 工具
- `Avatar` - 头像

### 导航图标

- `ArrowDown` - 向下箭头
- `ArrowLeft` - 向左箭头
- `ArrowRight` - 向右箭头
- `ArrowUp` - 向上箭头
- `Back` - 返回
- `Bottom` - 底部
- `Top` - 顶部

### 操作图标

- `Plus` - 加号
- `Minus` - 减号
- `Close` - 关闭
- `Check` - 对勾
- `Delete` - 删除
- `Edit` - 编辑
- `Search` - 搜索
- `Refresh` - 刷新

### 数据图标

- `DataAnalysis` - 数据分析
- `Monitor` - 监控
- `TrendCharts` - 趋势图
- `PieChart` - 饼图
- `Histogram` - 柱状图

### 反馈图标

- `SuccessFilled` - 成功
- `WarningFilled` - 警告
- `InfoFilled` - 信息
- `CircleCloseFilled` - 错误

更多图标请参考：[Element Plus Icons](https://element-plus.org/zh-CN/component/icon.html)

## 路由元信息配置

### 路由元信息结构

```javascript
{
  path: '/system/user',
  name: 'SystemUser',
  component: () => import('@/views/system/User.vue'),
  meta: {
    title: '用户管理',        // 菜单标题
    icon: 'User',            // 图标名称
    permission: 'user:list', // 权限标识
    hidden: false,           // 是否隐藏
    type: 1                  // 类型（0=目录，1=菜单，2=按钮）
  }
}
```

### 元信息说明

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| title | String | 菜单标题 | "用户管理" |
| icon | String | 图标名称 | "User" |
| permission | String | 权限标识 | "user:list" |
| hidden | Boolean | 是否隐藏 | false |
| type | Number | 类型 | 1 |

### 使用示例

在页面中使用路由元信息：

```javascript
import { useRoute } from 'vue-router'

const route = useRoute()

// 获取页面标题
const pageTitle = route.meta.title || '默认标题'

// 获取页面图标
const pageIcon = route.meta.icon

// 检查权限
const hasPermission = computed(() => {
  return userStore.hasPermission(route.meta.permission)
})
```

## 完整配置流程

### 步骤 1：创建页面组件

在 `/frontend/src/views/` 下创建新的页面组件：

```vue
<template>
  <div>
    <h1>新页面</h1>
  </div>
</template>

<script setup>
// 页面逻辑
</script>

<style scoped>
/* 页面样式 */
</style>
```

### 步骤 2：配置组件映射

在 `/frontend/src/utils/dynamic-routes.js` 中添加组件映射：

```javascript
const componentMap = {
  // ... 现有映射
  '/views/new/NewPage.vue': () => import('@/views/new/NewPage.vue')
}
```

### 步骤 3：配置图标映射（可选）

如果需要使用图标，在 `/frontend/src/layout/Layout.vue` 中：

1. 引入图标组件：

```javascript
import { NewIcon } from '@element-plus/icons-vue'
```

2. 添加图标映射：

```javascript
const iconMap = {
  // ... 现有映射
  'NewIcon': NewIcon
}
```

### 步骤 4：后端添加菜单数据

在数据库中添加菜单数据：

```sql
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status)
VALUES (0, 1, '新页面', '/new/page', '/views/new/NewPage.vue', 'new:list', 'NewIcon', 10, 1, 1);
```

### 步骤 5：关联角色菜单

为角色分配菜单权限：

```sql
-- 为管理员角色分配新菜单
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, id FROM sys_menu WHERE path = '/new/page';
```

### 步骤 6：测试

1. 重新登录系统
2. 检查侧边栏是否显示新菜单
3. 点击菜单，检查页面是否正常加载

## 常见问题

### 1. 页面显示 404

**可能原因：**
- 组件映射表中没有配置
- 组件路径不正确
- 组件文件不存在

**解决方案：**
- 检查 `componentMap` 中是否有对应配置
- 检查组件路径是否��确
- 检查组件文件是否存在

### 2. 图标不显示

**可能原因：**
- 图标映射表中没有配置
- 图标名称不正确
- 图标组件未引入

**解决方案：**
- 检查 `iconMap` 中是否有对应配置
- 检查图标名称是否正确
- 检查是否引入了图标组件

### 3. 菜单不显示

**可能原因：**
- 菜单的 `visible` 字段为 0
- 菜单的 `status` 字段为 0
- 用户角色没有关联该菜单

**解决方案：**
- 检查菜单的 `visible` 和 `status` 字段
- 检查角色菜单关联是否正确

## 最佳实践

1. **组件命名规范**：使用 PascalCase，如 `UserManagement.vue`
2. **组件路径规范**：以 `/views/` 开头，使用相对路径
3. **图标命名规范**：使用 Element Plus 图标名称
4. **权限标识规范**：使用 `模块:操作` 格式，如 `user:add`
5. **路由路径规范**：使用小写字母和连字符，如 `/user-management`

## 总结

通过合理配置组件映射表和图标映射表，可以实现灵活的动态路由系统。当添加新功能时，只需：

1. 创建页面组件
2. 配置组件映射
3. 配置图标映射（可选）
4. 后端添加菜单数据
5. 关联角色菜单

即可完成新功能的路由配置，无需修改前端路由代码。