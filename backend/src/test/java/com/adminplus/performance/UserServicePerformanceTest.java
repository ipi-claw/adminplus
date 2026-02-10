package com.adminplus.performance;

import com.adminplus.dto.UserCreateReq;
import com.adminplus.entity.UserEntity;
import com.adminplus.repository.UserRepository;
import com.adminplus.service.UserService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * 用户服务性能测试
 * 注意：这类测试应该在生产环境配置下运行
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
class UserServicePerformanceTest {

    @Autowired
    private UserService userService;

    @Autowired
    private UserRepository userRepository;

    @Test
    void testConcurrentUserCreation() throws InterruptedException {
        // 配置
        int threadCount = 10;
        int iterationsPerThread = 10;
        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        CountDownLatch latch = new CountDownLatch(threadCount);

        long startTime = System.currentTimeMillis();

        // 并发创建用户
        for (int i = 0; i < threadCount; i++) {
            final int threadId = i;
            executor.submit(() -> {
                try {
                    for (int j = 0; j < iterationsPerThread; j++) {
                        String username = String.format("user_%d_%d", threadId, j);
                        UserCreateReq req = new UserCreateReq(
                            username, "password123", "测试用户", 
                            username + "@example.com", "13800138000", null
                        );
                        userService.createUser(req);
                    }
                } finally {
                    latch.countDown();
                }
            });
        }

        // 等待所有线程完成
        assertTrue(latch.await(30, TimeUnit.SECONDS));
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        // 验证性能要求（100个用户创建应该在10秒内完成）
        assertTrue(duration < 10000, 
            String.format("并发用户创建耗时 %dms，超过10秒阈值", duration));

        // 验证数据一致性
        long userCount = userRepository.count();
        assertTrue(userCount >= threadCount * iterationsPerThread, 
            String.format("期望至少 %d 个用户，实际 %d", threadCount * iterationsPerThread, userCount));

        executor.shutdown();
    }

    @Test
    void testUserQueryPerformance() {
        // 准备测试数据
        for (int i = 0; i < 100; i++) {
            UserEntity user = new UserEntity();
            user.setUsername("perf_user_" + i);
            user.setPassword("password123");
            user.setNickname("性能测试用户" + i);
            user.setStatus(1);
            userRepository.save(user);
        }

        // 测试查询性能
        long startTime = System.currentTimeMillis();
        
        for (int i = 0; i < 1000; i++) {
            userService.getUserList();
        }
        
        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        // 验证查询性能（1000次查询应该在5秒内完成）
        assertTrue(duration < 5000, 
            String.format("用户查询性能测试耗时 %dms，超过5秒阈值", duration));
    }
}