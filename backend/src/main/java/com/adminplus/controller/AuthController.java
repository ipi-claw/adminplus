package com.adminplus.controller;

import com.adminplus.dto.UserLoginReq;
import com.adminplus.service.AuthService;
import com.adminplus.utils.ApiResponse;
import com.adminplus.vo.LoginResp;
import com.adminplus.vo.UserVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Slf4j
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "认证管理", description = "用户登录、登出、获取当前用户信息")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    @Operation(summary = "用户登录")
    public ApiResponse<LoginResp> login(@Valid @RequestBody UserLoginReq req) {
        log.info("用户登录: {}", req.username());
        LoginResp resp = authService.login(req);
        return ApiResponse.ok(resp);
    }

    @GetMapping("/me")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "获取当前用户信息")
    public ApiResponse<UserVO> getCurrentUser(Authentication authentication) {
        String username = authentication.getName();
        UserVO userVO = authService.getCurrentUser(username);
        return ApiResponse.ok(userVO);
    }

    @PostMapping("/logout")
    @Operation(summary = "用户登出")
    public ApiResponse<Void> logout() {
        authService.logout();
        return ApiResponse.ok();
    }
}