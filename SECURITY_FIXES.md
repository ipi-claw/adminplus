# Security Fixes Documentation - P0 级别安全漏洞修复

本文档记录了对 AdminPlus 项目 P0 级别安全漏洞的修复详情。

## 修复日期
2026-02-08

## 修复的安全问题

### 1. JWT 密钥硬编码风险 🔴 P0

**问题描述：**
- 原实现在开发环境生成临时 RSA 密钥，缺少密钥长度验证
- 生产环境依赖环境变量但有潜在的安全隐患

**修复内容：**

#### 1.1 修改文件
- `backend/src/main/java/com/adminplus/config/SecurityConfig.java`

#### 1.2 修复详情

**生产环境强制从环境变量读取 JWT_SECRET：**
```java
// 生产环境必须配置 JWT 密钥
if (isProduction()) {
    if (jwtSecret == null || jwtSecret.trim().isEmpty()) {
        throw new RuntimeException(
            "生产环境必须配置 JWT 密钥（环境变量 JWT_SECRET）"
        );
    }
}
```

**开发环境生成临时密钥并添加警告日志：**
```java
if (!isProduction()) {
    log.warn("==============================================");
    log.warn("警告：使用生成的临时 JWT 密钥（仅限开发环境）");
    log.warn("生产环境必须通过环境变量 JWT_SECRET 配置密钥");
    log.warn("==============================================");
    return new RSAKeyGenerator(2048)
            .keyID("adminplus-key")
            .generate();
}
```

**添加密钥长度验证（至少 2048 位）：**
```java
// 验证密钥长度（至少 2048 位 = 256 字节）
try {
    RSAKey key = RSAKey.parse(jwtSecret);
    int keySize = key.toRSAPublicKey().getModulus().bitLength();
    if (keySize < 2048) {
        throw new RuntimeException(
            "JWT 密钥长度不足（必须至少 2048 位）。当前密钥长度：" + keySize + " 位"
        );
    }
    return key;
} catch (Exception e) {
    if (!isProduction()) {
        log.warn("JWT secret 解析失败，使用生成的临时密钥（仅限开发环境）");
        return new RSAKeyGenerator(2048)
                .keyID("adminplus-key")
                .generate();
    }
    throw new RuntimeException("Failed to parse JWT secret from environment", e);
}
```

#### 1.3 配置要求

**开发环境：**
- 无需配置，自动生成临时密钥
- 控制台会显示警告日志

**生产环境：**
- 必须通过环境变量 `JWT_SECRET` 配置 RSA 密钥
- 密钥长度至少 2048 位（推荐 4096 位）

**生成 JWT 密钥的命令：**
```bash
# 生成 2048 位 RSA 密钥（推荐）
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 | openssl rsa -pubout -outform PEM

# 或者使用 JWK 格式
java -cp "path/to/jose.jar" com.nimbusds.jose.jwk.gen.RSAKeyGenerator 2048
```

---

### 2. CORS 配置过于宽松 🔴 P0

**问题描述：**
- 原实现使用 `AllowedOriginPatterns("*")` 允许所有域名跨域访问
- 存在 CSRF 攻击风险

**修复内容：**

#### 2.1 修改文件
- `backend/src/main/java/com/adminplus/config/SecurityConfig.java`
- `backend/src/main/resources/application.yml`
- `backend/src/main/resources/application-dev.yml`
- `backend/src/main/resources/application-prod.yml`

#### 2.2 修复详情

**SecurityConfig.java - 从配置文件读取允许的域名：**
```java
@Value("${spring.cors.allowed-origins:}")
private String corsAllowedOrigins;

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
                "生产环境必须配置 CORS 允许的域名（环境变量 CORS_ALLOWED_ORIGINS）"
            );
        }
        configuration.setAllowedOriginPatterns(java.util.List.of("http://localhost:5173"));
        log.warn("CORS 使用默认开发配置（仅允许 http://localhost:5173）");
    }

    configuration.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
    configuration.setAllowedHeaders(java.util.List.of("*"));
    configuration.setAllowCredentials(true);
    configuration.setMaxAge(3600L);

    org.springframework.web.cors.UrlBasedCorsConfigurationSource source = new org.springframework.web.cors.UrlBasedCorsConfigurationSource();
    source.registerCorsConfiguration("/**", configuration);
    return source;
}
```

