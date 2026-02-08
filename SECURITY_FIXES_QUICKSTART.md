# AdminPlus P0 安全漏洞修复 - 快速参考

## 🚨 修复概览

本次修复解决了 3 个 P0 级别的安全漏洞：

1. **JWT 密钥硬编码风险** - 生产环境强制从环境变量读取
2. **CORS 配置过于宽松** - 从配置文件读取允许的域名
3. **前端加密密钥硬编码** - 从环境变量读取并验证长度

## 📋 快速部署检查清单

### 后端环境变量（生产环境必须配置）

```bash
# JWT 密钥（RSA 格式，至少 2048 位）
export JWT_SECRET=<your-rsa-jwk-key>

# CORS 允许的域名（多个域名用逗号分隔）
export CORS_ALLOWED_ORIGINS=https://admin.example.com,https://api.example.com

# 数据库配置
export DB_URL=postgresql://postgres:5432/adminplus
export DB_USERNAME=postgres
export DB_PASSWORD=<your-db-password>
```

### 前端环境变量（生产环境必��配置）

在 `frontend/.env.production` 文件中：

```bash
VITE_API_BASE_URL=/api
VITE_ENCRYPTION_KEY=<your-32-byte-key>
```

## 🔑 密钥生成

### 快速生成（推荐使用脚本）

```bash
# 运行密钥生成脚本
./generate-security-keys.sh
```

### 手动生成

**前端加密密钥（32 字节）：**
```bash
openssl rand -base64 32
```

**JWT RSA 密钥（2048 位）：**
```bash
# 生成私钥
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out jwt_private.pem

# 生成公钥
openssl rsa -in jwt_private.pem -pubout -out jwt_public.pem
```

## 📁 修改的文件

### 后端

- ✅ `backend/src/main/java/com/adminplus/config/SecurityConfig.java`
  - JWT 密钥验证逻辑
  - CORS 配置从文件读取
  - 密钥长度验证

- ✅ `backend/src/main/resources/application.yml`
  - 添加 CORS 配置项

- ✅ `backend/src/main/resources/application-dev.yml`
  - 开发环境 CORS 配置

- ✅ `backend/src/main/resources/application-prod.yml`
  - 生产环境 CORS 配置

### 前端

- ✅ `frontend/src/utils/encryption.js`
  - 从环境变量读取加密密钥
  - 密钥长度验证（至少 32 字节）
  - 明确的错误提示

- ✅ `frontend/.env.example`
  - 添加 VITE_ENCRYPTION_KEY 示例

- ✅ `frontend/.env.development`
  - 配置开发环境测试密钥

- ✅ `frontend/.env.production`
  - 添加生产环境密钥配置

### 文档

- ✅ `SECURITY_FIXES.md` - 详细的修复文档
- ✅ `generate-security-keys.sh` - 密钥生成脚本
- ✅ `SECURITY_FIXES_QUICKSTART.md` - 本文件

## 🧪 验证步骤

### 1. 后端验证

**开发环境：**
```bash
cd backend
mvn spring-boot:run

# 检查日志中应该看到：
# - JWT 警告："使用生成的临时 JWT 密钥（仅限开发环境）"
# - CORS 信息："CORS 使用默认开发配置（仅允许 http://localhost:5173）"
```

**生产环境：**
```bash
# 配置环境变量
export JWT_SECRET=<your-rsa-jwk-key>
export CORS_ALLOWED_ORIGINS=https://admin.example.com

# 启动应用
java -jar adminplus.jar

# 应用应该正常启动，无错误信息
```

### 2. 前端验证

**开发环境：**
```bash
cd frontend
npm run dev

# 应用应该正常启动，加密功能正常
```

**生产环境：**
```bash
# 确认 .env.production 中已配置密钥
cat .env.production
# 应该包含：VITE_ENCRYPTION_KEY=<your-32-byte-key>

# 构建生产版本
npm run build

# 部署后测试加密功能
```

## ⚠️ 常见错误

### 错误 1：生产环境 JWT_SECRET 未配置

```
错误：生产环境必须配置 JWT 密��（环境变量 JWT_SECRET）
解决：export JWT_SECRET=<your-rsa-jwk-key>
```

### 错误 2：生产环境 CORS_ALLOWED_ORIGINS 未配置

```
错误：生产环境必须配置 CORS 允许的域名（环境变量 CORS_ALLOWED_ORIGINS）
解决：export CORS_ALLOWED_ORIGINS=https://admin.example.com
```

### 错误 3：前端加密密钥未配置

```
错误：未配置加密密钥 VITE_ENCRYPTION_KEY
解决：在 .env.production 中添加：VITE_ENCRYPTION_KEY=<your-32-byte-key>
```

### 错误 4：加密密钥长度不足

```
错误：加密密钥长度不足（至少 32 字节）
解决：使用以下命令生成：openssl rand -base64 32
```

### 错误 5：JWT 密钥长度不足

```
错误：JWT 密钥长度不足（必须至少 2048 位）
解决：使用 2048 位或更长的 RSA 密钥
```

## 🔒 安全最佳实践

1. **密钥管理**
   - ✅ 不要将密钥提交到版本控制系统
   - ✅ 使用环境变量或密钥管理服务存储
   - ✅ 定期轮换密钥（建议每 6-12 个月）

2. **CORS 配置**
   - ✅ 生产环境只允许可信的域名
   - ✅ 避免使用通配符 `*`
   - ✅ 定期审查允许的域名列表

3. **监控和日志**
   - ✅ 监控应用日志中的安全警告
   - ✅ 记录失败的认证尝试
   - ✅ 定期审计安全配置

4. **测试**
   - ✅ 在生产环境部署前进行安全测试
   - ✅ 定期进行渗透测试
   - ✅ 验证所有安全配置生效

## 📞 获取帮助

- 📖 详细文档：`SECURITY_FIXES.md`
- 🔑 密钥生成：`./generate-security-keys.sh`
- 🐛 问题反馈：提交 Issue

## 🔄 回滚方案

如果修复后出现问题，可以回滚到之前的版本：

```bash
# 查看提交历史
git log --oneline

# 回滚到指定版本
git revert <commit-hash>

# 恢复环境变量配置
# 移除 JWT_SECRET 和 CORS_ALLOWED_ORIGINS 环境变量（开发环境）
# 恢复前端 .env 文件中的硬编码密钥
```

## ✅ 部署前最后检查

- [ ] 后端环境变量已配置（生产环境）
- [ ] 前端环境变量已配置（生产环境）
- [ ] JWT 密钥长度至少 2048 位
- [ ] CORS 允许的域名已配置
- [ ] 加密密钥长度至少 32 字节
- [ ] 应用启动无错误
- [ ] 日志中无安全警告
- [ ] 功能测试通过
- [ ] 安全测试通过

---

**重要提醒：**
- 🚨 生产环境部署前必须完成所有安全配置
- 🚨 不要使用开发环境的测试密钥部署生产
- 🚨 定期轮换密钥以确保安全
- 🚨 监控应用日志中的安全警告信息

**祝部署顺利！** 🎉