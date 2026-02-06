# AdminPlus 快速开始指南

## 项目概述
AdminPlus 是一个基于 Spring Boot + Vue 3 + Element Plus 的后台管理系统。

本次实现完成了以下功能模块：
- 角色管理
- 菜单管理
- 用户-角色关联
- 角色-菜单关联

---

## 环境要求

### 后端
- JDK 17+
- Maven 3.6+
- MySQL 8.0+

### 前端
- Node.js 18+
- npm 或 pnpm

---

## 快速启动

### 1. 数据库初始化

```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE adminplus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE adminplus;

# 执行初始化脚本（包含表结构和测试数据）
source /root/.openclaw/workspace/AdminPlus/init-data.sql;
```

### 2. 启动后端服务

```bash
cd /root/.openclaw/workspace/AdminPlus/backend

# 修改数据库配置（如果需要）
vim src/main/resources/application.yml

# 启动服务
mvn spring-boot:run

# 或者打包后运行
mvn clean package -DskipTests
java -jar target/adminplus-backend-1.0.0.jar
```

后端服务默认运行在 `http://localhost:8080`

Swagger UI: `http://localhost:8080/swagger-ui.html`

### 3. 启动前端服务

```bash
cd /root/.openclaw/workspace/AdminPlus/frontend

# 安装依赖（首次运行）
npm install

# 启动开发服务器
npm run dev
```

前端服务默认运行在 `http://localhost:5173`

---

## 功能测试

### 1. 角色管理

访问路径：`/system/role`

#### 测试步骤
1. 查看角色列表
2. 点击"新增角色"，填写表单并提交
3. 点击"编辑"，修改角色信息
4. 点击"分配权限"，为角色勾选菜单权限
5. 点击"删除"，删除角色

#### 预期结果
- 角色列表正常显示
- 新增、编辑、删除功能正常
- 分配权限对话框正常显示菜单树
- 权限分配成功

### 2. 菜单管理

访问路径：`/system/menu`

#### 测试步骤
1. 查看菜单树
2. 点击"新增菜单"，创建一级菜单
3. 点击"新增子菜单"，为某个菜单创建子菜单
4. 点击"编辑"，修改菜单信息
5. 点击"删除"，删除菜单（尝试删除有子菜单的菜单，应有提示）

#### 预期结果
- 菜单树正常显示
- 可以创建多级菜单
- 不同类型菜单（目录/菜单/按钮）表单字段不同
- 删除有子菜单的菜单时有错误提示

### 3. 用户-角色关联

访问路径：`/system/user`

#### 测试步骤
1. 查看用户列表，确认角色列正常显示
2. 点击"分配角色"按钮
3. 在对话框中勾选角色
4. 提交后查看用户角色是否更新

#### 预期结果
- 用户列表显示角色标签
- 分配角色对话框正常显示所有角色
- 用户已有角色默认选中
- 分配成功后用户角色更新

---

## API 接口文档

### 角色管理接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /sys/roles | 查询角色列表 |
| GET | /sys/roles/{id} | 根据ID查询角色 |
| POST | /sys/roles | 创建角色 |
| PUT | /sys/roles/{id} | 更新角色 |
| DELETE | /sys/roles/{id} | 删除角色 |
| PUT | /sys/roles/{id}/menus | 为角色分配菜单权限 |
| GET | /sys/roles/{id}/menus | 查询角色的菜单ID列表 |

### 菜单管理接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | /sys/menus/tree | 查询菜单树形列表 |
| GET | /sys/menus/{id} | 根据ID查询菜单 |
| POST | /sys/menus | 创建菜单 |
| PUT | /sys/menus/{id} | 更新菜单 |
| DELETE | /sys/menus/{id} | 删除菜单 |

### 用户-角色关联接口

| 方法 | 路径 | 描述 |
|------|------|------|
| PUT | /sys/users/{id}/roles | 为用户分配角色 |
| GET | /sys/users/{id}/roles | 查询用户的角色ID列表 |

---

## 默认测试数据

执行 `init-data.sql` 后，系统将包含以下数据：

### 角色
- 超级管理员 (ROLE_ADMIN) - 拥有所有权限
- 普通用户 (ROLE_USER) - 基本用户权限
- 部门经理 (ROLE_MANAGER) - 部门管理权限

### 菜单
- 系统管理（目录）
  - 用户管理（菜单 + 5个按钮权限）
  - 角色管理（菜单 + 5个按钮权限）
  - 菜单管理（菜单 + 4个按钮权限）
- 首页（菜单）

---

## 常见问题

### 1. 后端启动失败

**问题**: 数据库连接失败

