/**
 * 加密工具函数
 * 用于保护 sessionStorage 中的敏感数据
 *
 * 安全说明：
 * - 使用 AES-GCM 加密算法（Authenticated Encryption）
 * - 密钥从环境变量 VITE_ENCRYPTION_KEY 读取（生产环境必须配置）
 * - 每次加密生成新的 IV（初始化向量）
 * - 包含认证标签，防止篡改
 */

// 从环境变量读取加密密钥
// 生产环境必须通过 .env.production 配置 VITE_ENCRYPTION_KEY
const ENV_ENCRYPTION_KEY = import.meta.env.VITE_ENCRYPTION_KEY

/**
 * 验证密钥长度（至少 32 字节，用于 256 位加密）
 * @param {string} key - 密钥字符串
 * @throws {Error} 如果密钥长度不足
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
 * @returns {string} 加密密钥
 * @throws {Error} 如果密钥未配置或长度不足
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

/**
 * 将字符串转换为 Uint8Array
 * @param {string} str - 输入字符串
 * @returns {Uint8Array}
 */
const stringToBuffer = (str) => {
  return new TextEncoder().encode(str)
}

/**
 * 将 Uint8Array 转换为 Base64 字符串
 * @param {Uint8Array} buffer - 输入缓冲区
 * @returns {string} Base64 编码的字符串
 */
const bufferToBase64 = (buffer) => {
  const bytes = new Uint8Array(buffer)
  let binary = ''
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i])
  }
  return btoa(binary)
}

/**
 * 将 Base64 字符串转换为 Uint8Array
 * @param {string} base64 - Base64 编码的字符串
 * @returns {Uint8Array}
 */
const base64ToBuffer = (base64) => {
  const binary = atob(base64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes
}

/**
 * 派生加密密钥
 * @param {string} password - 密码
 * @returns {Promise<CryptoKey>}
 */
const deriveKey = async (password) => {
  const passwordBuffer = stringToBuffer(password)

  // 导入密码材料
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    passwordBuffer,
    'PBKDF2',
    false,
    ['deriveKey']
  )

  // 派生 AES-GCM 密钥
  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: stringToBuffer('AdminPlus-Salt'), // 固定盐值
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    {
      name: 'AES-GCM',
      length: 256
    },
    false,
    ['encrypt', 'decrypt']
  )
}

/**
 * 加密数据
 * @param {any} data - 要加密的数据（会被 JSON 序列化）
 * @returns {Promise<string>} 加密后的 Base64 字符串（包含 IV 和认证标签）
 */
export const encrypt = async (data) => {
  try {
    // 获取并验证密钥
    const secretKey = getSecretKey()

    // 将数据序列化为 JSON
    const jsonStr = JSON.stringify(data)
    const dataBuffer = stringToBuffer(jsonStr)

    // 派生密钥
    const key = await deriveKey(secretKey)

    // 生成随机 IV
    const iv = crypto.getRandomValues(new Uint8Array(12))

    // 加密数据
    const encrypted = await crypto.subtle.encrypt(
      {
        name: 'AES-GCM',
        iv
      },
      key,
      dataBuffer
    )

    // 组合 IV + 加密数据
    const combined = new Uint8Array(iv.length + encrypted.byteLength)
    combined.set(iv)
    combined.set(new Uint8Array(encrypted), iv.length)

    // 转换为 Base64
    return bufferToBase64(combined)
  } catch (error) {
    console.error('[Encryption] 加密失败:', error)
    throw new Error('加密失败: ' + error.message)
  }
}

/**
 * 解密数据
 * @param {string} encryptedData - 加密的 Base64 字符串
 * @returns {Promise<any>} 解密后的原始数据
 */
export const decrypt = async (encryptedData) => {
  try {
    // 获取并验证密钥
    const secretKey = getSecretKey()

    // 从 Base64 转换为字节数组
    const combined = base64ToBuffer(encryptedData)

    // 提取 IV（前 12 字节）
    const iv = combined.slice(0, 12)

    // 提取加密数据（剩余字节）
    const encrypted = combined.slice(12)

    // 派生密钥
    const key = await deriveKey(secretKey)

    // 解密数据
    const decrypted = await crypto.subtle.decrypt(
      {
        name: 'AES-GCM',
        iv
      },
      key,
      encrypted
    )

    // 转换为字符串并解析 JSON
    const jsonStr = new TextDecoder().decode(decrypted)
    return JSON.parse(jsonStr)
  } catch (error) {
    console.error('[Encryption] 解密失败:', error)
    throw new Error('解密失败: ' + error.message)
  }
}

/**
 * 加密并存储到 sessionStorage
 * @param {string} key - 存储键
 * @param {any} data - 要存储的数据
 */
export const setEncryptedSession = async (key, data) => {
  try {
    const encrypted = await encrypt(data)
    sessionStorage.setItem(key, encrypted)
  } catch (error) {
    console.error(`[Encryption] 存储 ${key} 失败:`, error)
    // 加密失败时，不存储数据
  }
}

/**
 * 从 sessionStorage 读取并解密
 * @param {string} key - 存储键
 * @param {any} defaultValue - 默认值（解密失败时返回）
 * @returns {Promise<any>} 解密后的数据
 */
export const getEncryptedSession = async (key, defaultValue = null) => {
  try {
    const encrypted = sessionStorage.getItem(key)
    if (!encrypted) {
      return defaultValue
    }
    return await decrypt(encrypted)
  } catch (error) {
    console.error(`[Encryption] 读取 ${key} 失败:`, error)
    return defaultValue
  }
}

/**
 * 移除 sessionStorage 中的数据
 * @param {string} key - 存储键
 */
export const removeEncryptedSession = (key) => {
  sessionStorage.removeItem(key)
}

/**
 * 同步加密数据（包装函数）
 * 注意：这个函数是异步的，但返回 Promise，使用时需要 await
 * 为了兼容现有代码，保持函数名不变
 * @param {any} data - 要加密的数据
 * @returns {Promise<string>} 加密后的 Base64 字符串
 */
export const encryptData = async (data) => {
  return await encrypt(data)
}

/**
 * 同步解密数据（包装函数）
 * 注意：这个函数是异步的，但返回 Promise，使用时需要 await
 * 为了兼容现有代码，保持函数名不变
 * @param {string} encryptedData - 加密的 Base64 字符串
 * @returns {Promise<any>} 解密后的原始数据
 */
export const decryptData = async (encryptedData) => {
  return await decrypt(encryptedData)
}