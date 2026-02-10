package com.adminplus.controller;

import com.adminplus.dto.UserCreateReq;
import com.adminplus.dto.UserUpdateReq;
import com.adminplus.entity.UserEntity;
import com.adminplus.service.UserService;
import com.adminplus.vo.UserVO;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * 用户控制器测试
 */
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetUserList_Success() throws Exception {
        // Given
        UserVO user1 = new UserVO("1", "user1", "用户1", "user1@example.com", "13800138001", null, 1, null, null, null);
        UserVO user2 = new UserVO("2", "user2", "用户2", "user2@example.com", "13800138002", null, 1, null, null, null);
        List<UserVO> users = List.of(user1, user2);

        when(userService.getUserList()).thenReturn(users);

        // When & Then
        mockMvc.perform(get("/user/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data[0].username").value("user1"))
                .andExpect(jsonPath("$.data[1].username").value("user2"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetUserById_Success() throws Exception {
        // Given
        UserVO user = new UserVO("1", "user1", "用户1", "user1@example.com", "13800138001", null, 1, null, null, null);

        when(userService.getUserById("1")).thenReturn(user);

        // When & Then
        mockMvc.perform(get("/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.username").value("user1"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateUser_Success() throws Exception {
        // Given
        UserCreateReq req = new UserCreateReq("newuser", "password123", "新用户", "new@example.com", "13800138000", null);
        UserVO user = new UserVO("1", "newuser", "新用户", "new@example.com", "13800138000", null, 1, null, null, null);

        when(userService.createUser(any(UserCreateReq.class))).thenReturn(user);

        // When & Then
        mockMvc.perform(post("/user")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.username").value("newuser"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateUser_Success() throws Exception {
        // Given
        UserUpdateReq req = new UserUpdateReq("1", "updateduser", "更新用户", "updated@example.com", "13800138000", null, 1);
        UserVO user = new UserVO("1", "updateduser", "更新用户", "updated@example.com", "13800138000", null, 1, null, null, null);

        when(userService.updateUser(any(UserUpdateReq.class))).thenReturn(user);

        // When & Then
        mockMvc.perform(put("/user")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.username").value("updateduser"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteUser_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testGetUserList_Unauthorized() throws Exception {
        // When & Then - 未认证用户访问
        mockMvc.perform(get("/user/list"))
                .andExpect(status().isUnauthorized());
    }
}