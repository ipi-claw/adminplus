import auth from './auth'

/**
 * 注册自定义指令
 */
export function setupDirectives(app) {
  app.directive('auth', auth)
}