package com.adminplus.repository;

import com.adminplus.entity.UserRoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 用户-角色关联 Repository
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Repository
public interface UserRoleRepository extends JpaRepository<UserRoleEntity, Long> {

    /**
     * 根据用户ID查询角色ID列表
     */
    List<Long> findRoleIdByUserId(Long userId);

    /**
     * 根据角色ID查询用户ID列表
     */
    List<Long> findUserIdByRoleId(Long roleId);

    /**
     * 删除用户的所有角色
     */
    void deleteByUserId(Long userId);

    /**
     * 删除角色的所有用户
     */
    void deleteByRoleId(Long roleId);
}