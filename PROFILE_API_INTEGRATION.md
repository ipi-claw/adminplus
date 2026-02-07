# AdminPlus 个人中心前后端联调文档

## 概述

本文档记录了 AdminPlus 个人中心前后端接口的对接情况。

## 后端接口（ProfileController）

| 序号 | 接口路径 | 方法 | 功能 |
|------|---------|------|------|
| 1 | `/api/profile` | GET | 获取当前用户信息 |
| 2 | `/api/profile` | PUT | 更新当前用户信息 |
| 3 | `/api/profile/password` | POST | 修改密码 |
| 4 | `/api/profile/avatar` | POST | 上传头像 |
| 5 | `/api/profile/settings` | GET | 获取用户设置 |
| 6 | `/api/profile/settings` | PUT | 更新用户设置 |

## 前端 API 定义（src/api/profile.js）

所有接口已正确定义，路径与后端匹配（通过 request.js 的 baseURL 自动添加 `/api` 前缀）。

### 1. getProfile()

**请求：**
```javascript
getProfile()
```

**响应数据结构（ProfileVO）：**
```json
{
  "id": 1,
  "username": "admin",
  "nickname": "管理员",
  "email": "admin@example.com",
  "phone": "13800138000",
  "avatar": "/uploads/avatars/2026/02/07/xxx.jpg",
  "status": 1,
  "createTime": "2026-02-07T00:00:00Z",
  "updateTime": "2026-02-07T00:00:00Z"
}
```

**前端使用：**
- 在 `loadUserInfo()` 中调用
- 数据存储在 `userInfo` 响应式变量中
- 同时更新 userStore 中的用户信息

---

### 2. updateProfile(data)

**请求：**
```javascript
updateProfile({
  nickname: "管理员",
  email: "admin@example.com",
  phone: "13800138000"
})
```

**请求数据结构（ProfileUpdateReq）：**
```json
{
  "nickname": "管理员",
  "email": "admin@example.com",
  "phone": "13800138000",
  "avatar": "/uploads/avatars/2026/02/07/xxx.jpg"
}
```

**响应数据结构：** 同 getProfile

**前端使用：**
- 在 `handleUpdateProfile()` 中调用
- 只传递需要更新的字段
- 成功后重新加载用户信息

---

### 3. changePassword(data)

**请求：**
```javascript
changePassword({
  oldPassword: "old123456",
  newPassword: "new123456",
  confirmPassword: "new123456"
})
```

**请求数据结构（PasswordChangeReq）：**
```json
{
  "oldPassword": "old123456",
  "newPassword": "new123456",
  "confirmPassword": "new123456"
}
```

**响应：** 无数据（204 或 200 with null）

**前端使用：**
- 在 `handleChangePassword()` 中调用
- 前端验证两次密码是否一致
- 成功后自动登出并跳转到登录页

---

### 4. uploadAvatar(formData)

**请求：**
```javascript
const formData = new FormData()
formData.append('file', file)
uploadAvatar(formData)
```

**请求数据结构：**
- Content-Type: `multipart/form-data`
- 字段名：`file`（注意：不是 `avatar`）
- 文件类型：image/jpeg, image/png, image/gif, image/webp
- 文件大小：≤ 2MB

**响应数据结构（AvatarUploadResp）：**
```json
{
  "url": "/uploads/avatars/2026/02/07/uuid.jpg"
}
```

**前端使用：**
- 在 `handleAvatarUpload()` 中调用
- 使用 FormData 上传文件
- 字段名必须为 `file`
- 成功后重新加载用户信息以更新头像

---

### 5. getSettings()

**请求：**
```javascript
getSettings()
```

**响应数据结构（SettingsVO）：**
```json
{
  "settings": {
    "theme": "light",
    "language": "zh-CN"
  }
}
```

**前端使用：**
- 在 `loadUserSettings()` 中调用
- 数据通过 `data.settings.theme` 访问
- 填充到 settingsForm 中

---

### 6. updateSettings(data)

**请求：**
```javascript
updateSettings({
  settings: {
    theme: "light",
    language: "zh-CN"
  }
})
```

