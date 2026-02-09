# AdminPlus 数据库初始化指南

## 概述

AdminPlus 使用 PostgreSQL 16+ 作为数据库，本文档提供完整的数据库初始化步骤。

## 初始化步骤

### 方式一：一键初始化（推荐）

```bash
# Docker 环境
docker exec -i adminplus-postgres psql -U postgres < docs/init_complete.sql

# 本地环境
psql -U postgres -h localhost -p 5432 -d postgres < docs/init_complete.sql
```

**说明：**
- `init_complete.sql` 包含完整的数据库初始化脚本
- 自动创建数据库、表结构、索引、触发器
- 插入所有初始数据（用户、角色、菜单、部门等）

### 方式二：分步初始化

如果您需要更细粒度的控制，可以分别执行以下脚本：

#### 1. 创建数据库和基础表

```bash
# 方式 1：使用 Docker 容器执行
docker exec -i adminplus-postgres psql -U postgres < docs/init.sql

# 方式 2：本地连接数据库
psql -U postgres -h localhost -p 5432 -d postgres < docs/init.sql
```

**说明：**
- 创建 `adminplus` 数据库
- 创建所有基础表（用户、角色、菜单、字典、日志等）
- 插入初始管理员账号（用户名：`admin`，密码：`admin123`）
- 创建索引和触发器

#### 2. 初始化菜单数据

```bash
# 使用 Docker 容器执行
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_menus.sql

# 本地连接数据库
psql -U postgres -h localhost -p 5432 -d adminplus < docs/init_menus.sql
```

**说明：**
- 插入完整的菜单树形结构
- 插入按钮权限（用于权限控制）
- 为超级管理员角色分配所有菜单权限

#### 3. 初始化部门管理功能

```bash
# 方式 1：创建部门表
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_dept.sql

# 方式 2：添加部门管理菜单权限
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_dept_menu.sql
```

**说明：**
- 创建 `sys_dept` 表
- 插入 7 个初始部门（总部、技术研发部、市场运营部等）
- 为超级管理员角色分配部门管理权限

## 完整初始化脚本（一键执行）

```bash
# Docker 环境
docker exec -i adminplus-postgres psql -U postgres < docs/init.sql
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_menus.sql
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_dept.sql
docker exec -i adminplus-postgres psql -U postgres -d adminplus < docs/init_dept_menu.sql

# 本地环境
psql -U postgres -h localhost -p 5432 -d postgres < docs/init.sql
psql -U postgres -h localhost -p 5432 -d adminplus < docs/init_menus.sql
psql -U postgres -h localhost -p 5432 -d adminplus < docs/init_dept.sql
psql -U postgres -h localhost -p 5432 -d adminplus < docs/init_dept_menu.sql
```

## 验证初始化结果

### 检查表结构

```sql
-- 查看所有表
\dt

-- 查看表结构
\d sys_user
\d sys_role
\d sys_menu
\d sys_dept
```

### 检查初始数据

```sql
-- 检查管理员用户
SELECT id, username, nickname, email, phone, status FROM sys_user WHERE username = 'admin';

-- 检查角色
SELECT id, code, name, status FROM sys_role;

-- 检查菜单
SELECT id, parent_id, type, name, path, component, sort_order FROM sys_menu ORDER BY sort_order;

-- 检查部门
SELECT id, name, code, parent_id, sort_order FROM sys_dept ORDER BY sort_order;

-- 检查用户角色关联
SELECT u.username, r.code, r.name
FROM sys_user u
JOIN sys_user_role ur ON u.id = ur.user_id
JOIN sys_role r ON ur.role_id = r.id;
```

## 默认账号信息

| 用户名 | 密码 | 角色 | 权限 |
|--------|------|------|------|
| admin | admin123 | 超级管理员 | 所有权限 |

⚠️ **重要：生产环境请立即修改管理员密码！**

## 表结构说明

### 核心表

#### sys_user（用户表）
```sql
CREATE TABLE sys_user (
    id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,      -- 用户名
    password TEXT NOT NULL,              -- 密码（BCrypt 加密）
    nickname TEXT,                       -- 昵称
    email TEXT,                          -- 邮箱
    phone TEXT,                          -- 手机号
    avatar TEXT,                         -- 头像
    status INTEGER NOT NULL DEFAULT 1,   -- 状态（1=正常，0=禁用）
    settings JSONB,                      -- 配置（JSONB 类型）
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);
```

