package com.adminplus.repository;

import com.adminplus.entity.RoleMenuEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * 角色-菜单关联 Repository
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Repository
public interface RoleMenuRepository extends JpaRepository<RoleMenuEntity, Long> {

    /**
     * 根据角色ID查询菜单ID列表
     */
    List<Long> findMenuIdByRoleId(Long roleId);

    /**
     * 根据菜单ID查询角色ID列表
     */
    List<Long> findRoleIdByMenuId(Long menuId);

    /**
     * 删除角色的所有菜单
     */
    void deleteByRoleId(Long roleId);

    /**
     * 删除菜单的所有角色
     */
    void deleteByMenuId(Long menuId);
}