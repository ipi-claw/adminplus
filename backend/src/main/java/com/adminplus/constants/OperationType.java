package com.adminplus.constants;

/**
 * 操作类型常量
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
public interface OperationType {

    /**
     * 查询
     */
    int QUERY = 1;

    /**
     * 新增
     */
    int CREATE = 2;

    /**
     * 修改
     */
    int UPDATE = 3;

    /**
     * 删除
     */
    int DELETE = 4;

    /**
     * 导出
     */
    int EXPORT = 5;

    /**
     * 导入
     */
    int IMPORT = 6;

    /**
     * 其他
     */
    int OTHER = 7;
}