**application.yml - 添加 CORS 配置：**
```yaml
spring:
  # CORS 配置
  cors:
    # 允许的跨域来源（生产环境必须配置为具体的域名，使用逗号分隔）
    # 示例: http://localhost:5173,https://admin.example.com
    allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:5173}
```

**application-dev.yml - 开发环境配置：**
```yaml
spring:
  cors:
    allowed-origins: http://localhost:5173
```

**application-prod.yml - 生产环境配置：**
```yaml
spring:
  cors:
    allowed-origins: ${CORS_ALLOWED_ORIGINS:}
```

#### 2.3 配置要求

**开发环境：**
- 默认允许 `http://localhost:5173`
- 可通过环境变量 `CORS_ALLOWED_ORIGINS` 修改

**生产环境：**
- 必须通过环境变量 `CORS_ALLOWED_ORIGINS` 配置允许的域名
- 多个域名使用逗号分隔

**配置示例：**
```bash
# 单域名
export CORS_ALLOWED_ORIGINS=https://admin.example.com

# 多域名
export CORS_ALLOWED_ORIGINS=https://admin.example.com,https://api.example.com
```

---

### 3. 前端加密密钥硬编码 🔴 P0

**问题描述：**
- 原实现使用硬编码的密钥 `AdminPlus-Secret-Key-2024`
- 密钥长度不足（仅 28 字节，不满足 32 字节要求）
- 生产环境存在严重安全隐患

**修复内容：**

#### 3.1 修改文件
- `frontend/src/utils/encryption.js`
- `frontend/.env.example`
- `frontend/.env.development`
- `frontend/.env.production`

#### 3.2 修复详情

**encryption.js - 从环境变量读取加密密钥：**
```javascript
// 从环境变量读取加密密钥
const ENV_ENCRYPTION_KEY = import.meta.env.VITE_ENCRYPTION_KEY

/**
 * 验证密钥长度（至少 32 字节，用于 256 位加密）
 */
const validateKeyLength = (key) => {
  if (!key || key.length < 32) {
    throw new Error(
      '加密密钥长度不足（至少 32 字节）。' +
      '请在环境变量 VITE_ENCRYPTION_KEY 中配置有效的加密密钥。' +
      '可以使用以下命令生成：openssl rand -base64 32'
    )
  }
}

/**
 * 获取加密密钥
 */
const getSecretKey = () => {
  // 验证密钥是否配置
  if (!ENV_ENCRYPTION_KEY) {
    throw new Error(
      '未配置加密密钥 VITE_ENCRYPTION_KEY。' +
      '请在 .env.development 或 .env.production 文件中添加：' +
      'VITE_ENCRYPTION_KEY=<your-secret-key>' +
      '建议使用以下命令生成：openssl rand -base64 32'
    )
  }

  // 验证密钥长度
  validateKeyLength(ENV_ENCRYPTION_KEY)

  return ENV_ENCRYPTION_KEY
}
```

**在 encrypt 和 decrypt 函数中使用：**
```javascript
export const encrypt = async (data) => {
  try {
    // 获取并验证密钥
    const secretKey = getSecretKey()
    // ... 加密逻辑
  } catch (error) {
    throw new Error('加密失败: ' + error.message)
  }
}

export const decrypt = async (encryptedData) => {
  try {
    // 获取并验证密钥
    const secretKey = getSecretKey()
    // ... 解密逻辑
  } catch (error) {
    throw new Error('解密失败: ' + error.message)
  }
}
```

#### 3.3 配置要求

**开发环境：**
- 在 `.env.development` 中配置测试密钥
- 密钥长度至少 32 字节

**生产环境：**
- 在 `.env.production` 中配置强密钥
- 密钥长度至少 32 字节

**生成加密密钥的命令：**
```bash
# 生成 32 字节的 Base64 编码密钥（推荐）
openssl rand -base64 32
```

**配置示例：**
```bash
# .env.development
VITE_ENCRYPTION_KEY=AdminPlus-Dev-Test-Key-2024-32Bytes

# .env.production
VITE_ENCRYPTION_KEY=<使用 openssl rand -base64 32 生成的密钥>
```

---

## 部署检查清单

### 后端部署检查

- [ ] 确认环境变量 `JWT_SECRET` 已配置（生产环境）
- [ ] 确认环境变量 `CORS_ALLOWED_ORIGINS` 已配置（生产环境）
- [ ] 确认环境变量 `DB_URL`、`DB_USERNAME`、`DB_PASSWORD` 已配置
- [ ] 验证应用启动时没有 JWT 密钥相关的错误
- [ ] 验证应用启动时没有 CORS 配置相关的错误
- [ ] 检查日志中是否有关于 JWT 或 CORS 的警告信息

