import request from '@/utils/request'

/**
 * 获取统计数据
 * @returns {Promise} 返回统计数据（用户数、角色数、菜单数、日志数）
 */
export const getDashboardStats = () => {
  console.log('[API Dashboard] 获取统计数据')
  return request({
    url: '/v1/sys/dashboard/stats',
    method: 'get'
  })
}

/**
 * 获取用户增长趋势
 * @returns {Promise} 返回图表数据
 */
export const getUserGrowth = () => {
  console.log('[API Dashboard] 获取用户增长趋势')
  return request({
    url: '/v1/sys/dashboard/user-growth',
    method: 'get'
  })
}

/**
 * 获取角色分布
 * @returns {Promise} 返回图表数据
 */
export const getRoleDistribution = () => {
  console.log('[API Dashboard] 获取角色分布')
  return request({
    url: '/v1/sys/dashboard/role-distribution',
    method: 'get'
  })
}

/**
 * 获取菜单类型分布
 * @returns {Promise} 返回图表数据
 */
export const getMenuDistribution = () => {
  console.log('[API Dashboard] 获取菜单类型分布')
  return request({
    url: '/v1/sys/dashboard/menu-distribution',
    method: 'get'
  })
}

/**
 * 获取最近操作日志
 * @returns {Promise} 返回操作日志列表
 */
export const getRecentLogs = () => {
  console.log('[API Dashboard] 获取最近操作日志')
  return request({
    url: '/v1/sys/dashboard/recent-logs',
    method: 'get'
  })
}

/**
 * 获取系统信息
 * @returns {Promise} 返回系统信息
 */
export const getSystemInfo = () => {
  console.log('[API Dashboard] 获取系统信息')
  return request({
    url: '/v1/sys/dashboard/system-info',
    method: 'get'
  })
}

/**
 * 获取在线用户
 * @returns {Promise} 返回在线用户列表
 */
export const getOnlineUsers = () => {
  console.log('[API Dashboard] 获取在线用户')
  return request({
    url: '/v1/sys/dashboard/online-users',
    method: 'get'
  })
}