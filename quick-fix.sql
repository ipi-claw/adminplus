-- 快速修复 - 为关联表生成雪花ID

-- 清除现有数据
DELETE FROM sys_user_role;
DELETE FROM sys_role_menu;

-- 权限关联 - 为超级管理员分配所有菜单权限
INSERT INTO sys_role_menu (id, role_id, menu_id)
SELECT 
    ('1' || LPAD((ROW_NUMBER() OVER () + 1000)::text, 4, '0')) as id,
    '1', 
    id 
FROM sys_menu 
WHERE type != 2;

-- 部门经理权限
INSERT INTO sys_role_menu (id, role_id, menu_id)
VALUES 
('2001', '2', '27'),
('2002', '2', '2'),
('2003', '2', '3'),
('2004', '2', '4'),
('2005', '2', '5'),
('2006', '2', '6'),
('2007', '2', '7'),
('2008', '2', '21'),
('2009', '2', '22'),
('2010', '2', '23'),
('2011', '2', '24'),
('2012', '2', '25'),
('2013', '2', '26');

-- 开发人员权限
INSERT INTO sys_role_menu (id, role_id, menu_id)
VALUES 
('3001', '4', '27'),
('3002', '4', '2'),
('3003', '4', '8'),
('3004', '4', '13'),
('3005', '4', '17'),
('3006', '4', '28'),
('3007', '4', '30'),
('3008', '4', '31');

-- 运营人员权限
INSERT INTO sys_role_menu (id, role_id, menu_id)
VALUES 
('4001', '5', '27'),
('4002', '5', '30'),
('4003', '5', '31');

-- 普通用户权限
INSERT INTO sys_role_menu (id, role_id, menu_id)
VALUES ('5001', '3', '27');

-- 用户角色关联
INSERT INTO sys_user_role (id, user_id, role_id)
VALUES 
('6001', '1', '1'),
('6002', '2', '2'),
('6003', '3', '3'),
('6004', '4', '3'),
('6005', '5', '4'),
('6006', '6', '4'),
('6007', '7', '5'),
('6008', '8', '5'),
('6009', '9', '3'),
('6010', '10', '3');

-- 验证初始化结果
SELECT '权限关联数量：' AS info, COUNT(*) FROM sys_role_menu;
SELECT '用户角色关联数量：' AS info, COUNT(*) FROM sys_user_role;