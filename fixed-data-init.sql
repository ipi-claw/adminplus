-- 固定数据初始化脚本 - 适配实际表结构

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
('5', '2', 2, '删除用户', NULL, NULL, 'user:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('6', '2', 2, '分配角色', NULL, NULL, 'user:assign', NULL, 4, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('7', '2', 2, '重置密码', NULL, NULL, 'user:reset', NULL, 5, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 角色管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('8', '1', 1, '角色管理', '/system/role', 'system/Role', 'system:role:list', 'UserFilled', 2, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('9', '8', 2, '新增角色', NULL, NULL, 'role:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('10', '8', 2, '编辑角色', NULL, NULL, 'role:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('11', '8', 2, '删除角色', NULL, NULL, 'role:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('12', '8', 2, '分配权限', NULL, NULL, 'role:assign', NULL, 4, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 菜单管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('13', '1', 1, '菜单管理', '/system/menu', 'system/Menu', 'system:menu:list', 'Menu', 3, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('14', '13', 2, '新增菜单', NULL, NULL, 'menu:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('15', '13', 2, '编辑菜单', NULL, NULL, 'menu:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('16', '13', 2, '删除菜单', NULL, NULL, 'menu:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 字典管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('17', '1', 1, '字典管理', '/system/dict', 'system/Dict', 'system:dict:list', 'Document', 4, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('18', '17', 2, '新增字典', NULL, NULL, 'dict:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('19', '17', 2, '编辑字典', NULL, NULL, 'dict:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('20', '17', 2, '删除字典', NULL, NULL, 'dict:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 部门管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('21', '1', 1, '部门管理', '/system/dept', 'system/Dept', 'system:dept:list', 'OfficeBuilding', 5, 1, 1, NOW(), NOW(), false, 'system', 'system'),
('22', '21', 2, '新增部门', NULL, NULL, 'dept:add', NULL, 1, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('23', '21', 2, '编辑部门', NULL, NULL, 'dept:edit', NULL, 2, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('24', '21', 2, '删除部门', NULL, NULL, 'dept:delete', NULL, 3, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('25', '21', 2, '查询部门', NULL, NULL, 'dept:query', NULL, 4, 0, 1, NOW(), NOW(), false, 'system', 'system'),
('26', '21', 2, '部门列表', NULL, NULL, 'dept:list', NULL, 5, 0, 1, NOW(), NOW(), false, 'system', 'system');

-- 参数配置菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('28', '1', 1, '参数配置', '/system/config', 'system/Config', 'system:config:list', 'Tools', 6, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- 数据分析目录
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('29', NULL, 0, '数据分析', '/analysis', NULL, NULL, 'DataLine', 2, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- 数据统计菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('30', '29', 1, '数据统计', '/analysis/statistics', 'analysis/Statistics', 'analysis:statistics:view', 'TrendCharts', 1, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- 报表管理菜单
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted, create_user, update_user)
VALUES ('31', '29', 1, '报表管理', '/analysis/report', 'analysis/Report', 'analysis:report:view', 'DataAnalysis', 2, 1, 1, NOW(), NOW(), false, 'system', 'system');

-- ==================== 用户数据 ====================
-- 使用BCrypt加密的密码（123456）
INSERT INTO sys_user (id, username, password, nickname, email, phone, avatar, status, create_time, update_time, deleted, create_user, update_user)
VALUES 
('1', 'admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '超级管理员', 'admin@adminplus.com', '13800138000', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('2', 'manager', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '部门经理', 'manager@adminplus.com', '13800138001', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('3', 'user1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '普通用户1', 'user1@adminplus.com', '13800138002', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('4', 'user2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '普通用户2', 'user2@adminplus.com', '13800138003', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('5', 'dev1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '开发人员1', 'dev1@adminplus.com', '13800138004', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('6', 'dev2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '开发人员2', 'dev2@adminplus.com', '13800138005', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('7', 'operator1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '运营人员1', 'operator1@adminplus.com', '13800138006', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('8', 'operator2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '运营人员2', 'operator2@adminplus.com', '13800138007', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('9', 'cs1', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '客服人员1', 'cs1@adminplus.com', '13800138008', NULL, 1, NOW(), NOW(), false, 'system', 'system'),
('10', 'cs2', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTV2UiC', '客服人员2', 'cs2@adminplus.com', '13800138009', NULL, 1, NOW(), NOW(), false, 'system', 'system');

-- ==================== 权限关联 ====================
-- 为超级管理员分配所有菜单权限
INSERT INTO sys_role_menu (role_id, menu_id, create_user, update_user)
SELECT '1', id, 'system', 'system' FROM sys_menu WHERE type != 2;

-- 部门经理权限
INSERT INTO sys_role_menu (role_id, menu_id, create_user, update_user)
VALUES 
('2', '27', 'system', 'system'),
('2', '2', 'system', 'system'),
('2', '3', 'system', 'system'),
('2', '4', 'system', 'system'),
('2', '5', 'system', 'system'),
('2', '6', 'system', 'system'),
('2', '7', 'system', 'system'),
('2', '21', 'system', 'system'),
('2', '22', 'system', 'system'),
('2', '23', 'system', 'system'),
('2', '24', 'system', 'system'),
('2', '25', 'system', 'system'),
('2', '26', 'system', 'system');

-- 开发人员权限
INSERT INTO sys_role_menu (role_id, menu_id, create_user, update_user)
VALUES 
('4', '27', 'system', 'system'),
('4', '2', 'system', 'system'),
('4', '8', 'system', 'system'),
('4', '13', 'system', 'system'),
('4', '17', 'system', 'system'),
('4', '28', 'system', 'system'),
('4', '30', 'system', 'system'),
('4', '31', 'system', 'system');

-- 运营人员权限
INSERT INTO sys_role_menu (role_id, menu_id, create_user, update_user)
VALUES 
('5', '27', 'system', 'system'),
('5', '30', 'system', 'system'),
('5', '31', 'system', 'system');

-- 普通用户权限
INSERT INTO sys_role_menu (role_id, menu_id, create_user, update_user)
VALUES ('3', '27', 'system', 'system');

-- 用户角色关联
INSERT INTO sys_user_role (user_id, role_id, create_user, update_user)
VALUES 
('1', '1', 'system', 'system'),
('2', '2', 'system', 'system'),
('3', '3', 'system', 'system'),
('4', '3', 'system', 'system'),
('5', '4', 'system', 'system'),
('6', '4', 'system', 'system'),
('7', '5', 'system', 'system'),
('8', '5', 'system', 'system'),
('9', '3', 'system', 'system'),
('10', '3', 'system', 'system');

-- 验证初始化结果
SELECT '角色数量：' AS info, COUNT(*) FROM sys_role;
SELECT '菜单数量：' AS info, COUNT(*) FROM sys_menu;
SELECT '用户数量：' AS info, COUNT(*) FROM sys_user;
SELECT '部门数量：' AS info, COUNT(*) FROM sys_dept;
SELECT '权限关联数量：' AS info, COUNT(*) FROM sys_role_menu;
SELECT '用户角色关联数量：' AS info, COUNT(*) FROM sys_user_role;