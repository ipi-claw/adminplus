package com.adminplus.vo;

import java.util.List;

/**
 * 登录响应
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public record LoginResp(
        String token,
        String tokenType,
        UserVO user
) {
}