# AdminPlus 动态路由系统 - 快速入门指南

## 5 分钟快速开始

### 第 1 步：初始化菜单数据

执行 SQL 脚本，初始化菜单数据：

```bash
psql -U adminplus -d adminplus -f /root/.openclaw/workspace/AdminPlus/docs/init_menus.sql
```

### 第 2 步：启动后端服务

```bash
cd /root/.openclaw/workspace/AdminPlus/backend
mvn spring-boot:run
```

### 第 3 步：启动前端服务

```bash
cd /root/.openclaw/workspace/AdminPlus/frontend
npm run dev
```

### 第 4 步：登录系统

打开浏览器，访问 `http://localhost:5173`，使用管理员账号登录：

- 用户名：`admin`
- 密码：`admin123`

### 第 5 步：体验动态路由

登录后，你会看到侧边栏显示的菜单是动态加载的，根据你的角色权限显示不同的菜单。

## 添加新页面

### 示例：添加"日志管理"页面

#### 1. 创建页面组件

在 `/frontend/src/views/system/` 下创建 `Log.vue`：

```vue
<template>
  <div class="log-container">
    <el-card>
      <template #header>
        <span>日志管理</span>
      </template>
      <p>日志管理功能开发中...</p>
    </el-card>
  </div>
</template>

<script setup>
// 页面逻辑
</script>

<style scoped>
.log-container {
  padding: 20px;
}
</style>
```

#### 2. 配置组件映射

在 `/frontend/src/utils/dynamic-routes.js` 的 `componentMap` 中添加：

```javascript
const componentMap = {
  // ... 现有映射
  '/views/system/Log.vue': () => import('@/views/system/Log.vue')
}
```

#### 3. 后端添加菜单数据

在数据库中添加菜单：

```sql
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted)
VALUES (2, 1, '日志管理', '/system/log', '/views/system/Log.vue', 'log:list', 'Document', 5, 1, 1, NOW(), NOW(), 0);
```

#### 4. 关联角色菜单

为管理员角色分配菜单：

```sql
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, id FROM sys_menu WHERE path = '/system/log';
```

#### 5. 重新登录

退出登录，重新登录后，侧边栏会显示"日志管理"菜单。

## 常用命令

### 后端

```bash
# 编译后端
mvn clean compile

# 运行后端
mvn spring-boot:run

# 打包后端
mvn clean package
```

### 前端

```bash
# 安装依赖
npm install

# 运行开发服务器
npm run dev

# 构建生产版本
npm run build
```

### 数据库

```bash
# 连接数据库
psql -U adminplus -d adminplus

# 查询菜单
SELECT * FROM sys_menu WHERE deleted = 0 ORDER BY sort_order;

# 查询角色菜单关联
SELECT rm.*, r.name AS role_name, m.name AS menu_name
FROM sys_role_menu rm
JOIN sys_role r ON rm.role_id = r.id
JOIN sys_menu m ON rm.menu_id = m.id
WHERE r.deleted = 0 AND m.deleted = 0;
```

## 常见问题

### Q: 菜单不显示？

**A:** 检查以下几点：
1. 菜单的 `visible` 字段是否为 1
2. 菜单的 `status` 字段是否为 1
3. 用户角色是否关联了该菜单
4. 组件路径是否正确

### Q: 页面 404？

**A:** 检查以下几点：
1. 组件映射表中是否配置了该组件
2. 组件文件是否存在
3. 组件路径是否正确

### Q: 图标不显示？

**A:** 检查以下几点：
1. 图标映射表中是否配置了该图标
2. 图标名称是否正确
3. 图标组件是否引入

## 调试技巧

### 1. 查看路由配置

在浏览器控制台执行：

```javascript
console.log(router.getRoutes())
```

### 2. 查看菜单数据

在浏览器控制台执行：

```javascript
getUserMenuTree().then(data => console.log(data))
```

### 3. 查看用户权限

在浏览器控制台执行：

```javascript
console.log(userStore.permissions)
```

### 4. 查看路由加载状态

在浏览器控制台执行：

```javascript
console.log(userStore.hasLoadedRoutes)
```

## 下一步

- 阅读 `/docs/DYNAMIC_ROUTES.md` 了解详细的架构设计
- 阅读 `/docs/FRONTEND_CONFIG.md` 了解前端配置方法
- 阅读 `/docs/TESTING_GUIDE.md` 了解测试方法

## 获取帮助

如有问题，请查看：
- `/docs/DYNAMIC_ROUTES.md` - 动态路由系统文档
- `/docs/FRONTEND_CONFIG.md` - 前端配置指南
- `/docs/TESTING_GUIDE.md` - 测试指南

---

**版本：** 1.0.0
**更新日期：** 2026-02-08