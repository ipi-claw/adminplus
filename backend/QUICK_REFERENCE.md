# AdminPlus 后端修复快速参考

## 修复清单

### 1. 编译错误修复 ✅
```diff
- SecurityConfig.java:103 - 删除无效的 .httpSecurity.oauth2.resourceserver.opaque(false)
- DatabaseHealthIndicator.java:9 - javax.sql.DataSource → jakarta.sql.DataSource
- CaptchaController.java:13 - javax.imageio.ImageIO → jakarta.imageio.ImageIO
```

### 2. 配置改进 ✅
```diff
+ logback-spring.xml - 新建日志配置文件
+ application.yml - 添加 jwt.secret 配置和注释
+ AdminPlusApplication.java - 修正端口 8080 → 8081
```

---

## 快速测试

### 编译测试
```bash
cd /root/.openclaw/workspace/AdminPlus/backend
./test-start.sh
```

### Docker 启动
```bash
cd /root/.openclaw/workspace/AdminPlus
docker-compose up -d
```

### 健康检查
```bash
curl http://localhost:8081/api/actuator/health
```

### API 文档
```
http://localhost:8081/api/swagger-ui.html
```

---

## 环境变量（生产环境）

```bash
export JWT_SECRET="your-secure-jwt-secret-key"
export POSTGRES_USER="your-db-user"
export POSTGRES_PASSWORD="your-db-password"
export DB_URL="jdbc:postgresql://your-host:5432/adminplus"
```

---

## 端口配置

- **API 服务**: 8081
- **数据库**: 5432
- **Redis**: 6379
- **前端**: 80

---

## 关键文件

| 文件 | 说明 |
|------|------|
| `FIXES_SUMMARY.md` | 完整修复报告 |
| `ISSUES_FIXED.md` | 问题详细说明 |
| `test-start.sh` | 测试启动脚本 |
| `logback-spring.xml` | 日志配置 |

---

## 日志级别

| 环境 | Root | 应用 | Security | Hibernate |
|------|------|------|----------|-----------|
| Dev | INFO | DEBUG | DEBUG | DEBUG |
| Prod | WARN | WARN | ERROR | ERROR |

---

## JWT 配置

| 配置项 | 开发环境 | 生产环境 |
|--------|----------|----------|
| 密钥来源 | 自动生成 | JWT_SECRET 环境变量 |
| 过期时间 | 2 小时 | 2 小时 |
| 算法 | RS256 | RS256 |

---

## 修复统计

- 🔴 严重：3 个
- 🟡 中等：2 个
- 🟢 轻微：1 个
- ✅ 总计：6 个

---

**最后更新**: 2026-02-08 01:51 GMT+8