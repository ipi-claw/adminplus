package com.adminplus.controller;

import com.adminplus.dto.UserLoginReq;
import com.adminplus.dto.UserLoginResp;
import com.adminplus.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 认证控制器测试
 */
@WebMvcTest(AuthController.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private AuthService authService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void testLogin_Success() throws Exception {
        // Given
        UserLoginReq loginReq = new UserLoginReq("admin", "admin123");
        UserLoginResp loginResp = new UserLoginResp("access-token", "refresh-token", "admin", 3600);

        when(authService.login(any(UserLoginReq.class))).thenReturn(loginResp);

        // When & Then
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.accessToken").value("access-token"))
                .andExpect(jsonPath("$.data.username").value("admin"));
    }

    @Test
    void testLogin_InvalidCredentials() throws Exception {
        // Given
        UserLoginReq loginReq = new UserLoginReq("admin", "wrong-password");

        when(authService.login(any(UserLoginReq.class)))
                .thenThrow(new com.adminplus.exception.BizException("用户名或密码错误"));

        // When & Then
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value(400))
                .andExpect(jsonPath("$.message").value("用户名或密码错误"));
    }

    @Test
    void testLogin_ValidationError() throws Exception {
        // Given
        UserLoginReq loginReq = new UserLoginReq("", "");

        // When & Then
        mockMvc.perform(post("/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isBadRequest());
    }
}