**请求数据结构（SettingsUpdateReq）：**
```json
{
  "settings": {
    "theme": "light",
    "language": "zh-CN"
  }
}
```

**响应数据结构：** 同 getSettings

**前端使用：**
- 在 `handleSaveSettings()` 中调用
- 必须使用 `{ settings: {...} }` 结构
- 成功后应用主题设置

---

## 已修复的问题

### 1. 头像上传字段名问题
- **问题：** 前端使用 `formData.append('avatar', file)`
- **修复：** 改为 `formData.append('file', file)`
- **原因：** 后端 `@RequestParam("file")` 期望字段名为 `file`

### 2. Settings 数据结构访问问题
- **问题：** 前端使用 `data.theme` 直接访问
- **修复：** 改为 `data.settings.theme`
- **原因：** 后端 SettingsVO 返回 `{ settings: {...} }` 结构

### 3. Settings 更新数据结构问题
- **问题：** 前端发送 `{ theme, language }`
- **修复：** 改为 `{ settings: { theme, language } }`
- **原因：** 后端 SettingsUpdateReq 期望 `{ settings: {...} }` 结构

---

## API 路径说明

由于前端 `src/utils/request.js` 中配置了：
```javascript
baseURL: import.meta.env.VITE_API_BASE_URL || '/api'
```

因此前端 API 调用中的路径会自动加上 `/api` 前缀：

| 前端 API 路径 | 实际请求路径 |
|--------------|-------------|
| `/profile` | `/api/profile` |
| `/profile/password` | `/api/profile/password` |
| `/profile/avatar` | `/api/profile/avatar` |
| `/profile/settings` | `/api/profile/settings` |

---

## 前端页面（Profile.vue）

### 功能模块

1. **个人信息卡片**
   - 显示用户头像、用户名、昵称、邮箱、手机号
   - 支持点击头像更换头像

2. **编辑信息**
   - 表单编辑昵称、邮箱、手机号
   - 用户名只读
   - 实时验证

3. **修改密码**
   - 输入当前密码、新密码、确认密码
   - 前端验证密码一致性
   - 成功后自动登出

4. **个人设置**
   - 主题切换（浅色/深色/跟随系统）
   - 语言选择（简体中文/English）
   - 实时生效

### 数据流

```
用户操作 → 表单验证 → API 调用 → 成功提示 → 刷新数据 → 更新 UI
```

---

## 测试建议

### 1. 获取用户信息
- 访问个人中心页面
- 检查用户信息是否正确显示
- 检查头像是否正确加载

### 2. 更新个人信息
- 修改昵称、邮箱、手机号
- 点击保存
- 检查是否成功更新
- 刷新页面验证数据持久化

### 3. 修改密码
- 输入正确的旧密码和新密码
- 点击修改
- 检查是否成功修改并自动登出
- 使用新密码重新登录

### 4. 上传头像
- 点击更换头像
- 选择图片（JPG/PNG，≤ 2MB）
- 点击确认上传
- 检查头像是否更新

### 5. 获取设置
- 访问个人中心页面
- 检查主题和语言设置是否正确显示

### 6. 更新设置
- 修改主题或语言
- 点击保存
- 检查设置是否生效
- 刷新页面验证数据持久化

---

## 注意事项

1. **头像上传：**
   - 文件名必须为 `file`
   - 文件类型限制：JPG、PNG、GIF、WebP
   - 文件大小限制：2MB

2. **密码修改：**
   - 新密码长度：6-20 字符
   - 新密码不能与旧密码相同
   - 前端和后端都会验证密码一致性

3. **Settings 结构：**
   - 获取时：`data.settings.theme`
   - 更新时：`{ settings: { theme, language } }`

4. **用户信息：**
   - 用户名不可修改
   - 昵称最大长度：50 字符
   - 邮箱最大长度：100 字符
   - 手机号格式：`^1[3-9]\d{9}$`

---

## 联调状态

✅ 所有 6 个接口已完成前后端联调
✅ 所有数据结构已对齐
✅ 所有边界情况已处理
✅ 前端验证和后端验证都已实现

**联调完成时间：** 2026-02-07