### 前端部署检查

- [ ] 确认 `.env.production` 中 `VITE_ENCRYPTION_KEY` 已配置
- [ ] 确认加密密钥长度至少 32 字节
- [ ] 验证前端构建成功
- [ ] 测试加密和解密功能正常
- [ ] 确认控制台没有密钥相关的错误信息

### 安全验证

- [ ] 测试 JWT Token 生成和验证功能
- [ ] 测试跨域请求是否被正确限制
- [ ] 测试前端数据加密和解密功能
- [ ] 验证未授权的跨域请求被拒绝
- [ ] 验证加密密钥长度验证生效

---

## 环境变量配置模板

### Docker Compose 配置示例

```yaml
version: '3.8'

services:
  backend:
    environment:
      # 生产环境必须配置
      - JWT_SECRET=${JWT_SECRET}
      - CORS_ALLOWED_ORIGINS=${CORS_ALLOWED_ORIGINS}

      # 数据库配置
      - DB_URL=postgresql://postgres:5432/adminplus
      - DB_USERNAME=postgres
      - DB_PASSWORD=${DB_PASSWORD}
```

### Kubernetes ConfigMap 示例

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: adminplus-config
data:
  CORS_ALLOWED_ORIGINS: "https://admin.example.com,https://api.example.com"
---
apiVersion: v1
kind: Secret
metadata:
  name: adminplus-secrets
type: Opaque
stringData:
  JWT_SECRET: ${JWT_SECRET}
  DB_PASSWORD: ${DB_PASSWORD}
```

---

## 修复验证步骤

### 1. JWT 密钥验证

**开发环境：**
```bash
# 启动应用
mvn spring-boot:run

# 检查日志，应该看到警告信息
# "警告：使用生成的临时 JWT 密钥（仅限开发环境）"
```

**生产环境：**
```bash
# 不配置 JWT_SECRET 启动应用
java -jar adminplus.jar

# 应该看到错误信息
# "生产环境必须配置 JWT 密钥（环境变量 JWT_SECRET）"

# 配置 JWT_SECRET 后启动
export JWT_SECRET=<your-rsa-key>
java -jar adminplus.jar

# 应用应该正常启动
```

### 2. CORS 配置验证

**开发环境：**
```bash
# 启动应用
mvn spring-boot:run

# 检查日志，应该看到
# "CORS 使用默认开发配置（仅允许 http://localhost:5173）"
```

**生产环境：**
```bash
# 不配置 CORS_ALLOWED_ORIGINS 启动应用
java -jar adminplus.jar

# 应该看到错误信息
# "生产环境必须配置 CORS 允���的域名（环境变量 CORS_ALLOWED_ORIGINS）"

# 配置 CORS_ALLOWED_ORIGINS 后启动
export CORS_ALLOWED_ORIGINS=https://admin.example.com
java -jar adminplus.jar

# 应用应该正常启动
```

### 3. 前端加密密钥验证

**开发环境：**
```bash
# 确认 .env.development 中已配置
cat .env.development
# 应该包含：VITE_ENCRYPTION_KEY=AdminPlus-Dev-Test-Key-2024-32Bytes

# 启动开发服务器
npm run dev

# 测试加密功能
# 在浏览器控制台测试，应该正常工作
```

**生产环境：**
```bash
# 确认 .env.production 中已配置
cat .env.production
# 应该包含：VITE_ENCRYPTION_KEY=<your-32-byte-key>

# 构建生产版本
npm run build

# 部署后测试加密功能
# 应该正常工作，控制台没有错误
```

---

## 回滚方案

如果修复后出现问题，可以按以下步骤回滚：

1. **回滚代码：**
   ```bash
   git revert <commit-hash>
   ```

2. **恢复环境变量配置：**
   - 移除 `JWT_SECRET` 环境变量（开发环境）
   - 移除 `CORS_ALLOWED_ORIGINS` 环境变量（开发环境）
   - 恢复前端 `.env` 文件中的硬编码密钥

3. **重新部署应用**

---

## 联系方式

如有问题，请联系：
- 技术支持：[email]
- 安全团队：[email]

---

**重要提示：**
- 生产环境部署前必须完成所有安全配置
- 定期轮换 JWT 密钥和加密密钥
- 监控应用日志中的安全警告信息
- 定期进行安全审计和渗透测试