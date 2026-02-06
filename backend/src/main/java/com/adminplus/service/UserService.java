package com.adminplus.service;

import com.adminplus.dto.UserCreateReq;
import com.adminplus.dto.UserUpdateReq;
import com.adminplus.entity.UserEntity;
import com.adminplus.vo.UserVO;

import java.util.List;

/**
 * 用户服务接口
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public interface UserService {

    /**
     * 分页查询用户列表
     */
    List<UserVO> getUserList(Integer page, Integer size, String keyword);

    /**
     * 根据ID查询用户
     */
    UserVO getUserById(Long id);

    /**
     * 根据用户名查询用户
     */
    UserEntity getUserByUsername(String username);

    /**
     * 创建用户
     */
    UserVO createUser(UserCreateReq req);

    /**
     * 更新用户
     */
    UserVO updateUser(Long id, UserUpdateReq req);

    /**
     * 删除用户
     */
    void deleteUser(Long id);

    /**
     * 启用/禁用用户
     */
    void updateUserStatus(Long id, Integer status);

    /**
     * 重置密码
     */
    void resetPassword(Long id, String newPassword);

    /**
     * 为用户分配角色
     */
    void assignRoles(Long userId, List<Long> roleIds);

    /**
     * 查询用户的角色ID列表
     */
    List<Long> getUserRoleIds(Long userId);
}