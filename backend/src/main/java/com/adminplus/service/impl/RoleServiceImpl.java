package com.adminplus.service.impl;

import com.adminplus.dto.RoleCreateReq;
import com.adminplus.dto.RoleUpdateReq;
import com.adminplus.entity.RoleEntity;
import com.adminplus.entity.RoleMenuEntity;
import com.adminplus.exception.BizException;
import com.adminplus.repository.RoleMenuRepository;
import com.adminplus.repository.RoleRepository;
import com.adminplus.service.RoleService;
import com.adminplus.vo.RoleVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 角色服务实现
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class RoleServiceImpl implements RoleService {

    private final RoleRepository roleRepository;
    private final RoleMenuRepository roleMenuRepository;

    @Override
    @Transactional(readOnly = true)
    public List<RoleVO> getRoleList() {
        var roles = roleRepository.findAll();
        return roles.stream().map(role -> new RoleVO(
                role.getId(),
                role.getCode(),
                role.getName(),
                role.getDescription(),
                role.getDataScope(),
                role.getStatus(),
                role.getSortOrder(),
                role.getCreateTime(),
                role.getUpdateTime()
        )).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public RoleVO getRoleById(Long id) {
        var role = roleRepository.findById(id)
                .orElseThrow(() -> new BizException("角色不存在"));

        return new RoleVO(
                role.getId(),
                role.getCode(),
                role.getName(),
                role.getDescription(),
                role.getDataScope(),
                role.getStatus(),
                role.getSortOrder(),
                role.getCreateTime(),
                role.getUpdateTime()
        );
    }

    @Override
    @Transactional
    public RoleVO createRole(RoleCreateReq req) {
        // 检查角色编码是否已存在
        if (roleRepository.existsByCode(req.code())) {
            throw new BizException("角色编码已存在");
        }

        var role = new RoleEntity();
        role.setCode(req.code());
        role.setName(req.name());
        role.setDescription(req.description());
        role.setDataScope(req.dataScope() != null ? req.dataScope() : 1);
        role.setStatus(req.status() != null ? req.status() : 1);
        role.setSortOrder(req.sortOrder());

        role = roleRepository.save(role);

        return new RoleVO(
                role.getId(),
                role.getCode(),
                role.getName(),
                role.getDescription(),
                role.getDataScope(),
                role.getStatus(),
                role.getSortOrder(),
                role.getCreateTime(),
                role.getUpdateTime()
        );
    }

    @Override
    @Transactional
    public RoleVO updateRole(Long id, RoleUpdateReq req) {
        var role = roleRepository.findById(id)
                .orElseThrow(() -> new BizException("角色不存在"));

        if (req.name() != null) {
            role.setName(req.name());
        }
        if (req.description() != null) {
            role.setDescription(req.description());
        }
        if (req.dataScope() != null) {
            role.setDataScope(req.dataScope());
        }
        if (req.status() != null) {
            role.setStatus(req.status());
        }
        if (req.sortOrder() != null) {
            role.setSortOrder(req.sortOrder());
        }

        role = roleRepository.save(role);

        return new RoleVO(
                role.getId(),
                role.getCode(),
                role.getName(),
                role.getDescription(),
                role.getDataScope(),
                role.getStatus(),
                role.getSortOrder(),
                role.getCreateTime(),
                role.getUpdateTime()
        );
    }

    @Override
    @Transactional
    public void deleteRole(Long id) {
        var role = roleRepository.findById(id)
                .orElseThrow(() -> new BizException("角色不存在"));

        // 删除角色-菜单关联
        roleMenuRepository.deleteByRoleId(id);

        // 删除角色（逻辑删除或物理删除，这里使用物理删除）
        roleRepository.delete(role);
    }

    @Override
    @Transactional
    public void assignMenus(Long roleId, List<Long> menuIds) {
        // 检查角色是否存在
        if (!roleRepository.existsById(roleId)) {
            throw new BizException("角色不存在");
        }

        // 删除原有的角色-菜单关联
        roleMenuRepository.deleteByRoleId(roleId);

        // 添加新的角色-菜单关联
        if (menuIds != null && !menuIds.isEmpty()) {
            List<RoleMenuEntity> roleMenus = menuIds.stream().map(menuId -> {
                var roleMenu = new RoleMenuEntity();
                roleMenu.setRoleId(roleId);
                roleMenu.setMenuId(menuId);
                return roleMenu;
            }).toList();
            roleMenuRepository.saveAll(roleMenus);
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<Long> getRoleMenuIds(Long roleId) {
        if (!roleRepository.existsById(roleId)) {
            throw new BizException("角色不存在");
        }
        return roleMenuRepository.findMenuIdByRoleId(roleId);
    }
}