package com.adminplus.repository;

import com.adminplus.entity.LogEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * 操作日志 Repository
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Repository
public interface LogRepository extends JpaRepository<LogEntity, Long> {

    /**
     * 统计未删除的日志数量
     */
    long countByDeletedFalse();
}