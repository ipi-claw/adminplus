package com.adminplus.service.impl;

import com.adminplus.dto.UserLoginReq;
import com.adminplus.entity.RoleEntity;
import com.adminplus.entity.UserEntity;
import com.adminplus.entity.UserRoleEntity;
import com.adminplus.exception.BizException;
import com.adminplus.repository.RoleRepository;
import com.adminplus.repository.UserRoleRepository;
import com.adminplus.service.AuthService;
import com.adminplus.service.PermissionService;
import com.adminplus.service.UserService;
import com.adminplus.vo.LoginResp;
import com.adminplus.vo.UserVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 认证服务实现
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;
    private final JwtEncoder jwtEncoder;
    private final UserService userService;
    private final UserRoleRepository userRoleRepository;
    private final RoleRepository roleRepository;
    private final PermissionService permissionService;

    @Override
    public LoginResp login(UserLoginReq req) {
        try {
            // 认证用户
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(req.username(), req.password())
            );

            // 生成 JWT Token
            Instant now = Instant.now();
            JwtClaimsSet claims = JwtClaimsSet.builder()
                    .issuer("adminplus")
                    .issuedAt(now)
                    .expiresAt(now.plus(24, ChronoUnit.HOURS))
                    .subject(authentication.getName())
                    .claim("userId", user.getId())
                    .claim("username", user.getUsername())
                    .claim("scope", "ROLE_USER")
                    .build();

            String token = jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();

            // 获取用户信息
            UserEntity user = userService.getUserByUsername(req.username());

            // 查询用户角色
            List<UserRoleEntity> userRoles = userRoleRepository.findByUserId(user.getId());
            List<String> roleNames = userRoles.stream()
                    .map(UserRoleEntity::getRoleId)
                    .map(roleId -> roleRepository.findById(roleId).orElse(null))
                    .filter(role -> role != null)
                    .map(RoleEntity::getName)
                    .collect(Collectors.toList());

            UserVO userVO = new UserVO(
                    user.getId(),
                    user.getUsername(),
                    user.getNickname(),
                    user.getEmail(),
                    user.getPhone(),
                    user.getAvatar(),
                    user.getStatus(),
                    roleNames,
                    user.getCreateTime(),
                    user.getUpdateTime()
            );

            // 查询用户权限
            List<String> permissions = permissionService.getUserPermissions(user.getId());

            return new LoginResp(token, "Bearer", userVO, permissions);

        } catch (AuthenticationException e) {
            log.error("登录失败: {}", e.getMessage());
            throw new BizException("用户名或密码错误");
        }
    }

    @Override
    public UserVO getCurrentUser(String username) {
        UserEntity user = userService.getUserByUsername(username);

        // 查询用户角色
        List<UserRoleEntity> userRoles = userRoleRepository.findByUserId(user.getId());
        List<String> roleNames = userRoles.stream()
                .map(UserRoleEntity::getRoleId)
                .map(roleId -> roleRepository.findById(roleId).orElse(null))
                .filter(role -> role != null)
                .map(RoleEntity::getName)
                .collect(Collectors.toList());

        return new UserVO(
                user.getId(),
                user.getUsername(),
                user.getNickname(),
                user.getEmail(),
                user.getPhone(),
                user.getAvatar(),
                user.getStatus(),
                roleNames,
                user.getCreateTime(),
                user.getUpdateTime()
        );
    }

    @Override
    public List<String> getCurrentUserPermissions(String username) {
        UserEntity user = userService.getUserByUsername(username);
        return permissionService.getUserPermissions(user.getId());
    }

    @Override
    public void logout() {
        // JWT 是无状态的，前端删除 Token 即可
        log.info("用户登出");
    }
}