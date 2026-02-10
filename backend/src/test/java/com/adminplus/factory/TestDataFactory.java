package com.adminplus.factory;

import com.adminplus.dto.UserCreateReq;
import com.adminplus.dto.UserLoginReq;
import com.adminplus.dto.RoleCreateReq;
import com.adminplus.dto.MenuCreateReq;
import com.adminplus.entity.UserEntity;
import com.adminplus.entity.RoleEntity;
import com.adminplus.entity.MenuEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Map;

/**
 * 测试数据工厂
 * 提供统一的测试数据创建方法
 */
public class TestDataFactory {

    private static final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    /**
     * 创建测试用户实体
     */
    public static UserEntity createUserEntity(String username, String nickname) {
        UserEntity user = new UserEntity();
        user.setId(generateId("U"));
        user.setUsername(username);
        user.setPassword(passwordEncoder.encode("password123"));
        user.setNickname(nickname);
        user.setEmail(username + "@example.com");
        user.setPhone("13800138000");
        user.setStatus(1);
        return user;
    }

    /**
     * 创建管理员用户实体
     */
    public static UserEntity createAdminUser() {
        return createUserEntity("admin", "管理员");
    }

    /**
     * 创建普通用户实体
     */
    public static UserEntity createNormalUser() {
        return createUserEntity("user", "普通用户");
    }

    /**
     * 创建用户创建请求
     */
    public static UserCreateReq createUserCreateReq(String username, String nickname) {
        return new UserCreateReq(
            username, "password123", nickname,
            username + "@example.com", "13800138000", null
        );
    }

    /**
     * 创建用户登录请求
     */
    public static UserLoginReq createUserLoginReq(String username, String password) {
        return new UserLoginReq(username, password);
    }

    /**
     * 创建角色实体
     */
    public static RoleEntity createRoleEntity(String code, String name, String description) {
        RoleEntity role = new RoleEntity();
        role.setId(generateId("R"));
        role.setCode(code);
        role.setName(name);
        role.setDescription(description);
        role.setDataScope(1);
        role.setStatus(1);
        role.setSortOrder(1);
        return role;
    }

    /**
     * 创建管理员角色
     */
    public static RoleEntity createAdminRole() {
        return createRoleEntity("admin", "管理员", "系统管理员");
    }

    /**
     * 创建普通用户角色
     */
    public static RoleEntity createUserRole() {
        return createRoleEntity("user", "普通用户", "普通用户角色");
    }

    /**
     * 创建角色创建请求
     */
    public static RoleCreateReq createRoleCreateReq(String code, String name, String description) {
        return new RoleCreateReq(code, name, description, 1, 1);
    }

    /**
     * 创建菜单实体
     */
    public static MenuEntity createMenuEntity(String name, String path, String component, Integer type) {
        MenuEntity menu = new MenuEntity();
        menu.setId(generateId("M"));
        menu.setName(name);
        menu.setPath(path);
        menu.setComponent(component);
        menu.setType(type);
        menu.setStatus(1);
        menu.setSortOrder(1);
        menu.setVisible(true);
        return menu;
    }

    /**
     * 创建菜单创建请求
     */
    public static MenuCreateReq createMenuCreateReq(String name, String path, String component, Integer type) {
        return new MenuCreateReq(name, path, component, type, 1, 1, true, null, null);
    }

    /**
     * 生成简单的测试ID
     */
    private static String generateId(String prefix) {
        return prefix + System.currentTimeMillis() + "_" + (int)(Math.random() * 1000);
    }

    /**
     * 创建用户设置
     */
    public static Map<String, Object> createUserSettings() {
        return Map.of(
            "theme", "dark",
            "language", "zh-CN",
            "layout", "vertical"
        );
    }
}