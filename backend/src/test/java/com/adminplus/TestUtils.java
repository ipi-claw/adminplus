package com.adminplus;

import com.adminplus.entity.UserEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

/**
 * 测试工具类
 */
public class TestUtils {

    private static final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * 创建测试用户
     */
    public static UserEntity createTestUser() {
        UserEntity user = new UserEntity();
        user.setUsername("testuser");
        user.setPassword(passwordEncoder.encode("password123"));
        user.setNickname("测试用户");
        user.setEmail("test@example.com");
        user.setPhone("13800138000");
        user.setStatus(1);
        return user;
    }

    /**
     * 创建管理员用户
     */
    public static UserEntity createAdminUser() {
        UserEntity user = new UserEntity();
        user.setUsername("admin");
        user.setPassword(passwordEncoder.encode("admin123"));
        user.setNickname("管理员");
        user.setEmail("admin@example.com");
        user.setStatus(1);
        return user;
    }

    /**
     * 模拟用户认证
     */
    public static void mockAuthentication(String username, String... roles) {
        List<SimpleGrantedAuthority> authorities = List.of(roles).stream()
                .map(SimpleGrantedAuthority::new)
                .toList();

        UsernamePasswordAuthenticationToken authentication = 
                new UsernamePasswordAuthenticationToken(username, null, authorities);

        SecurityContext context = SecurityContextHolder.createEmptyContext();
        context.setAuthentication(authentication);
        SecurityContextHolder.setContext(context);
    }

    /**
     * 清除认证上下文
     */
    public static void clearAuthentication() {
        SecurityContextHolder.clearContext();
    }
}