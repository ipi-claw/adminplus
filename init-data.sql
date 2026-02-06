-- AdminPlus 初始化数据脚本
-- 用于测试角色管理和菜单管理功能

-- ==================== 角色数据 ====================
INSERT INTO sys_role (code, name, description, data_scope, status, sort_order, create_time, update_time, deleted)
VALUES
('ROLE_ADMIN', '超级管理员', '拥有系统所有权限', 1, 1, 1, NOW(), NOW(), false),
('ROLE_USER', '普通用户', '拥有基本用户权限', 4, 1, 2, NOW(), NOW(), false),
('ROLE_MANAGER', '部门经理', '拥有部门管理权限', 2, 1, 3, NOW(), NOW(), false);

-- ==================== 菜单数据 ====================
-- 系统管理（目录）
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES (NULL, 0, '系统管理', '/system', NULL, NULL, 'Setting', 1, 1, 1, NOW(), NOW());

-- 获取刚插入的系统管理菜单ID
SET @system_menu_id = LAST_INSERT_ID();

-- 用户管理（菜单）
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES (@system_menu_id, 1, '用户管理', '/system/user', 'system/User', 'system:user:list', 'User', 1, 1, 1, NOW(), NOW());
SET @user_menu_id = LAST_INSERT_ID();

-- 用户管理按钮权限
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES
(@user_menu_id, 2, '用户新增', NULL, NULL, 'system:user:add', NULL, 1, 0, 1, NOW(), NOW()),
(@user_menu_id, 2, '用户编辑', NULL, NULL, 'system:user:edit', NULL, 2, 0, 1, NOW(), NOW()),
(@user_menu_id, 2, '用户删除', NULL, NULL, 'system:user:delete', NULL, 3, 0, 1, NOW(), NOW()),
(@user_menu_id, 2, '用户查询', NULL, NULL, 'system:user:query', NULL, 4, 0, 1, NOW(), NOW()),
(@user_menu_id, 2, '分配角色', NULL, NULL, 'system:user:assign', NULL, 5, 0, 1, NOW(), NOW());

-- 角色管理（菜单）
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES (@system_menu_id, 1, '角色管理', '/system/role', 'system/Role', 'system:role:list', 'UserFilled', 2, 1, 1, NOW(), NOW());
SET @role_menu_id = LAST_INSERT_ID();

-- 角色管理按钮权限
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES
(@role_menu_id, 2, '角色新增', NULL, NULL, 'system:role:add', NULL, 1, 0, 1, NOW(), NOW()),
(@role_menu_id, 2, '角色编辑', NULL, NULL, 'system:role:edit', NULL, 2, 0, 1, NOW(), NOW()),
(@role_menu_id, 2, '角色删除', NULL, NULL, 'system:role:delete', NULL, 3, 0, 1, NOW(), NOW()),
(@role_menu_id, 2, '角色查询', NULL, NULL, 'system:role:query', NULL, 4, 0, 1, NOW(), NOW()),
(@role_menu_id, 2, '分配权限', NULL, NULL, 'system:role:assign', NULL, 5, 0, 1, NOW(), NOW());

-- 菜单管理（菜单）
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES (@system_menu_id, 1, '菜单管理', '/system/menu', 'system/Menu', 'system:menu:list', 'Menu', 3, 1, 1, NOW(), NOW());
SET @menu_menu_id = LAST_INSERT_ID();

-- 菜单管理按钮权限
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES
(@menu_menu_id, 2, '菜单新增', NULL, NULL, 'system:menu:add', NULL, 1, 0, 1, NOW(), NOW()),
(@menu_menu_id, 2, '菜单编辑', NULL, NULL, 'system:menu:edit', NULL, 2, 0, 1, NOW(), NOW()),
(@menu_menu_id, 2, '菜单删除', NULL, NULL, 'system:menu:delete', NULL, 3, 0, 1, NOW(), NOW()),
(@menu_menu_id, 2, '菜单查询', NULL, NULL, 'system:menu:query', NULL, 4, 0, 1, NOW(), NOW());

-- Dashboard（菜单）
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time)
VALUES (NULL, 1, '首页', '/dashboard', 'Dashboard', 'dashboard:view', 'HomeFilled', 0, 1, 1, NOW(), NOW());

-- ==================== 为超级管理员分配所有菜单权限 ====================
-- 获取所有菜单ID
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 1, id FROM sys_menu;

-- ==================== 为管理员用户分配角色 ====================
-- 假设已经存在一个 admin 用户，为其分配超级管理员角色
-- 如果不存在，需要先创建用户
-- INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

-- 查看初始化数据
SELECT '角色数据：' AS info;
SELECT id, code, name, description, data_scope, status, sort_order FROM sys_role;

SELECT '菜单数据（前10条）：' AS info;
SELECT id, parent_id, type, name, path, component, perm_key, sort_order, visible, status FROM sys_menu ORDER BY sort_order LIMIT 10;

SELECT '角色-菜单关联数据（前10条）：' AS info;
SELECT id, role_id, menu_id FROM sys_role_menu LIMIT 10;