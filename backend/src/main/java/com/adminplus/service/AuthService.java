package com.adminplus.service;

import com.adminplus.dto.UserLoginReq;
import com.adminplus.vo.LoginResp;
import com.adminplus.vo.UserVO;

import java.util.List;

/**
 * 认证服务接口
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public interface AuthService {

    /**
     * 用户登录
     */
    LoginResp login(UserLoginReq req);

    /**
     * 获取当前用户信息
     */
    UserVO getCurrentUser(String username);

    /**
     * 获取当前用户的权限列表
     */
    List<String> getCurrentUserPermissions(String username);

    /**
     * 用户登出
     */
    void logout();
}