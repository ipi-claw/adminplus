package com.adminplus.utils;

import java.util.regex.Pattern;

/**
 * 密码强度工具类
 *
 * @author AdminPlus
 * @since 2026-02-07
 */
public class PasswordUtils {

    // 密码强度规则：至少8位，包含大小写字母、数字和特殊字符
    private static final Pattern STRONG_PASSWORD_PATTERN = Pattern.compile(
            "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$"
    );

    // 中等密码：至少6位
    private static final Pattern MEDIUM_PASSWORD_PATTERN = Pattern.compile(
            "^.+$"
    );

    /**
     * 验证密码强度（强密码：至少8位，包含大小写字母和数字）
     *
     * @param password 密码
     * @return 是否符合强密码要求
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }
        return STRONG_PASSWORD_PATTERN.matcher(password).matches();
    }

    /**
     * 验证密码强度（中等密码：至少6位）
     *
     * @param password 密码
     * @return 是否符合中等密码要求
     */
    public static boolean isMediumPassword(String password) {
        if (password == null || password.isEmpty()) {
            return false;
        }
        return password.length() >= 6;
    }

    /**
     * 获取密码强度描述
     *
     * @param password 密码
     * @return 强度描述
     */
    public static String getPasswordStrength(String password) {
        if (password == null || password.isEmpty()) {
            return "密码不能为空";
        }

        if (isStrongPassword(password)) {
            return "强";
        } else if (isMediumPassword(password)) {
            return "中";
        } else {
            return "弱";
        }
    }

    /**
     * 获取密码强度提示信息
     *
     * @param password 密码
     * @return 提示信息
     */
    public static String getPasswordStrengthHint(String password) {
        if (password == null || password.isEmpty()) {
            return "密码不能为空";
        }

        StringBuilder hint = new StringBuilder();

        if (password.length() < 8) {
            hint.append("密码长度至少8位；");
        }

        if (!password.matches(".*[0-9].*")) {
            hint.append("密码必须包含数字；");
        }

        if (!password.matches(".*[a-z].*")) {
            hint.append("密码必须包含小写字母；");
        }

        if (!password.matches(".*[A-Z].*")) {
            hint.append("密码必须包含大写字母；");
        }

        if (!password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?].*")) {
            hint.append("密码必须包含特殊字符；");
        }

        if (hint.length() == 0) {
            return "密码强度符合要求";
        }

        return hint.toString().replaceAll("；$", "");
    }
}