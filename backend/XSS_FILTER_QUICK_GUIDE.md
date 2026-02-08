# XssFilter 重复注册问题 - 快速指南

## 问题
```
Failed to register 'filter xssFilter' on the servlet context. Possibly already registered?
```

## 修复
在 `WebMvcConfig.java` 中添加了 `@ConditionalOnMissingBean` 注解。

```java
@Bean
@ConditionalOnMissingBean(name = "xssFilter")
public FilterRegistrationBean<XssFilter> xssFilterRegistration() {
    // ...
}
```

## 原理
确保只有在不存在同名 Bean 时才注册，避免重复注册。

## 验证
```bash
cd /root/.openclaw/workspace/AdminPlus/backend
./test-xss-filter.sh
```

## 详细报告
查看 `XSS_FILTER_FIX.md` 了解详细信息。

---

**修复时间**: 2026-02-08 01:51 GMT+8