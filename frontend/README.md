# AdminPlus 前端项目

基于 Vue 3 + Element Plus 的全栈 RBAC 管理系统前端项目。

## 技术栈

- Vue 3.5
- Vue Router 4
- Pinia 2.2
- Axios 1.7
- Element Plus 2.8
- Vite 6.0

## 快速开始

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:5173

默认账号：`admin`
默认密码：`admin123`

### 生产构建

```bash
npm run build
```

构建产物在 `dist` 目录

### 预览构建结果

```bash
npm run preview
```

## 项目结构

```
src/
├── api/              # API 接口
│   ├── auth.js       # 认证接口
│   ├── user.js       # 用户接口
│   ├── role.js       # 角色接口
│   ├── menu.js       # 菜单接口
│   ├── dict.js       # 字典接口
│   └── dashboard.js  # 仪表盘接口
├── assets/           # 静态资源
├── components/       # 公共组件
├── directives/       # 自定义指令
│   ├── auth.js       # 权限指令
│   └── index.js      # 指导出
├── layout/           # 布局组件
│   └── Layout.vue    # 主布局
├── router/           # 路由配置
│   └── index.js      # 路由定义
├── stores/           # 状态管理
│   ├── user.js       # 用户状态
│   └── dict.js       # 字典状态
├── utils/            # 工具函数
│   ├── request.js    # 请求封装
│   ├── debounce.js   # 防抖
│   ├── throttle.js   # 节流
│   └── index.js      # 通用工具
├── views/            # 页面组件
│   ├── auth/
│   │   └── Login.vue # 登录页
│   ├── Dashboard.vue # 仪表盘
│   └── system/       # 系统管理
│       ├── User.vue  # 用户管理
│       ├── Role.vue  # 角色管理
│       ├── Menu.vue  # 菜单管理
│       ├── Dict.vue  # 字典管理
│       └── DictItem.vue # 字典项管理
├── App.vue           # 根组件
└── main.js           # 入口文件
```

## 功能模块

### 1. 认证模块
- 用户登录
- 退出登录
- JWT Token 认证

### 2. 用户管理
- 用户列表（分页、搜索）
- 新增/编辑/删除用户
- 启用/禁用用户
- 分配角色

### 3. 角色管理
- 角色列表
- 新增/编辑/删除角色
- 数据权限配置
- 分配菜单权限

### 4. 菜单管理
- 菜单树形展示
- 新增/编辑/删除菜单
- 支持目录、菜单、按钮类型
- 菜单排序、图标配置

### 5. 字典管理
- 字典列表（分页、搜索）
- 新增/编辑/删除字典
- 字典项管理
- 启用/禁用字典

### 6. 仪表盘
- 统计数据展示
- 系统信息概览

## 权限控制

### 指令方式

```vue
<el-button v-auth="'user:add'">新增用户</el-button>
```

### Store 方法

```javascript
import { useUserStore } from '@/stores/user'

const userStore = useUserStore()

// 检查单个权限
userStore.hasPermission('user:add')

// 检查任意权限
userStore.hasAnyPermission(['user:add', 'user:edit'])

// 检查所有权限
userStore.hasAllPermissions(['user:add', 'user:edit'])
```

## API 接口

### 基础配置

- 开发环境：`http://localhost:8080`
- 生产环境：`/api`（通过 Nginx 代理）

### 统一响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {}
}
```

### 认证头

```
Authorization: Bearer {token}
```

## 环境配置

### 开发环境 (.env.development)

```
VITE_API_BASE_URL=http://localhost:8080
```

### 生产环境 (.env.production)

```
VITE_API_BASE_URL=/api
```

## Docker 部署

### 构建镜像

```bash
docker build -t adminplus-frontend .
```

### 运行容器

```bash
docker run -d -p 80:80 --name adminplus-frontend adminplus-frontend
```

## 开发规范

### 组件命名

- 使用 PascalCase 命名组件文件
- 组件内部使用 kebab-case 引用

### API 调用

所有 API 调用统一使用 `src/api/` 目录下的接口方法。

### 状态管理

使用 Pinia 进行状态管理，支持 LocalStorage 持久化。

### 样式规范

- 使用 scoped 样式避免污染
- 优先使用 Element Plus 内置样式

## 常见问题

### 1. 登录后跳转失败

检查路由守卫配置和 token 存储。

### 2. API 请求失败

检查后端服务是否启动，以及 API 地址配置是否正确。

### 3. 权限指令不生效

确保用户已登录，并且 permissions 数组包含对应权限。

### 4. 菜单不显示

检查用户角色是否已分配对应的菜单权限。

## 更新日志

### v1.0.0 (2025-02-07)

- ✅ 完成所有核心功能模块
- ✅ 用户管理、角色管理、菜单管理、字典管理
- ✅ 权限控制系统
- ✅ 美观的用户界面
- ✅ 生产环境构建成功

## 联系方式

如有问题，请提交 Issue 或联系开发团队。

## 许可证

MIT License