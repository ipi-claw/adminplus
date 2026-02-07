package com.adminplus.service;

import com.adminplus.vo.DashboardStatsVO;

/**
 * Dashboard 服务接口
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
public interface DashboardService {

    /**
     * 获取统计数据
     *
     * @return 统计数据
     */
    DashboardStatsVO getStats();
}