/**
 * 常量定义
 */

// 菜单类型
export const MENU_TYPE = {
  DIRECTORY: 0, // 目录
  MENU: 1,      // 菜单
  BUTTON: 2     // 按钮
}

// 菜单类型文本映射
export const MENU_TYPE_TEXT = {
  [MENU_TYPE.DIRECTORY]: '目录',
  [MENU_TYPE.MENU]: '菜单',
  [MENU_TYPE.BUTTON]: '按钮'
}

// 菜单类型标签类型映射
export const MENU_TYPE_TAG = {
  [MENU_TYPE.DIRECTORY]: '',
  [MENU_TYPE.MENU]: 'success',
  [MENU_TYPE.BUTTON]: 'warning'
}

// 状态
export const STATUS = {
  DISABLED: 0, // 禁用
  ENABLED: 1   // 正常
}

// 可见性
export const VISIBLE = {
  HIDDEN: 0,   // 隐藏
  SHOWN: 1     // 显示
}

// 响应码
export const RESPONSE_CODE = {
  SUCCESS: 200,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  SERVER_ERROR: 500
}

// HTTP 状态码
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  INTERNAL_SERVER_ERROR: 500
}

// 请求超时时间（毫秒）
export const REQUEST_TIMEOUT = 30000

// 分页默认配置
export const PAGINATION = {
  PAGE_SIZE: 10,
  PAGE_SIZES: [10, 20, 50, 100]
}

// 存储键名
export const STORAGE_KEYS = {
  TOKEN: 'token',
  USER: 'user',
  LANGUAGE: 'language',
  THEME: 'theme'
}

// 默认排序值
export const DEFAULT_SORT_ORDER = 0