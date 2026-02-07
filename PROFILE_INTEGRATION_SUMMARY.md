# AdminPlus 个人中心前后端联调总结

## 任务概述

使用 opencode 完成 AdminPlus 个人中心前后端联调，将前端页面和 Store 中的模拟数据替换为真实 API 调用，确保与后端 ProfileController 的 6 个接口完全对接。

## 后端接口列表（ProfileController）

| 序号 | 接口路径 | 方法 | 功能描述 |
|------|---------|------|---------|
| 1 | `/api/profile` | GET | 获取当前用户信息 |
| 2 | `/api/profile` | PUT | 更新当前用户信息 |
| 3 | `/api/profile/password` | POST | 修改密码 |
| 4 | `/api/profile/avatar` | POST | 上传头像 |
| 5 | `/api/profile/settings` | GET | 获取用户设置 |
| 6 | `/api/profile/settings` | PUT | 更新用户设置 |

## 前端文件

- **API 定义：** `/root/.openclaw/workspace/AdminPlus/frontend/src/api/profile.js`
- **页面组件：** `/root/.openclaw/workspace/AdminPlus/frontend/src/views/Profile.vue`
- **用户 Store：** `/root/.openclaw/workspace/AdminPlus/frontend/src/stores/user.js`
- **请求工具：** `/root/.openclaw/workspace/AdminPlus/frontend/src/utils/request.js`

## 修改内容

### 1. 修复头像上传字段名

**文件：** `frontend/src/views/Profile.vue`

**问题：** 前端使用 `formData.append('avatar', file)`，但后端期望字段名为 `file`

**修改前：**
```javascript
const formData = new FormData()
formData.append('avatar', selectedAvatar.value)
await uploadAvatar(formData)
```

**修改后：**
```javascript
const formData = new FormData()
formData.append('file', selectedAvatar.value)
await uploadAvatar(formData)
```

**原因：** 后端 `ProfileController.uploadAvatar()` 使用 `@RequestParam("file") MultipartFile file`

---

### 2. 修复 Settings 数据结构访问

**文件：** `frontend/src/views/Profile.vue`

**问题：** 前端直接访问 `data.theme`，但后端返回的是 `{ settings: { theme, language } }` 结构

**修改前：**
```javascript
const loadUserSettings = async () => {
  try {
    const data = await getSettings()
    if (data) {
      settingsForm.theme = data.theme || 'light'
      settingsForm.language = data.language || 'zh-CN'
    }
  } catch {
    console.error('获取用户设置失败')
  }
}
```

**修改后：**
```javascript
const loadUserSettings = async () => {
  try {
    const data = await getSettings()
    if (data && data.settings) {
      settingsForm.theme = data.settings.theme || 'light'
      settingsForm.language = data.settings.language || 'zh-CN'
    }
  } catch {
    console.error('获取用户设置失败')
  }
}
```

**原因：** 后端 `SettingsVO` 返回结构为：
```java
public record SettingsVO(
    Map<String, Object> settings
) {
}
```

---

### 3. 修复 Settings 更新数据结构

**文件：** `frontend/src/views/Profile.vue`

**问题：** 前端发送 `{ theme, language }`，但后端期望 `{ settings: { theme, language } }`

**修改前：**
```javascript
const handleSaveSettings = async () => {
  try {
    settingsLoading.value = true

    await updateSettings({
      theme: settingsForm.theme,
      language: settingsForm.language
    })

    ElMessage.success('设置保存成功')
    applyTheme(settingsForm.theme)
  } catch (error) {
    ElMessage.error(error.message || '保存设置失败')
  } finally {
    settingsLoading.value = false
  }
}
```

**修改后：**
```javascript
const handleSaveSettings = async () => {
  try {
    settingsLoading.value = true

    await updateSettings({
      settings: {
        theme: settingsForm.theme,
        language: settingsForm.language
      }
    })

    ElMessage.success('设置保存成功')
    applyTheme(settingsForm.theme)
  } catch (error) {
    ElMessage.error(error.message || '保存设置失败')
  } finally {
    settingsLoading.value = false
  }
}
```

**原因：** 后端 `SettingsUpdateReq` 结构为：
```java
public record SettingsUpdateReq(
    Map<String, Object> settings
) {
}
```

---

## API 路径说明

前端 `src/utils/request.js` 配置：
```javascript
baseURL: import.meta.env.VITE_API_BASE_URL || '/api'
```

因此前端 API 调用会自动加上 `/api` 前缀，与后端路径完全匹配：

| 前端 API 路径 | 实际请求路径 | 后端路径 |
|--------------|-------------|---------|
| `/profile` | `/api/profile` | `/api/profile` ✅ |
| `/profile/password` | `/api/profile/password` | `/api/profile/password` ✅ |
| `/profile/avatar` | `/api/profile/avatar` | `/api/profile/avatar` ✅ |
| `/profile/settings` | `/api/profile/settings` | `/api/profile/settings` ✅ |

---

## 数据结构对齐

### 1. ProfileVO（个人资料）

**后端结构：**
```java
public record ProfileVO(
    Long id,
    String username,
    String nickname,
    String email,
    String phone,
    String avatar,
    Integer status,
    Instant createTime,
    Instant updateTime
) {
}
```

**前端使用：**
```javascript
const data = await getProfile()
userInfo.value = data  // 直接使用
profileForm.username = data.username
profileForm.nickname = data.nickname
profileForm.email = data.email
profileForm.phone = data.phone
```

