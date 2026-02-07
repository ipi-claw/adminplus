package com.adminplus.vo;

import java.time.Instant;

/**
 * 权限视图对象
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
public record PermissionVO(
        Long id,
        String permKey,
        String name,
        Integer type,
        Long parentId
) {
}