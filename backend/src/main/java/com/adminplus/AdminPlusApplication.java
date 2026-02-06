package com.adminplus;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * AdminPlus 主启动类
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@SpringBootApplication
public class AdminPlusApplication {

    public static void main(String[] args) {
        SpringApplication.run(AdminPlusApplication.class, args);
        System.out.println("""
            ========================================
              AdminPlus 启动成功！
              访问地址: http://localhost:8080/api
              API 文档: http://localhost:8080/api/actuator/health
            ========================================
            """);
    }
}