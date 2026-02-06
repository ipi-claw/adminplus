-- AdminPlus 数据库初始化脚本
-- PostgreSQL 16+

-- 创建数据库
CREATE DATABASE IF NOT EXISTS adminplus;

-- 切换到 adminplus 数据库
\c adminplus;

-- 删除已存在的表（按依赖关系倒序）
DROP TABLE IF EXISTS sys_role_menu CASCADE;
DROP TABLE IF EXISTS sys_user_role CASCADE;
DROP TABLE IF EXISTS sys_menu CASCADE;
DROP TABLE IF EXISTS sys_role CASCADE;
DROP TABLE IF EXISTS sys_user CASCADE;

-- 创建用户表
CREATE TABLE sys_user (
    id BIGSERIAL PRIMARY KEY,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    nickname TEXT,
    email TEXT,
    phone TEXT,
    avatar TEXT,
    status INTEGER NOT NULL DEFAULT 1,
    settings JSONB,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- 创建角色表
CREATE TABLE sys_role (
    id BIGSERIAL PRIMARY KEY,
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    data_scope INTEGER NOT NULL DEFAULT 1,
    status INTEGER NOT NULL DEFAULT 1,
    sort_order INTEGER,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- 创建菜单表
CREATE TABLE sys_menu (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,
    type INTEGER NOT NULL,
    name TEXT NOT NULL,
    path TEXT,
    component TEXT,
    perm_key TEXT,
    icon TEXT,
    sort_order INTEGER,
    visible INTEGER NOT NULL DEFAULT 1,
    status INTEGER NOT NULL DEFAULT 1,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- 创建用户-角色关联表
CREATE TABLE sys_user_role (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    UNIQUE(user_id, role_id)
);

-- 创建角色-菜单关联表
CREATE TABLE sys_role_menu (
    id BIGSERIAL PRIMARY KEY,
    role_id BIGINT NOT NULL,
    menu_id BIGINT NOT NULL,
    UNIQUE(role_id, menu_id)
);

-- 创建索引
CREATE INDEX idx_sys_user_username ON sys_user(username);
CREATE INDEX idx_sys_user_status ON sys_user(status);
CREATE INDEX idx_sys_role_code ON sys_role(code);
CREATE INDEX idx_sys_menu_parent_id ON sys_menu(parent_id);
CREATE INDEX idx_sys_menu_type ON sys_menu(type);
CREATE INDEX idx_sys_user_role_user_id ON sys_user_role(user_id);
CREATE INDEX idx_sys_user_role_role_id ON sys_user_role(role_id);
CREATE INDEX idx_sys_role_menu_role_id ON sys_role_menu(role_id);
CREATE INDEX idx_sys_role_menu_menu_id ON sys_role_menu(menu_id);

-- 插入初始数据

-- 插入管理员角色
INSERT INTO sys_role (code, name, description, data_scope, status, sort_order)
VALUES ('ROLE_ADMIN', '超级管理员', '拥有所有权限', 1, 1, 1);

-- 插入管理员用户（密码: admin123，BCrypt 加密）
INSERT INTO sys_user (username, password, nickname, email, phone, status)
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', '超级管理员', 'admin@adminplus.com', '13800138000', 1);

-- 关联管理员用户和管理员角色
INSERT INTO sys_user_role (user_id, role_id)
SELECT u.id, r.id FROM sys_user u, sys_role r
WHERE u.username = 'admin' AND r.code = 'ROLE_ADMIN';

-- 插入系统菜单
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status) VALUES
-- 系统管理模块
(NULL, 0, '系统管理', '/system', NULL, NULL, 'Setting', 1, 1, 1),

-- 用户管理
((SELECT id FROM sys_menu WHERE name = '系统管理'), 1, '用户管理', '/system/user', 'system/user/index', NULL, 'User', 1, 1, 1),
((SELECT id FROM sys_menu WHERE name = '用户管理'), 2, '新增用户', NULL, NULL, 'user:add', NULL, 1, 0, 1),
((SELECT id FROM sys_menu WHERE name = '用户管理'), 2, '编辑用户', NULL, NULL, 'user:edit', NULL, 2, 0, 1),
((SELECT id FROM sys_menu WHERE name = '用户管理'), 2, '删除用户', NULL, NULL, 'user:delete', NULL, 3, 0, 1),

-- 角色管理
((SELECT id FROM sys_menu WHERE name = '系统管理'), 1, '角色管理', '/system/role', 'system/role/index', NULL, 'UserFilled', 2, 1, 1),
((SELECT id FROM sys_menu WHERE name = '角色管理'), 2, '新增角色', NULL, NULL, 'role:add', NULL, 1, 0, 1),
((SELECT id FROM sys_menu WHERE name = '角色管理'), 2, '编辑角色', NULL, NULL, 'role:edit', NULL, 2, 0, 1),
((SELECT id FROM sys_menu WHERE name = '角色管理'), 2, '删除角色', NULL, NULL, 'role:delete', NULL, 3, 0, 1),
((SELECT id FROM sys_menu WHERE name = '角色管理'), 2, '分配权限', NULL, NULL, 'role:assign', NULL, 4, 0, 1),

-- 菜单管理
((SELECT id FROM sys_menu WHERE name = '系统管理'), 1, '菜单管理', '/system/menu', 'system/menu/index', NULL, 'Menu', 3, 1, 1),
((SELECT id FROM sys_menu WHERE name = '菜单管理'), 2, '新增菜单', NULL, NULL, 'menu:add', NULL, 1, 0, 1),
((SELECT id FROM sys_menu WHERE name = '菜单管理'), 2, '编辑菜单', NULL, NULL, 'menu:edit', NULL, 2, 0, 1),
((SELECT id FROM sys_menu WHERE name = '菜单管理'), 2, '删除菜单', NULL, NULL, 'menu:delete', NULL, 3, 0, 1);

-- 为管理员角色分配所有菜单权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.id, m.id FROM sys_role r, sys_menu m
WHERE r.code = 'ROLE_ADMIN';

-- 创建更新时间触发器
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.update_time = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 为所有表添加触发器
CREATE TRIGGER update_sys_user_updated_at BEFORE UPDATE ON sys_user
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sys_role_updated_at BEFORE UPDATE ON sys_role
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sys_menu_updated_at BEFORE UPDATE ON sys_menu
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON TABLE sys_user IS '用户表';
COMMENT ON TABLE sys_role IS '角色表';
COMMENT ON TABLE sys_menu IS '菜单表';
COMMENT ON TABLE sys_user_role IS '用户-角色关联表';
COMMENT ON TABLE sys_role_menu IS '角色-菜单关联表';

COMMENT ON COLUMN sys_user.username IS '用户名';
COMMENT ON COLUMN sys_user.password IS '密码（BCrypt 加密）';
COMMENT ON COLUMN sys_user.nickname IS '昵称';
COMMENT ON COLUMN sys_user.email IS '邮箱';
COMMENT ON COLUMN sys_user.phone IS '手机号';
COMMENT ON COLUMN sys_user.avatar IS '头像';
COMMENT ON COLUMN sys_user.status IS '状态（1=正常，0=禁用）';
COMMENT ON COLUMN sys_user.settings IS '配置（JSONB 类型）';

COMMENT ON COLUMN sys_role.code IS '角色编码（如 ROLE_ADMIN）';
COMMENT ON COLUMN sys_role.name IS '角色名称';
COMMENT ON COLUMN sys_role.description IS '描述';
COMMENT ON COLUMN sys_role.data_scope IS '数据权限范围（1=全部，2=本部门，3=本部门及以下，4=仅本人）';
COMMENT ON COLUMN sys_role.status IS '状态（1=正常，0=禁用）';
COMMENT ON COLUMN sys_role.sort_order IS '排序';

COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID';
COMMENT ON COLUMN sys_menu.type IS '类型（0=目录，1=菜单，2=按钮）';
COMMENT ON COLUMN sys_menu.name IS '菜单名称';
COMMENT ON COLUMN sys_menu.path IS '路由路径';
COMMENT ON COLUMN sys_menu.component IS '组件路径';
COMMENT ON COLUMN sys_menu.perm_key IS '权限标识符（如 user:add）';
COMMENT ON COLUMN sys_menu.icon IS '图标';
COMMENT ON COLUMN sys_menu.sort_order IS '排序';
COMMENT ON COLUMN sys_menu.visible IS '是否可见（1=显示，0=隐藏）';
COMMENT ON COLUMN sys_menu.status IS '状态（1=正常，0=禁用）';