package com.adminplus.config;

import com.adminplus.filter.TokenBlacklistFilter;
import com.nimbusds.jose.JOSEException;
import com.nimbusds.jose.jwk.JWKSet;
import com.nimbusds.jose.jwk.RSAKey;
import com.nimbusds.jose.jwk.gen.RSAKeyGenerator;
import com.nimbusds.jose.jwk.source.ImmutableJWKSet;
import com.nimbusds.jose.jwk.source.JWKSource;
import com.nimbusds.jose.proc.SecurityContext;
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
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Value("${jwt.secret:}")
    private String jwtSecret;

    private final TokenBlacklistFilter tokenBlacklistFilter;
    private final Environment env;

    public SecurityConfig(TokenBlacklistFilter tokenBlacklistFilter, Environment env) {
        this.tokenBlacklistFilter = tokenBlacklistFilter;
        this.env = env;
    }

    /**
     * 密钥生成（开发环境）
     * 生产环境应从环境变量或配置文件读取
     */
    @Bean
    public RSAKey rsaKey() throws JOSEException {
        // 如果配置了 JWT 密钥，从环境变量读取
        if (jwtSecret != null && !jwtSecret.isEmpty()) {
            try {
                return RSAKey.parse(jwtSecret);
            } catch (Exception e) {
                throw new RuntimeException("Failed to parse JWT secret from environment", e);
            }
        }

        // 生产环境警告
        if (isProduction()) {
            throw new RuntimeException("生产环境必须配置 JWT 密钥（环境变量 JWT_SECRET）");
        }

        // 开发环境生成临时密钥
        return new RSAKeyGenerator(2048)
                .keyID("adminplus-key")
                .generate();
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
     */
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // 公开端点
                        .requestMatchers("/auth/login", "/auth/register", "/uploads/**", "/captcha/**").permitAll()
                        // Actuator - 根据环境限制访问
                        .requestMatchers("/actuator/health").permitAll()
                        .requestMatchers("/actuator/**").denyAll()
                        .anyRequest().authenticated()
                )
                .oauth2ResourceServer(oauth2 -> oauth2
                        .jwt(jwt -> jwt.jwtAuthenticationConverter(jwtAuthenticationConverter()))
                )
                .addFilterBefore(tokenBlacklistFilter, UsernamePasswordAuthenticationFilter.class)
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
     * 判断是否为生产环境
     */
    private boolean isProduction() {
        String env = this.env.getProperty("app.env", "dev");
        return "prod".equalsIgnoreCase(env) || "production".equalsIgnoreCase(env);
    }
}