**解决方案**:
- 检查 `application.yml` 中的数据库配置
- 确认 MySQL 服务已启动
- 确认数据库已创建

### 2. 前端启动失败

**问题**: 依赖安装失败

**解决方案**:
```bash
# 清除缓存重新安装
rm -rf node_modules package-lock.json
npm install
```

### 3. API 请求失败

**问题**: 跨域问题或 404 错误

**解决方案**:
- 确认后端服务已启动
- 检查前端 API 基础路径配置
- 检查后端 SecurityConfig 中的跨域配置

### 4. 菜单树不显示

**问题**: 菜单数据为空

**解决方案**:
- 确认已执行 `init-data.sql`
- 检查数据库 `sys_menu` 表是否有数据
- 检查浏览器控制台是否有错误

---

## 开发规范

### 后端
- DTO/VO 使用 `record` 类型
- Service 方法添加 `@Transactional` 注解
- 统一异常处理
- 统一响应格式

### 前端
- 使用 `<script setup>` 语法
- 使用 Composition API
- 使用 Element Plus 组件库
- 统一的 API 调用方式

---

## 项目结构

```
AdminPlus/
├── backend/                    # 后端项目
│   └── src/main/java/com/adminplus/
│       ├── controller/         # 控制器层
│       │   ├── AuthController.java
│       │   ├── UserController.java
│       │   ├── RoleController.java    # 新增
│       │   └── MenuController.java    # 新增
│       ├── service/            # 服务层
│       │   ├── AuthService.java
│       │   ├── UserService.java
│       │   ├── RoleService.java       # 新增
│       │   ├── MenuService.java       # 新增
│       │   └── impl/
│       │       ├── AuthServiceImpl.java
│       │       ├── UserServiceImpl.java
│       │       ├── RoleServiceImpl.java  # 新增
│       │       └── MenuServiceImpl.java  # 新增
│       ├── dto/                # 数据传输对象
│       │   ├── UserCreateReq.java
│       │   ├── UserUpdateReq.java
│       │   ├── UserLoginReq.java
│       │   ├── RoleCreateReq.java      # 新增
│       │   ├── RoleUpdateReq.java      # 新增
│       │   ├── MenuCreateReq.java      # 新增
│       │   └── MenuUpdateReq.java      # 新增
│       ├── vo/                 # 视图对象
│       │   ├── LoginResp.java
│       │   ├── UserVO.java
│       │   ├── RoleVO.java           # 新增
│       │   └── MenuVO.java           # 新增
│       ├── entity/             # 实体类
│       │   ├── UserEntity.java
│       │   ├── RoleEntity.java
│       │   ├── MenuEntity.java
│       │   ├── UserRoleEntity.java
│       │   └── RoleMenuEntity.java
│       ├── repository/         # 数据访问层
│       │   ├── UserRepository.java
│       │   ├── RoleRepository.java
│       │   ├── MenuRepository.java
│       │   ├── UserRoleRepository.java
│       │   └── RoleMenuRepository.java
│       └── config/             # 配置类
│           ├── SecurityConfig.java
│           └── OpenApiConfig.java
│
├── frontend/                   # 前端项目
│   └── src/
│       ├── api/                # API 接口
│       │   ├── auth.js
│       │   ├── user.js
│       │   ├── role.js         # 新增
│       │   └── menu.js         # 新增
│       ├── views/              # 页面组件
│       │   ├── Dashboard.vue
│       │   ├── auth/
│       │   │   └── Login.vue
│       │   └── system/
│       │       ├── User.vue
│       │       ├── Role.vue        # 新增
│       │       └── Menu.vue        # 新增
│       ├── stores/             # 状态管理
│       │   └── user.js
│       ├── layout/             # 布局组件
│       │   └── Layout.vue
│       ├── utils/              # 工具函数
│       │   └── request.js
│       └── App.vue
│
├── init-data.sql               # 初始化数据脚本
├── IMPLEMENTATION_SUMMARY.md   # 实现总结
└── QUICKSTART.md               # 快速开始指南
```

---

## 后续计划

1. **权限控制**: 添加接口级别的权限验证
2. **缓存优化**: 对菜单树等数据添加缓存
3. **操作日志**: 记录用户操作日志
4. **数据导入导出**: 支持批量导入导出
5. **前端优化**: 添加更多交互效果和动画

---

## 技术支持

如有问题，请查看：
- `IMPLEMENTATION_SUMMARY.md` - 详细的实现说明
- 后端 Swagger UI - API 接口文档
- 浏览器控制台 - 前端错误信息
- 后端日志 - 后端错误信息

---

**祝使用愉快！** 🎉