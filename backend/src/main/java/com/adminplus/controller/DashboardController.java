package com.adminplus.controller;

import com.adminplus.service.DashboardService;
import com.adminplus.utils.ApiResponse;
import com.adminplus.vo.DashboardStatsVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Dashboard 控制器
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Slf4j
@RestController
@RequestMapping("/v1/sys/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard管理", description = "统计数据接口")
public class DashboardController {

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    @Operation(summary = "获取统计数据")
    @PreAuthorize("hasAuthority('dashboard:stats')")
    public ApiResponse<DashboardStatsVO> getStats() {
        log.info("获取 Dashboard 统计数据");
        DashboardStatsVO stats = dashboardService.getStats();
        return ApiResponse.ok(stats);
    }
}