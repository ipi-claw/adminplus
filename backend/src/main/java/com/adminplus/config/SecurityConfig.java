package com.adminplus.config;

import com.adminplus.filter.TokenBlacklistFilter;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.gen.RSAKeyGenerator;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtGrantedAuthoritiesConverter;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Spring Security 配置
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
@Slf4j
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${jwt.secret:}")
    private String jwtSecret;

    @Value("${spring.cors.allowed-origins:http://localhost:5173,http://localhost:3000}")
    private String corsAllowedOrigins;

    private final TokenBlacklistFilter tokenBlacklistFilter;
    private final Environment env;

    public SecurityConfig(TokenBlacklistFilter tokenBlacklistFilter, Environment env) {
        this.tokenBlacklistFilter = tokenBlacklistFilter;
        this.env = env;
    }

    /**
     * 密钥生成（开发环境）
     * 生产环境强制从环境变量读取 JWT_SECRET
     *
     * 安全要求：
     * - 生产环境必须配置 JWT_SECRET 环境变量
     * - 密钥长度至少 256 位（RSA 2048 位）
     * - 开发环境生成临时密钥并输出警告日志
     */
    @Bean
    public RSAKey rsaKey() throws JOSEException {
        // 生产环境：强制从环境变量读取 JWT_SECRET
        if (isProduction()) {
            if (jwtSecret == null || jwtSecret.isEmpty()) {
                throw new RuntimeException(
                    "生产环境必须配置 JWT 密钥！请设置环境变量 JWT_SECRET（至少 256 位）"
                );
            }

            try {
                RSAKey rsaKey = RSAKey.parse(jwtSecret);

                // 验证密钥长度（至少 2048 位，即 256 字节）
                int keySize = rsaKey.toRSAPublicKey().getModulus().bitLength();
                if (keySize < 2048) {
                    throw new RuntimeException(
                        String.format("JWT 密钥长度不足！当前：%d 位，要求：至少 2048 位", keySize)
                    );
                }

                log.info("JWT 密钥已从环境变量加载，密钥长度：{} 位", keySize);
                return rsaKey;

            } catch (Exception e) {
                throw new RuntimeException("JWT 密钥解析失败！请检查环境变量 JWT_SECRET 格式是否正确", e);
            }
        }

        // 开发环境：生成临时密钥
        RSAKey tempKey = new RSAKeyGenerator(2048)
                .keyID("adminplus-dev-key")
                .generate();

        log.warn("⚠️  开发环境：使用临时生成的 JWT 密钥（仅限开发环境使用）");
        log.warn("⚠️  警告：临时密钥每次重启都会变化，生产环境必须配置 JWT_SECRET 环境变量！");
        log.warn("⚠️  如何配置：export JWT_SECRET=<your-rsa-key-json>");

        return tempKey;
    }

    /**
     * JWT 编码器（用于登录时签发 Token）
     */
    @Bean
    public JwtEncoder jwtEncoder(RSAKey rsaKey) {
        var jwkSet = new JWKSet(rsaKey);
        JWKSource<SecurityContext> jwkSource = new ImmutableJWKSet<>(jwkSet);
        return new NimbusJwtEncoder(jwkSource);
    }

    /**
     * JWT 解码器（用于验证 Token）
     */
    @Bean
    public JwtDecoder jwtDecoder(RSAKey rsaKey) {
        try {
            return NimbusJwtDecoder.withPublicKey(rsaKey.toRSAPublicKey()).build();
        } catch (JOSEException e) {
            throw new RuntimeException("Failed to create JWT decoder", e);
        }
    }

    /**
     * 密码编码器
     */
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * 认证管理器
     */
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    /**
     * JWT 权限转换器
     */
    @Bean
    public JwtAuthenticationConverter jwtAuthenticationConverter() {
        var grantedAuthoritiesConverter = new JwtGrantedAuthoritiesConverter();
        grantedAuthoritiesConverter.setAuthorityPrefix("ROLE_");
        grantedAuthoritiesConverter.setAuthoritiesClaimName("scope");

        var jwtAuthenticationConverter = new JwtAuthenticationConverter();
        jwtAuthenticationConverter.setJwtGrantedAuthoritiesConverter(grantedAuthoritiesConverter);
        return jwtAuthenticationConverter;
    }

    /**
     * 安全过滤器链
     *
     * CSRF 保护说明：
     * - 对于使用 JWT 认证的 REST API（/api/**），CSRF 保护通过忽略请求来实现
     * - 这是因为 JWT Token 本身已经提供了防 CSRF 保护（通过 Authorization 头）
     * - 如果前端使用 Cookie 存储 JWT，则需要启用 CSRF 保护
     * - 当前实现：API 端点忽略 CSRF（JWT Bearer Token 方式），其他端点启用 CSRF
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                // 启用 CSRF 保护，使用 CookieCsrfTokenRepository
                // 注意：对于使用 Bearer Token 的 REST API，可以安全地忽略 CSRF
                // 如果使用 Cookie 存储 JWT，应该移除 ignoringRequestMatchers 配置
                .csrf(csrf -> csrf
                        .csrfTokenRepository(org.springframework.security.web.csrf.CookieCsrfTokenRepository.withHttpOnlyFalse())
                        // 仅忽略认证相关端点（登录、注册）和公开端点
                        // 其他 API 端点使用 JWT Bearer Token，不依赖 Cookie，可安全忽略 CSRF
                        .ignoringRequestMatchers(
                                "/auth/**",           // 认证相关端点（登录、注册、登出）
                                "/v1/auth/**",        // v1 版本的认证相关端点
                                "/captcha/**",        // 验证码端点
                                "/v1/captcha/**",     // v1 版本的验证码端点
                                "/uploads/**",        // 公开的上传文件访问
                                "/actuator/health"    // 健康检查端点
                        )
                )
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 公开端点
                        .requestMatchers("/auth/login", "/auth/register", "/uploads/**", "/captcha/**").permitAll()
                        .requestMatchers("/v1/auth/login", "/v1/auth/register", "/v1/uploads/**", "/v1/captcha/**").permitAll()
                        // Actuator - 根据环境限制访问
                        .requestMatchers("/actuator/health").permitAll()
                        .requestMatchers("/actuator/**").denyAll()
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
                )
                .addFilterBefore(tokenBlacklistFilter, UsernamePasswordAuthenticationFilter.class)
                // 配置 CORS - 限制跨域访问
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                // 添加安全头
                .headers(headers -> headers
                        .contentSecurityPolicy(csp -> csp.policyDirectives("default-src 'self'"))
                        .frameOptions(frame -> frame.sameOrigin())
                        .httpStrictTransportSecurity(hsts -> hsts
                                .includeSubDomains(true)
                                .maxAgeInSeconds(31536000)
                                .preload(true)
                        )
                )
                .build();
    }

    /**
     * CORS 配置源
     * 从配置文件读取允许的域名，限制跨域访问，防止 CSRF 攻击
     */
    @Bean
    public org.springframework.web.cors.CorsConfigurationSource corsConfigurationSource() {
        org.springframework.web.cors.CorsConfiguration configuration = new org.springframework.web.cors.CorsConfiguration();

        // 从配置文件读取允许的域名
        if (corsAllowedOrigins != null && !corsAllowedOrigins.trim().isEmpty()) {
            String[] origins = corsAllowedOrigins.split(",");
            configuration.setAllowedOriginPatterns(java.util.Arrays.asList(origins));
            log.info("CORS 已配置允许的域名: {}", java.util.Arrays.toString(origins));
        } else {
            // 如果未配置，仅允许本地开发（生产环境会报错）
            if (isProduction()) {
                throw new RuntimeException(
                    "生产环境必须配置 CORS 允许的域名！请设置环境变量 CORS_ALLOWED_ORIGINS"
                );
            }
            configuration.setAllowedOriginPatterns(java.util.List.of("http://localhost:5173", "http://localhost:3000"));
            log.warn("⚠️  开发环境：CORS 使用默认配置（仅允许本地开发服务器）");
            log.warn("⚠️  警告：生产环境必须配置 CORS_ALLOWED_ORIGINS 环境变量！");
        }

        configuration.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(java.util.List.of("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        org.springframework.web.cors.UrlBasedCorsConfigurationSource source = new org.springframework.web.cors.UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    /**
     * 判断是否为生产环境
     */
    private boolean isProduction() {
        String env = this.env.getProperty("app.env", "dev");
        return "prod".equalsIgnoreCase(env) || "production".equalsIgnoreCase(env);
    }
}