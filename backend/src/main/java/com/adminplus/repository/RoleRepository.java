package com.adminplus.repository;

import com.adminplus.entity.RoleEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * 角色 Repository
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Repository
public interface RoleRepository extends JpaRepository<RoleEntity, Long> {

    /**
     * 根据角色编码查询角色
     */
    Optional<RoleEntity> findByCode(String code);

    /**
     * 检查角色编码是否存在
     */
    boolean existsByCode(String code);
}