package com.adminplus.vo;

import java.time.Instant;
import java.util.List;

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
        Long parentId,
        String label,
        String value,
        Integer sortOrder,
        Integer status,
        String remark,
        List<DictItemVO> children,
        Instant createTime,
        Instant updateTime
) {}