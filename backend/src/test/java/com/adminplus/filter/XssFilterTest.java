package com.adminplus.filter;

import com.adminplus.utils.XssRequestWrapper;
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
 * XSS 过滤器测试
 */
@ExtendWith(MockitoExtension.class)
class XssFilterTest {

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @Test
    void testDoFilter_WrapsRequest() throws Exception {
        // Given
        XssFilter filter = new XssFilter();

        // When
        filter.doFilter(request, response, filterChain);

        // Then
        verify(filterChain).doFilter(any(XssRequestWrapper.class), eq(response));
    }
}