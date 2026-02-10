package com.adminplus;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

/**
 * 基础集成测试类
 */
@SpringBootTest
@ActiveProfiles("test")
@Transactional
public abstract class BaseIntegrationTest {
}