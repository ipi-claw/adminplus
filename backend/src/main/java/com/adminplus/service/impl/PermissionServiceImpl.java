package com.adminplus.service.impl;

import com.adminplus.entity.MenuEntity;
import com.adminplus.entity.RoleEntity;
import com.adminplus.entity.UserRoleEntity;
import com.adminplus.repository.MenuRepository;
import com.adminplus.repository.RoleMenuRepository;
import com.adminplus.repository.RoleRepository;
import com.adminplus.repository.UserRoleRepository;
import com.adminplus.service.PermissionService;
import com.adminplus.vo.PermissionVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 权限服务实现
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PermissionServiceImpl implements PermissionService {

    private final UserRoleRepository userRoleRepository;
    private final RoleMenuRepository roleMenuRepository;
    private final MenuRepository menuRepository;
    private final RoleRepository roleRepository;

    @Override
    @Transactional(readOnly = true)
    public List<String> getUserPermissions(Long userId) {
        // 1. 查询用户的角色ID列表
        List<Long> roleIds = userRoleRepository.findByUserId(userId).stream()
                .map(UserRoleEntity::getRoleId)
                .toList();

        if (roleIds.isEmpty()) {
            return List.of();
        }

        // 2. 查询这些角色的菜单ID列表（去重）
        Set<Long> menuIds = roleIds.stream()
                .flatMap(roleId -> roleMenuRepository.findMenuIdByRoleId(roleId).stream())
                .collect(Collectors.toSet());

        if (menuIds.isEmpty()) {
            return List.of();
        }

        // 3. 查询菜单的权限标识符（permKey），过滤掉空值
        return menuIds.stream()
                .map(menuId -> menuRepository.findById(menuId).orElse(null))
                .filter(menu -> menu != null && menu.getPermKey() != null && !menu.getPermKey().isBlank())
                .map(MenuEntity::getPermKey)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getUserRoles(Long userId) {
        List<Long> roleIds = userRoleRepository.findByUserId(userId).stream()
                .map(UserRoleEntity::getRoleId)
                .toList();

        return roleIds.stream()
                .map(roleId -> roleRepository.findById(roleId).orElse(null))
                .filter(role -> role != null)
                .map(RoleEntity::getCode)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<Long> getUserRoleIds(Long userId) {
        return userRoleRepository.findByUserId(userId).stream()
                .map(UserRoleEntity::getRoleId)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<String> getRolePermissions(Long roleId) {
        // 1. 查询角色的菜单ID列表
        List<Long> menuIds = roleMenuRepository.findMenuIdByRoleId(roleId);

        if (menuIds.isEmpty()) {
            return List.of();
        }

        // 2. 查询菜单的权限标识符（permKey），过滤掉空值
        return menuIds.stream()
                .map(menuId -> menuRepository.findById(menuId).orElse(null))
                .filter(menu -> menu != null && menu.getPermKey() != null && !menu.getPermKey().isBlank())
                .map(MenuEntity::getPermKey)
                .collect(Collectors.toList());
    }

    @Override
    @Transactional(readOnly = true)
    public List<PermissionVO> getAllPermissions() {
        List<MenuEntity> menus = menuRepository.findAllByOrderBySortOrderAsc();

        return menus.stream()
                .filter(menu -> menu.getPermKey() != null && !menu.getPermKey().isBlank())
                .map(menu -> new PermissionVO(
                        menu.getId(),
                        menu.getPermKey(),
                        menu.getName(),
                        menu.getType(),
                        menu.getParentId()
                ))
                .toList();
    }
}