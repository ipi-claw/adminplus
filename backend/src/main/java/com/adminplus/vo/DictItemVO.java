package com.adminplus.vo;

import java.time.Instant;

/**
 * 字典项视图对象
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public record DictItemVO(
        Long id,
        Long dictId,
        String dictType,
        String label,
        String value,
        Integer sortOrder,
        Integer status,
        String remark,
        Instant createTime,
        Instant updateTime
) {}