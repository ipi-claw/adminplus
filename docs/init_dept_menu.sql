-- 部门管理菜单初始化脚本
-- PostgreSQL 16+

-- 插入部门管理菜单
INSERT INTO sys_menu (create_time, update_time, deleted, parent_id, type, name, path, component, perm_key, icon, sort_order, visible, status) VALUES
-- 部门管理
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '系统管理'), 1, '部门管理', '/system/dept', 'system/dept/index', NULL, 'OfficeBuilding', 4, 1, 1),
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '部门管理'), 2, '新增部门', NULL, NULL, 'dept:add', NULL, 1, 0, 1),
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '部门管理'), 2, '编辑部门', NULL, NULL, 'dept:edit', NULL, 2, 0, 1),
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '部门管理'), 2, '删除部门', NULL, NULL, 'dept:delete', NULL, 3, 0, 1),
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '部门管理'), 2, '查询部门', NULL, NULL, 'dept:query', NULL, 4, 0, 1),
(NOW(), NOW(), false, (SELECT id FROM sys_menu WHERE name = '部门管理'), 2, '部门列表', NULL, NULL, 'dept:list', NULL, 5, 0, 1);

-- 为管理员角色分配部门管理菜单权限
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT r.id, m.id FROM sys_role r, sys_menu m
WHERE r.code = 'ROLE_ADMIN' AND m.name IN ('部门管理', '新增部门', '编辑部门', '删除部门', '查询部门', '部门列表')
ON CONFLICT DO NOTHING;