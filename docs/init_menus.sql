-- AdminPlus 菜单数据初始化脚本
-- 用于动态路由系统的菜单配置

-- 清空现有菜单数据（可选）
-- TRUNCATE TABLE sys_role_menu CASCADE;
-- TRUNCATE TABLE sys_menu CASCADE;

-- 插入菜单数据
INSERT INTO sys_menu (id, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status, create_time, update_time, deleted) VALUES
-- 首页
(1, 0, 1, '首页', '/dashboard', '/views/Dashboard.vue', 'dashboard:list', 'HomeFilled', 1, 1, 1, NOW(), NOW(), false),

-- 系统管理（目录）
(2, 0, 0, '系统管理', '/system', NULL, 'system:list', 'Setting', 2, 1, 1, NOW(), NOW(), false),

-- 系统管理子菜单
(3, 2, 1, '用户管理', '/system/user', '/views/system/User.vue', 'user:list', 'User', 1, 1, 1, NOW(), NOW(), false),
(4, 2, 1, '角色管理', '/system/role', '/views/system/Role.vue', 'role:list', 'UserFilled', 2, 1, 1, NOW(), NOW(), false),
(5, 2, 1, '菜单管理', '/system/menu', '/views/system/Menu.vue', 'menu:list', 'Menu', 3, 1, 1, NOW(), NOW(), false),
(6, 2, 1, '字典管理', '/system/dict', '/views/system/Dict.vue', 'dict:list', 'Document', 4, 1, 1, NOW(), NOW(), false),

-- 字典项管理（作为字典管理的子页面）
(7, 2, 1, '字典项管理', '/system/dict/:dictId', '/views/system/DictItem.vue', 'dictitem:list', NULL, 5, 1, 1, NOW(), NOW(), false),

-- 个人中心
(8, 0, 1, '个人中心', '/profile', '/views/Profile.vue', 'profile:view', 'Avatar', 3, 1, 1, NOW(), NOW(), false),

-- 按钮权限（type=2，不生成路由，仅用于权限控制）
(9, 3, 2, '添加用户', NULL, NULL, 'user:add', NULL, 1, 0, 1, NOW(), NOW(), false),
(10, 3, 2, '编辑用户', NULL, NULL, 'user:edit', NULL, 2, 0, 1, NOW(), NOW(), false),
(11, 3, 2, '删除用户', NULL, NULL, 'user:delete', NULL, 3, 0, 1, NOW(), NOW(), false),
(12, 3, 2, '分配角色', NULL, NULL, 'user:assign', NULL, 4, 0, 1, NOW(), NOW(), false),
(13, 3, 2, '重置密码', NULL, NULL, 'user:reset', NULL, 5, 0, 1, NOW(), NOW(), false),

(14, 4, 2, '添加角色', NULL, NULL, 'role:add', NULL, 1, 0, 1, NOW(), NOW(), false),
(15, 4, 2, '编辑角色', NULL, NULL, 'role:edit', NULL, 2, 0, 1, NOW(), NOW(), false),
(16, 4, 2, '删除角色', NULL, NULL, 'role:delete', NULL, 3, 0, 1, NOW(), NOW(), false),
(17, 4, 2, '分配权限', NULL, NULL, 'role:assign', NULL, 4, 0, 1, NOW(), NOW(), false),

(18, 5, 2, '添加菜单', NULL, NULL, 'menu:add', NULL, 1, 0, 1, NOW(), NOW(), false),
(19, 5, 2, '编辑菜单', NULL, NULL, 'menu:edit', NULL, 2, 0, 1, NOW(), NOW(), false),
(20, 5, 2, '删除菜单', NULL, NULL, 'menu:delete', NULL, 3, 0, 1, NOW(), NOW(), false),

(21, 6, 2, '添加字典', NULL, NULL, 'dict:add', NULL, 1, 0, 1, NOW(), NOW(), false),
(22, 6, 2, '编辑字典', NULL, NULL, 'dict:edit', NULL, 2, 0, 1, NOW(), NOW(), false),
(23, 6, 2, '删除字典', NULL, NULL, 'dict:delete', NULL, 3, 0, 1, NOW(), NOW(), false);

-- 为超级管理员角色分配所有菜单权限
-- 超级管理员角色的 ID 为 3
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 3, id FROM sys_menu WHERE deleted = false;

-- 为普通用户角色分配部分菜单权限（仅首页和个人中心）
-- 普通用户角色的 ID 为 4
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 4, id FROM sys_menu
WHERE id IN (1, 8) AND deleted = false;

-- 验证数据
SELECT
    m.id,
    m.parent_id,
    CASE m.type
        WHEN 0 THEN '目录'
        WHEN 1 THEN '菜单'
        WHEN 2 THEN '按钮'
    END AS type_name,
    m.name,
    m.path,
    m.component,
    m.perm_key,
    m.icon,
    m.sort_order,
    CASE m.visible WHEN 1 THEN '显示' WHEN 0 THEN '隐藏' END AS visible_name,
    CASE m.status WHEN 1 THEN '正常' WHEN 0 THEN '禁用' END AS status_name
FROM sys_menu m
WHERE m.deleted = false
ORDER BY m.sort_order, m.id;

-- 查询角色菜单关联
SELECT
    r.id AS role_id,
    r.name AS role_name,
    m.id AS menu_id,
    m.name AS menu_name,
    m.path AS menu_path
FROM sys_role_menu rm
JOIN sys_role r ON rm.role_id = r.id
JOIN sys_menu m ON rm.menu_id = m.id
WHERE r.deleted = false AND m.deleted = false
ORDER BY r.id, m.sort_order, m.id;