#### sys_role（角色表）
```sql
CREATE TABLE sys_role (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,           -- 角色编码（如 ROLE_ADMIN）
    name TEXT NOT NULL,                  -- 角色名称
    description TEXT,                    -- 描述
    data_scope INTEGER NOT NULL DEFAULT 1, -- 数据权限范围
    status INTEGER NOT NULL DEFAULT 1,   -- 状态（1=正常，0=禁用）
    sort_order INTEGER,                  -- 排序
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);
```

#### sys_menu（菜单表）
```sql
CREATE TABLE sys_menu (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,                    -- 父菜单ID
    type INTEGER NOT NULL,               -- 类型（0=目录，1=菜单，2=按钮）
    name TEXT NOT NULL,                  -- 菜单名称
    path TEXT,                           -- 路由路径
    component TEXT,                      -- 组件路径
    perm_key TEXT,                       -- 权限标识符（如 user:add）
    icon TEXT,                           -- 图标
    sort_order INTEGER,                  -- 排序
    visible INTEGER NOT NULL DEFAULT 1,  -- 是否可见（1=显示，0=隐藏）
    status INTEGER NOT NULL DEFAULT 1,   -- 状态（1=正常，0=禁用）
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);
```

#### sys_dept（部门表）
```sql
CREATE TABLE sys_dept (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,                    -- 父部门ID
    name TEXT NOT NULL,                  -- 部门名称
    code TEXT,                           -- 部门编码
    leader TEXT,                         -- 负责人
    phone TEXT,                          -- 联系电话
    email TEXT,                          -- 邮箱
    sort_order INTEGER,                  -- 排序
    status INTEGER NOT NULL DEFAULT 1,   -- 状态（1=正常，0=禁用）
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);
```

### 关联表

#### sys_user_role（用户-角色关联表）
```sql
CREATE TABLE sys_user_role (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,             -- 用户ID
    role_id BIGINT NOT NULL,             -- 角色ID
    UNIQUE(user_id, role_id)
);
```

#### sys_role_menu（角色-菜单关联表）
```sql
CREATE TABLE sys_role_menu (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT NOT NULL,             -- 角色ID
    menu_id BIGINT NOT NULL,             -- 菜单ID
    UNIQUE(role_id, menu_id)
);
```

### 其他表

- `sys_dict`（字典表）
- `sys_dict_item`（字典项表）
- `sys_log`（操作日志表）

## 数据权限范围说明

| 值 | 说明 |
|----|------|
| 1  | 全部数据 |
| 2  | 本部门数据 |
| 3  | 本部门及以下数据 |
| 4  | 仅本人数据 |

## 菜单类型说明

| 值 | 说明 | 是否生成路由 |
|----|------|-------------|
| 0  | 目录 | 是 |
| 1  | 菜单 | 是 |
| 2  | 按钮 | 否（仅用于权限控制） |

## 常见问题

### 1. 密码加密方式

AdminPlus 使用 BCrypt 加密算法，默认管理员密码 `admin123` 的加密结果为：
```
$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH
```

### 2. 修改管理员密码

```sql
-- 生成 BCrypt 密码（在 Java 代码中）
String encodedPassword = passwordEncoder.encode("new_password");

-- 更新密码
UPDATE sys_user SET password = '$2a$10$...' WHERE username = 'admin';
```

### 3. 重置数据库

```bash
# 删除所有表
docker exec -i adminplus-postgres psql -U postgres -d adminplus << EOF
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
EOF

# 重新初始化
docker exec -i adminplus-postgres psql -U postgres < docs/init.sql
```

### 4. 备份数据库

```bash
# 备份
docker exec adminplus-postgres pg_dump -U postgres adminplus > backup.sql

# 恢复
docker exec -i adminplus-postgres psql -U postgres adminplus < backup.sql
```

## 数据库版本要求

- PostgreSQL 16+
- 推荐使用 PostgreSQL 16 Alpine 版本（Docker 镜像）

## 相关文档

- [AdminPlus 开发规范](./开发规范.md)
- [API 文档](http://localhost:8081/api/swagger-ui.html)
- [README.md](../README.md)