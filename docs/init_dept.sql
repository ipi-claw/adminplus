-- 部门表创建脚本
-- PostgreSQL 16+

-- 创建部门表
CREATE TABLE sys_dept (
    id BIGSERIAL PRIMARY KEY,
    parent_id BIGINT,
    name TEXT NOT NULL,
    code TEXT,
    leader TEXT,
    phone TEXT,
    email TEXT,
    sort_order INTEGER,
    status INTEGER NOT NULL DEFAULT 1,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted BOOLEAN NOT NULL DEFAULT FALSE
);

-- 创建索引
CREATE INDEX idx_sys_dept_parent_id ON sys_dept(parent_id);
CREATE INDEX idx_sys_dept_name ON sys_dept(name);
CREATE INDEX idx_sys_dept_code ON sys_dept(code);
CREATE INDEX idx_sys_dept_status ON sys_dept(status);

-- 创建更新时间触发器
CREATE TRIGGER update_sys_dept_updated_at BEFORE UPDATE ON sys_dept
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入初始部门数据
INSERT INTO sys_dept (parent_id, name, code, leader, phone, email, sort_order, status) VALUES
(NULL, 'AdminPlus 总部', 'HQ', '张三', '13800138000', 'admin@adminplus.com', 1, 1),
((SELECT id FROM sys_dept WHERE code = 'HQ'), '技术研发部', 'RD', '李四', '13800138001', 'rd@adminplus.com', 1, 1),
((SELECT id FROM sys_dept WHERE code = 'HQ'), '市场运营部', 'MK', '王五', '13800138002', 'mk@adminplus.com', 2, 1),
((SELECT id FROM sys_dept WHERE code = 'RD'), '后端开发组', 'RD-BE', '赵六', '13800138003', 'rd-be@adminplus.com', 1, 1),
((SELECT id FROM sys_dept WHERE code = 'RD'), '前端开发组', 'RD-FE', '钱七', '13800138004', 'rd-fe@adminplus.com', 2, 1),
((SELECT id FROM sys_dept WHERE code = 'MK'), '市场推广组', 'MK-MKT', '孙八', '13800138005', 'mkt@adminplus.com', 1, 1),
((SELECT id FROM sys_dept WHERE code = 'MK'), '客户服务组', 'MK-CS', '周九', '13800138006', 'cs@adminplus.com', 2, 1);

-- 添加表注释
COMMENT ON TABLE sys_dept IS '部门表';

-- 添加列注释
COMMENT ON COLUMN sys_dept.parent_id IS '父部门ID';
COMMENT ON COLUMN sys_dept.name IS '部门名称';
COMMENT ON COLUMN sys_dept.code IS '部门编码';
COMMENT ON COLUMN sys_dept.leader IS '负责人';
COMMENT ON COLUMN sys_dept.phone IS '联系电话';
COMMENT ON COLUMN sys_dept.email IS '邮箱';
COMMENT ON COLUMN sys_dept.sort_order IS '排序';
COMMENT ON COLUMN sys_dept.status IS '状态（1=正常，0=禁用）';