/**
 * 统一验证规则
 */

/**
 * 验证邮箱
 * @param {string} email - 邮箱地址
 * @returns {boolean} - 是否有效
 */
export function isValidEmail(email) {
  const reg = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
  return reg.test(email)
}

/**
 * 验证手机号（中国大陆）
 * @param {string} phone - 手机号
 * @returns {boolean} - 是否有效
 */
export function isValidPhone(phone) {
  const reg = /^1[3-9]\d{9}$/
  return reg.test(phone)
}

/**
 * 验证用户名
 * @param {string} username - 用户名
 * @returns {boolean} - 是否有效
 */
export function isValidUsername(username) {
  const reg = /^[a-zA-Z0-9_]{4,20}$/
  return reg.test(username)
}

/**
 * 验证密码强度
 * @param {string} password - 密码
 * @returns {boolean} - 是否有效
 */
export function isValidPassword(password) {
  // 至少 8 位，包含字母和数字
  const reg = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$/
  return reg.test(password)
}

/**
 * 验证 URL
 * @param {string} url - URL 地址
 * @returns {boolean} - 是否有效
 */
export function isValidUrl(url) {
  try {
    new URL(url)
    return true
  } catch {
    return false
  }
}

/**
 * 验证身份证号（中国大陆）
 * @param {string} idCard - 身份证号
 * @returns {boolean} - 是否有效
 */
export function isValidIdCard(idCard) {
  const reg = /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/
  return reg.test(idCard)
}

/**
 * Element Plus 表单验证规则
 */
export const formRules = {
  /**
   * 邮箱验证规则
   */
  email: [
    { required: true, message: '请输入邮箱', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (!isValidEmail(value)) {
        callback(new Error('请输入有效的邮箱地址'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ],

  /**
   * 手机号验证规则
   */
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (!isValidPhone(value)) {
        callback(new Error('请输入有效的手机号'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ],

  /**
   * 用户名验证规则
   */
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 4, max: 20, message: '用户名长度在 4 到 20 个字符', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (!isValidUsername(value)) {
        callback(new Error('用户名只能包含字母、数字和下划线'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ],

  /**
   * 密码验证规则
   */
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 8, message: '密码至少 8 位', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (!isValidPassword(value)) {
        callback(new Error('密码必须包含字母和数字'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ],

  /**
   * 确认密码验证规则
   */
  confirmPassword: (passwordRef) => [
    { required: true, message: '请再次输入密码', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (value !== passwordRef.value) {
        callback(new Error('两次输入的密码不一致'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ],

  /**
   * URL 验证规则
   */
  url: [
    { required: true, message: '请输入 URL', trigger: 'blur' },
    { validator: (rule, value, callback) => {
      if (!isValidUrl(value)) {
        callback(new Error('请输入有效的 URL 地址'))
      } else {
        callback()
      }
    }, trigger: 'blur' }
  ]
}