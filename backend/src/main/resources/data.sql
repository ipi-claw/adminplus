-- 字典表测试数据
INSERT INTO sys_dict (dict_type, dict_name, remark, status, deleted, create_time, update_time) VALUES
('sys_common_status', '通用状态', '系统通用状态字典', 1, false, NOW(), NOW()),
('sys_user_sex', '用户性别', '用户性别字典', 1, false, NOW(), NOW()),
('sys_yes_no', '是否选项', '系统是否选项字典', 1, false, NOW(), NOW());

-- 字典项测试数据
INSERT INTO sys_dict_item (dict_id, label, value, sort_order, status, remark, deleted, create_time, update_time) VALUES
-- 通用状态
(1, '正常', '1', 1, 1, '正常状态', false, NOW(), NOW()),
(1, '禁用', '0', 2, 1, '禁用状态', false, NOW(), NOW()),
-- 用户性别
(2, '男', '1', 1, 1, '男性', false, NOW(), NOW()),
(2, '女', '2', 2, 1, '女性', false, NOW(), NOW()),
(2, '未知', '0', 3, 1, '未知性别', false, NOW(), NOW()),
-- 是否选项
(3, '是', '1', 1, 1, '是', false, NOW(), NOW()),
(3, '否', '0', 2, 1, '否', false, NOW(), NOW());

-- 初始化管理员用户（密码：admin123）
INSERT INTO sys_user (username, nickname, password, email, phone, status, deleted, create_time, update_time) VALUES
('admin', '系统管理员', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6Z5EH', 'admin@adminplus.com', '13800138000', 1, false, NOW(), NOW());

-- 初始化角色
INSERT INTO sys_role (role_name, role_code, description, status, deleted, create_time, update_time) VALUES
('超级管理员', 'ROLE_ADMIN', '拥有系统所有权限', 1, false, NOW(), NOW()),
('普通用户', 'ROLE_USER', '普通用户角色', 1, false, NOW(), NOW());

-- 为管理员分配角色
INSERT INTO sys_user_role (user_id, role_id) VALUES (1, 1);

-- 初始化菜单
INSERT INTO sys_menu (parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, deleted, create_time, update_time) VALUES
(0, 0, '系统管理', '/system', NULL, NULL, 'Setting', 1, 1, 1, false, NOW(), NOW()),
(1, 1, '用户管理', '/system/user', 'system/User', 'user:list', 'User', 1, 1, 1, false, NOW(), NOW()),
(1, 1, '角色管理', '/system/role', 'system/Role', 'role:list', 'UserFilled', 2, 1, 1, false, NOW(), NOW()),
(1, 1, '菜单管理', '/system/menu', 'system/Menu', 'menu:list', 'Menu', 3, 1, 1, false, NOW(), NOW()),
(1, 1, '字典管理', '/system/dict', 'system/Dict', 'dict:list', 'Document', 4, 1, 1, false, NOW(), NOW());

-- 为超级管理员角色分配所有菜单权限
INSERT INTO sys_role_menu (role_id, menu_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5);