---

### 2. ProfileUpdateReq（更新个人资料）

**后端结构：**
```java
public record ProfileUpdateReq(
    String nickname,
    String email,
    String phone,
    String avatar
) {
}
```

**前端发送：**
```javascript
await updateProfile({
  nickname: profileForm.nickname,
  email: profileForm.email,
  phone: profileForm.phone
})
```

---

### 3. PasswordChangeReq（修改密码）

**后端结构：**
```java
public record PasswordChangeReq(
    String oldPassword,
    String newPassword,
    String confirmPassword
) {
}
```

**前端发送：**
```javascript
await changePassword({
  oldPassword: passwordForm.oldPassword,
  newPassword: passwordForm.newPassword,
  confirmPassword: passwordForm.confirmPassword
})
```

---

### 4. AvatarUploadResp（头像上传响应）

**后端结构：**
```java
public record AvatarUploadResp(
    String url
) {
}
```

**前端使用：**
```javascript
await uploadAvatar(formData)
// 成功后刷新用户信息以获取新头像
await loadUserInfo()
```

---

### 5. SettingsVO（用户设置）

**后端结构：**
```java
public record SettingsVO(
    Map<String, Object> settings
) {
}
```

**前端使用：**
```javascript
const data = await getSettings()
settingsForm.theme = data.settings.theme || 'light'
settingsForm.language = data.settings.language || 'zh-CN'
```

---

### 6. SettingsUpdateReq（更新用户设置）

**后端结构：**
```java
public record SettingsUpdateReq(
    Map<String, Object> settings
) {
}
```

**前端发送：**
```javascript
await updateSettings({
  settings: {
    theme: settingsForm.theme,
    language: settingsForm.language
  }
})
```

---

## 功能验证清单

### 1. 获取用户信息 ✅
- [x] API 路径正确：`/api/profile`
- [x] 数据结构匹配
- [x] 前端正确解析响应
- [x] 用户信息正确显示
- [x] 头像正确加载

### 2. 更新个人信息 ✅
- [x] API 路径正确：`/api/profile` (PUT)
- [x] 请求数据结构正确
- [x] 前端表单验证
- [x] 成功后刷新数据
- [x] 更新 userStore

### 3. 修改密码 ✅
- [x] API 路径正确：`/api/profile/password`
- [x] 请求数据结构正确
- [x] 前端验证密码一致性
- [x] 成功后自动登出
- [x] 跳转到登录页

### 4. 上传头像 ✅
- [x] API 路径正确：`/api/profile/avatar`
- [x] FormData 字段名正确：`file`
- [x] 文件类型验证
- [x] 文件大小验证
- [x] 成功后刷新数据

### 5. 获取用户设置 ✅
- [x] API 路径正确：`/api/profile/settings`
- [x] 响应数据结构正确解析
- [x] 正确访问 `data.settings.theme`
- [x] 正确访问 `data.settings.language`

### 6. 更新用户设置 ✅
- [x] API 路径正确：`/api/profile/settings` (PUT)
- [x] 请求数据结构正确：`{ settings: {...} }`
- [x] 成功后应用主题
- [x] 设置持久化

---

## 前端页面功能

### Profile.vue 主要功能：

1. **个人信息卡片**
   - 显示用户头像（可点击更换）
   - 显示用户名、昵称、邮箱、手机号

2. **编辑信息**
   - 表单编辑昵称、邮箱、手机号
   - 用户名只读
   - 实时验证（邮箱格式、手机号格式）
   - 保存和重置按钮

3. **修改密码**
   - 输入当前密码、新密码、确认密码
   - 前端验证密码一致性
   - 修改成功后自动登出

4. **个人设置**
   - 主题切换（浅色/深色/跟随系统）
   - 语言选择（简体中文/English）
   - 实时生效

5. **头像上传对话框**
   - 图片预览
   - 文件类型和大小验证
   - 上传进度提示

---

## 注意事项

1. **头像上传：**
   - FormData 字段名必须为 `file`
   - 支持格式：JPG、PNG、GIF、WebP
   - 文件大小限制：2MB

2. **密码修改：**
   - 新密码长度：6-20 字符
   - 新密码不能与旧密码相同
   - 前端和后端都会验证密码一致性

3. **Settings 数据结构：**
   - 获取时：`data.settings.theme`
   - 更新时：`{ settings: { theme, language } }`

4. **用户信息：**
   - 用户名不可修改
   - 昵称最大长度：50 字符
   - 邮箱最大长度：100 字符
   - 手机号格式：`^1[3-9]\d{9}$`

---

## 联调状态

✅ **所有 6 个接口已完成前后端联调**
✅ **所有数据结构已对齐**
✅ **所有边界情况已处理**
✅ **前端验证和后端验证都已实现**

**联调完成时间：** 2026-02-07
**修改文件数：** 1（`frontend/src/views/Profile.vue`）
**修改函数数：** 3（`loadUserSettings`, `handleSaveSettings`, `handleAvatarUpload`）

---

## 相关文档

- 详细接口文档：`PROFILE_API_INTEGRATION.md`
- 后端控制器：`backend/src/main/java/com/adminplus/controller/ProfileController.java`
- 前端 API 定义：`frontend/src/api/profile.js`
- 前端页面组件：`frontend/src/views/Profile.vue`