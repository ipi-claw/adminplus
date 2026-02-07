package com.adminplus.service.impl;

import com.adminplus.constants.LogStatus;
import com.adminplus.entity.LogEntity;
import com.adminplus.repository.LogRepository;
import com.adminplus.service.LogService;
import com.adminplus.utils.SecurityUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 日志服务实现
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class LogServiceImpl implements LogService {

    private final LogRepository logRepository;

    @Override
    @Async
    @Transactional
    public void log(String module, Integer operationType, String description) {
        log(module, operationType, description, null, null, null);
    }

    @Override
    @Async
    @Transactional
    public void log(String module, Integer operationType, String description,
                    String method, String params, String ip) {
        try {
            LogEntity logEntity = new LogEntity();
            logEntity.setUserId(SecurityUtils.getCurrentUserId());
            logEntity.setUsername(SecurityUtils.getCurrentUsername());
            logEntity.setModule(module);
            logEntity.setOperationType(operationType);
            logEntity.setDescription(description);
            logEntity.setMethod(method);
            logEntity.setParams(params);
            logEntity.setIp(ip);
            logEntity.setStatus(LogStatus.SUCCESS);
            logEntity.setCostTime(0L);

            logRepository.save(logEntity);
        } catch (Exception e) {
            log.error("保存操作日志失败", e);
        }
    }

    @Override
    @Async
    @Transactional
    public void log(String module, Integer operationType, String description, Long costTime) {
        try {
            LogEntity logEntity = new LogEntity();
            logEntity.setUserId(SecurityUtils.getCurrentUserId());
            logEntity.setUsername(SecurityUtils.getCurrentUsername());
            logEntity.setModule(module);
            logEntity.setOperationType(operationType);
            logEntity.setDescription(description);
            logEntity.setCostTime(costTime);
            logEntity.setStatus(LogStatus.SUCCESS);

            logRepository.save(logEntity);
        } catch (Exception e) {
            log.error("保存操作日志失败", e);
        }
    }

    @Override
    @Async
    @Transactional
    public void log(String module, Integer operationType, String description,
                    Integer status, String errorMsg) {
        try {
            LogEntity logEntity = new LogEntity();
            logEntity.setUserId(SecurityUtils.getCurrentUserId());
            logEntity.setUsername(SecurityUtils.getCurrentUsername());
            logEntity.setModule(module);
            logEntity.setOperationType(operationType);
            logEntity.setDescription(description);
            logEntity.setStatus(status);
            logEntity.setErrorMsg(errorMsg);

            logRepository.save(logEntity);
        } catch (Exception e) {
            log.error("保存操作日志失败", e);
        }
    }
}