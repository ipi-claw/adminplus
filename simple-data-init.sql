-- 简化版本的数据初始化脚本 - 适配实际表结构

-- 清除现有数据
DELETE FROM sys_user_role;
DELETE FROM sys_role_menu;
DELETE FROM sys_user;
DELETE FROM sys_role;
DELETE FROM sys_menu;
DELETE FROM sys_dept;

-- ==================== 角色数据 ====================
INSERT INTO sys_role (id, code, name, description, data_scope, status, sort_order, create_time, update_time, deleted, create_user, update_user)
VALUES
('1', 'ROLE_ADMIN', '超级管理员', '拥有系统所有权限', 1, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('2', 'ROLE_MANAGER', '部门经理', '拥有部门管理权限', 2, 1, 2, NOW(), NOW(), false, 'system', 'system'),
('3', 'ROLE_USER', '普通用户', '拥有基本用户权限', 4, 1, 3, NOW(), NOW(), false, 'system', 'system'),
('4', 'ROLE_DEVELOPER', '开发人员', '拥有开发相关权限', 3, 1, 4, NOW(), NOW(), false, 'system', 'system'),
('5', 'ROLE_OPERATOR', '运营人员', '拥有运营相关权限', 4, 1, 5, NOW(), NOW(), false, 'system', 'system');

-- ==================== 部门数据 ====================
INSERT INTO sys_dept (id, parent_id, name, code, leader, phone, email, sort_order, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('1', NULL, 'AdminPlus 总部', 'HQ', '张三', '010-12345678', 'hq@adminplus.com', 1, 1, NOW(), NOW(), false, 'system', 'system'),
('2', '1', '技术研发部', 'RD', '李四', '010-12345679', 'rd@adminplus.com', 2, 1, NOW(), NOW(), false, 'system', 'system'),
('3', '1', '市场运营部', 'MK', '王五', '010-12345680', 'mk@adminplus.com', 3, 1, NOW(), NOW(), false, 'system', 'system'),
('4', '2', '后端开发组', 'BE', '赵六', '010-12345681', 'be@adminplus.com', 1, 1, NOW(), NOW(), false, 'system', 'system'),
('5', '2', '前端开发组', 'FE', '钱七', '010-12345682', 'fe@adminplus.com', 2, 1, NOW(), NOW(), false, 'system', 'system'),
('6', '3', '市场推广组', 'MP', '孙八', '010-12345683', 'mp@adminplus.com', 1, 1, NOW(), NOW(), false, 'system', 'system'),
('7', '3', '客户服务组', 'CS', '周九', '010-12345684', 'cs@adminplus.com', 2, 1, NOW(), NOW(), false, 'system', 'system');

-- ==================== 菜单数据 ====================
-- 首页
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('27', NULL, 1, '首页', '/dashboard', 'Dashboard', 'dashboard:view', 'HomeFilled', 0, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- 系统管理目录
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('1', NULL, 0, '系统管理', '/system', NULL, NULL, 'Setting', 1, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- 用户管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('2', '1', 1, '用户管理', '/system/user', 'system/User', 'system:user:list', 'User', 1, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('3', '2', 2, '新增用户', NULL, NULL, 'user:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('4', '2', 2, '编辑用户', NULL, NULL, 'user:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('5', '2', 2, '删除用户', NULL, NULL, 'user:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 角色管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('8', '1', 1, '角色管理', '/system/role', 'system/Role', 'system:role:list', 'Lock', 2, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('9', '8', 2, '新增角色', NULL, NULL, 'role:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('10', '8', 2, '编辑角色', NULL, NULL, 'role:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- ==================== 角色菜单关联数据 ====================
-- 超级管理员拥有所有权限
INSERT INTO sys_role_menu (id, menu_id, role_id) VALUES
('rm1', '27', '1'),
('rm2', '1', '1'),
('rm3', '2', '1'),
('rm4', '3', '1'),
('rm5', '4', '1'),
('rm6', '5', '1'),
('rm7', '8', '1'),
('rm8', '9', '1'),
('rm9', '10', '1');

-- 普通用户权限
INSERT INTO sys_role_menu (id, menu_id, role_id) VALUES
('rm10', '27', '3'),
('rm11', '1', '3'),
('rm12', '2', '3');

-- ==================== 用户数据 ====================
-- 密码均为：admin123 (BCrypt加密)
INSERT INTO sys_user (id, username, password, nickname, phone, email, status, create_time, update_time, deleted, create_user, update_user)
VALUES
('1', 'admin', '$2a$10$8Xv0hVJ3Q7KQ7KQ7KQ7KQO.8Xv0hVJ3Q7KQ7KQ7KQ7KQO', '超级管理员', '13800138001', 'admin@adminplus.com', 1, NOW(), NOW(), false, 'system', 'system'),
('2', 'user1', '$2a$10$8Xv0hVJ3Q7KQ7KQ7KQ7KQO.8Xv0hVJ3Q7KQ7KQ7KQ7KQO', '普通用户1', '13800138002', 'user1@adminplus.com', 1, NOW(), NOW(), false, 'system', 'system'),
('3', 'user2', '$2a$10$8Xv0hVJ3Q7KQ7KQ7KQ7KQO.8Xv0hVJ3Q7KQ7KQ7KQ7KQO', '普通用户2', '13800138003', 'user2@adminplus.com', 1, NOW(), NOW(), false, 'system', 'system');

-- ==================== 用户角色关联数据 ====================
INSERT INTO sys_user_role (id, user_id, role_id) VALUES
('ur1', '1', '1'),
('ur2', '2', '3'),
('ur3', '3', '3');

-- ==================== 数据统计 ====================
SELECT '角色数量：' AS info, COUNT(*) AS count FROM sys_role;
SELECT '菜单数量：' AS info, COUNT(*) AS count FROM sys_menu;
SELECT '用户数量：' AS info, COUNT(*) AS count FROM sys_user;
SELECT '部门数量：' AS info, COUNT(*) AS count FROM sys_dept;
SELECT '权限关联数量：' AS info, COUNT(*) AS count FROM sys_role_menu;
SELECT '用户角色关联数量：' AS info, COUNT(*) AS count FROM sys_user_role;