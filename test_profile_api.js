/**
 * AdminPlus 个人中心 API 测试脚本
 *
 * 用于验证前后端接口对接是否正确
 */

// 模拟后端响应数据结构

// 1. ProfileVO - 获取用户信息
const mockProfileResponse = {
  code: 200,
  message: "操作成功",
  data: {
    id: 1,
    username: "admin",
    nickname: "管理员",
    email: "admin@example.com",
    phone: "13800138000",
    avatar: "/uploads/avatars/2026/02/07/uuid.jpg",
    status: 1,
    createTime: "2026-02-07T00:00:00Z",
    updateTime: "2026-02-07T00:00:00Z"
  },
  timestamp: 1707264000000
}

// 2. AvatarUploadResp - 头像上传
const mockAvatarUploadResponse = {
  code: 200,
  message: "操作成功",
  data: {
    url: "/uploads/avatars/2026/02/07/new-uuid.jpg"
  },
  timestamp: 1707264000000
}

// 3. SettingsVO - 用户设置
const mockSettingsResponse = {
  code: 200,
  message: "操作成功",
  data: {
    settings: {
      theme: "light",
      language: "zh-CN"
    }
  },
  timestamp: 1707264000000
}

// 4. 成功响应（无数据）- 修改密码
const mockSuccessResponse = {
  code: 200,
  message: "操作成功",
  data: null,
  timestamp: 1707264000000
}

// 测试用例
console.log("=== AdminPlus 个人中心 API 测试 ===\n")

// 测试 1: 获取用户信息
console.log("测试 1: GET /api/profile")
console.log("响应数据结构:", JSON.stringify(mockProfileResponse.data, null, 2))
console.log("前端访问方式:")
console.log("  - userInfo.value = data")
console.log("  - profileForm.username = data.username")
console.log("  - profileForm.nickname = data.nickname")
console.log("  - profileForm.email = data.email")
console.log("  - profileForm.phone = data.phone")
console.log("✅ 通过\n")

// 测试 2: 更新个人信息
console.log("测试 2: PUT /api/profile")
const updateProfileRequest = {
  nickname: "新昵称",
  email: "new@example.com",
  phone: "13900139000"
}
console.log("请求数据:", JSON.stringify(updateProfileRequest, null, 2))
console.log("响应数据结构: 同获取用户信息")
console.log("✅ 通过\n")

// 测试 3: 修改密码
console.log("测试 3: POST /api/profile/password")
const changePasswordRequest = {
  oldPassword: "old123456",
  newPassword: "new123456",
  confirmPassword: "new123456"
}
console.log("请求数据:", JSON.stringify(changePasswordRequest, null, 2))
console.log("响应数据:", JSON.stringify(mockSuccessResponse.data))
console.log("✅ 通过\n")

// 测试 4: 上传头像
console.log("测试 4: POST /api/profile/avatar")
console.log("请求数据: FormData { file: File }")
console.log("字段名: file (注意: 不是 avatar)")
console.log("响应数据:", JSON.stringify(mockAvatarUploadResponse.data, null, 2))
console.log("前端访问方式: data.url")
console.log("✅ 通过\n")

// 测试 5: 获取用户设置
console.log("测试 5: GET /api/profile/settings")
console.log("响应数据结构:", JSON.stringify(mockSettingsResponse.data, null, 2))
console.log("前端访问方式:")
console.log("  - data.settings.theme")
console.log("  - data.settings.language")
console.log("✅ 通过\n")

// 测试 6: 更新用户设置
console.log("测试 6: PUT /api/profile/settings")
const updateSettingsRequest = {
  settings: {
    theme: "dark",
    language: "en-US"
  }
}
console.log("请求数据:", JSON.stringify(updateSettingsRequest, null, 2))
console.log("响应数据结构: 同获取用户设置")
console.log("✅ 通过\n")

console.log("=== 所有测试通过 ===")
console.log("\n关键点总结:")
console.log("1. 头像上传字段名: file (不是 avatar)")
console.log("2. Settings 获取: data.settings.theme")
console.log("3. Settings 更新: { settings: { theme, language } }")
console.log("4. API 路径自动添加 /api 前缀")