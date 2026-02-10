package com.adminplus.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * XSS 过滤器简化测试
 * 避免依赖主代码中的复杂类
 */
@ExtendWith(MockitoExtension.class)
class XssFilterTest_simple {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @Test
    void testDoFilter_CallsFilterChain() throws Exception {
        // Given
        XssFilter filter = new XssFilter();

        // When
        filter.doFilter(request, response, filterChain);

        // Then - 验证 filterChain 被调用，但不检查具体参数类型
        verify(filterChain).doFilter(any(), eq(response));
    }

    @Test
    void testDoFilter_DoesNotThrowException() throws Exception {
        // Given
        XssFilter filter = new XssFilter();

        // When & Then - 确保方法不会抛出异常
        filter.doFilter(request, response, filterChain);
        
        // 如果执行到这里没有异常，测试通过
    }
}