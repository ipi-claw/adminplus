package com.adminplus.service;

import org.springframework.web.multipart.MultipartFile;

/**
 * 病毒扫描服务接口
 *
 * @author AdminPlus
 * @since 2026-02-08
 */
public interface VirusScanService {

    /**
     * 扫描文件是否包含病毒
     *
     * @param file 要扫描的文件
     * @return true 如果文件安全，false 如果包含病毒
     * @throws RuntimeException 如果扫描失败
     */
    boolean scanFile(MultipartFile file);

    /**
     * 检查病毒扫描服务是否可用
     *
     * @return true 如果服务可用，false 如果服务不可用
     */
    boolean isServiceAvailable();
}