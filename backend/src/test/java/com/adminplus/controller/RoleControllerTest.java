package com.adminplus.controller;

import com.adminplus.dto.RoleCreateReq;
import com.adminplus.dto.RoleUpdateReq;
import com.adminplus.vo.RoleVO;
import com.adminplus.service.RoleService;
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
 * 角色控制器测试
 */
@WebMvcTest(RoleController.class)
class RoleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private RoleService roleService;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetRoleList_Success() throws Exception {
        // Given
        RoleVO role1 = new RoleVO("1", "admin", "管理员", "系统管理员", 1, 1, null, null);
        RoleVO role2 = new RoleVO("2", "user", "普通用户", "普通用户角色", 1, 2, null, null);
        List<RoleVO> roles = List.of(role1, role2);

        when(roleService.getRoleList()).thenReturn(roles);

        // When & Then
        mockMvc.perform(get("/role/list"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data[0].name").value("管理员"))
                .andExpect(jsonPath("$.data[1].name").value("普通用户"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetRoleById_Success() throws Exception {
        // Given
        RoleVO role = new RoleVO("1", "admin", "管理员", "系统管理员", 1, 1, null, null);

        when(roleService.getRoleById("1")).thenReturn(role);

        // When & Then
        mockMvc.perform(get("/role/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("管理员"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateRole_Success() throws Exception {
        // Given
        RoleCreateReq req = new RoleCreateReq("editor", "编辑者", "内容编辑角色", 1, 3);
        RoleVO role = new RoleVO("3", "editor", "编辑者", "内容编辑角色", 1, 3, null, null);

        when(roleService.createRole(any(RoleCreateReq.class))).thenReturn(role);

        // When & Then
        mockMvc.perform(post("/role")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("编辑者"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateRole_Success() throws Exception {
        // Given
        RoleUpdateReq req = new RoleUpdateReq("1", "admin", "超级管理员", "系统超级管理员", 1, 1);
        RoleVO role = new RoleVO("1", "admin", "超级管理员", "系统超级管理员", 1, 1, null, null);

        when(roleService.updateRole(any(RoleUpdateReq.class))).thenReturn(role);

        // When & Then
        mockMvc.perform(put("/role")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200))
                .andExpect(jsonPath("$.data.name").value("超级管理员"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteRole_Success() throws Exception {
        // When & Then
        mockMvc.perform(delete("/role/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.code").value(200));
    }

    @Test
    void testGetRoleList_Unauthorized() throws Exception {
        // When & Then - 未认证用户访问
        mockMvc.perform(get("/role/list"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(roles = "USER")
    void testGetRoleList_Forbidden() throws Exception {
        // When & Then - 普通用户尝试访问管理员接口
        mockMvc.perform(get("/role/list"))
                .andExpect(status().isForbidden());
    }
}