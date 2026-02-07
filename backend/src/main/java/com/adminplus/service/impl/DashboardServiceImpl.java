package com.adminplus.service.impl;

import com.adminplus.entity.LogEntity;
import com.adminplus.entity.MenuEntity;
import com.adminplus.entity.RoleEntity;
import com.adminplus.entity.UserEntity;
import com.adminplus.repository.LogRepository;
import com.adminplus.repository.MenuRepository;
import com.adminplus.repository.RoleRepository;
import com.adminplus.repository.UserRepository;
import com.adminplus.service.DashboardService;
import com.adminplus.vo.DashboardStatsVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Dashboard 服务实现
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final MenuRepository menuRepository;
    private final LogRepository logRepository;

    @Override
    public DashboardStatsVO getStats() {
        log.debug("获取 Dashboard 统计数据");

        // 统计用户数（未删除的）
        long userCount = userRepository.countByDeletedFalse();

        // 统计角色数（未删除的）
        long roleCount = roleRepository.countByDeletedFalse();

        // 统计菜单数（未删除的）
        long menuCount = menuRepository.countByDeletedFalse();

        // 统计日志数（未删除的）
        long logCount = logRepository.countByDeletedFalse();

        return new DashboardStatsVO(userCount, roleCount, menuCount, logCount);
    }
}