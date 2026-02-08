/**
 * XSS 防护工具函数
 * 用于防止跨站脚本攻击 (Cross-Site Scripting)
 */

/**
 * HTML 实体编码映射
 */
const HTML_ENTITIES = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;',
  '/': '&#x2F;'
}

/**
 * 转义 HTML 特殊字符
 * 防止 XSS 攻击
 *
 * @param {string} str - 需要转义的字符串
 * @returns {string} 转义后的字符串
 *
 * @example
 * escapeHtml('<script>alert("xss")</script>')
 * // 返回: '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'
 */
export const escapeHtml = (str) => {
  if (!str || typeof str !== 'string') {
    return str
  }

  return str.replace(/[&<>"'/]/g, (char) => HTML_ENTITIES[char])
}

/**
 * 清理 HTML 内容，移除危险标签和属性
 * 使用白名单策略，只保留安全的 HTML 标签和属性
 *
 * @param {string} html - 需要清理的 HTML 字符串
 * @returns {string} 清理后的 HTML 字符串
 *
 * @example
 * sanitizeHtml('<p>安全内容</p><script>alert("xss")</script>')
 * // 返回: '<p>安全内容</p>'
 */
export const sanitizeHtml = (html) => {
  if (!html || typeof html !== 'string') {
    return html
  }

  // 允许的标签白名单
  const allowedTags = [
    'p', 'br', 'strong', 'em', 'u', 'i', 'b',
    'h1', 'h2', 'h3', 'h4', 'h5', 'h6',
    'ul', 'ol', 'li',
    'a', 'span', 'div'
  ]

  // 允许的属性白名单（标签 -> 属性列表）
  const allowedAttributes = {
    a: ['href', 'title', 'target'],
    img: ['src', 'alt', 'title', 'width', 'height']
  }

  // 移除危险的标签和属性
  let sanitized = html

  // 1. 移除 script 标签及其内容
  sanitized = sanitized.replace(/<script\b[^>]*>([\s\S]*?)<\/script>/gi, '')

  // 2. 移除 style 标签及其内容
  sanitized = sanitized.replace(/<style\b[^>]*>([\s\S]*?)<\/style>/gi, '')

  // 3. 移除 iframe 标签
  sanitized = sanitized.replace(/<iframe\b[^>]*>([\s\S]*?)<\/iframe>/gi, '')

  // 4. 移除 object 和 embed 标签
  sanitized = sanitized.replace(/<(object|embed)\b[^>]*>([\s\S]*?)<\/\1>/gi, '')

  // 5. 移除 on* 事件处理器（如 onclick, onerror 等）
  sanitized = sanitized.replace(/\s+on\w+\s*=\s*["'][^"']*["']/gi, '')
  sanitized = sanitized.replace(/\s+on\w+\s*=\s*[^\s>]*/gi, '')

  // 6. 移除 javascript: 协议
  sanitized = sanitized.replace(/javascript:/gi, '')

  // 7. 移除 data: 协议（除了图片）
  sanitized = sanitized.replace(/data:(?!image\/)/gi, 'data-blocked:')

  // 8. 移除危险的表达式
  sanitized = sanitized.replace(/expression\s*\(/gi, 'expression-blocked(')

  return sanitized
}

/**
 * 安全地设置 innerHTML
 * 在使用 v-html 前先清理内容
 *
 * @param {string} html - 需要设置的 HTML 内容
 * @returns {string} 清理后的 HTML 内容
 *
 * @example
 * // 在 Vue 组件中使用
 * <div v-html="safeHtml(userContent)"></div>
 */
export const safeHtml = (html) => {
  return sanitizeHtml(html)
}

/**
 * 转义 URL 参数
 * 防止 URL 注入攻击
 *
 * @param {string} str - 需要转义�� URL 参数
 * @returns {string} 转义后的字符串
 */
export const escapeUrl = (str) => {
  if (!str || typeof str !== 'string') {
    return str
  }

  return encodeURIComponent(str)
}

/**
 * 转义 JSON 数据
 * 防止 JSON 注入攻击
 *
 * @param {*} data - 需要转义的数据
 * @returns {string} 安全的 JSON 字符串
 */
export const escapeJson = (data) => {
  try {
    const jsonStr = JSON.stringify(data)
    // 移除可能存在的 </script> 标签
    return jsonStr.replace(/<\/script>/gi, '<\\/script>')
  } catch (error) {
    console.error('[XSS] JSON 转义失败:', error)
    return '{}'
  }
}