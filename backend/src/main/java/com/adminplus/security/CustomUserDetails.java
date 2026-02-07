package com.adminplus.security;

import lombok.Getter;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 自定义用户详情
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Getter
public class CustomUserDetails implements UserDetails {

    private final Long id;
    private final String username;
    private final String password;
    private final String nickname;
    private final String email;
    private final String phone;
    private final String avatar;
    private final Integer status;
    private final Collection<? extends GrantedAuthority> authorities;

    public CustomUserDetails(Long id, String username, String password, String nickname,
                             String email, String phone, String avatar, Integer status,
                             List<String> roles, List<String> permissions) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.nickname = nickname;
        this.email = email;
        this.phone = phone;
        this.avatar = avatar;
        this.status = status;

        // 构建权限列表：角色（ROLE_前缀）+ 权限标识符
        List<GrantedAuthority> authorityList = new java.util.ArrayList<>();

        // 添加角色权限（ROLE_前缀）
        if (roles != null && !roles.isEmpty()) {
            authorityList.addAll(roles.stream()
                    .map(role -> role.startsWith("ROLE_") ? role : "ROLE_" + role)
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList()));
        }

        // 添加菜单权限
        if (permissions != null && !permissions.isEmpty()) {
            authorityList.addAll(permissions.stream()
                    .map(SimpleGrantedAuthority::new)
                    .collect(Collectors.toList()));
        }

        // 如果没有任何权限，默认给予 ROLE_USER
        if (authorityList.isEmpty()) {
            authorityList.add(new SimpleGrantedAuthority("ROLE_USER"));
        }

        this.authorities = authorityList;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return status != null && status == 1;
    }
}