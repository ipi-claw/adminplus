import { defineStore } from 'pinia'
import { ref } from 'vue'
import { login as loginApi, getCurrentUser, getCurrentUserPermissions } from '@/api/auth'
import { assignRoles as assignRolesApi, getUserRoleIds as getUserRoleIdsApi } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(sessionStorage.getItem('token') || '')
  const user = ref(JSON.parse(sessionStorage.getItem('user') || 'null'))
  const permissions = ref(JSON.parse(sessionStorage.getItem('permissions') || '[]'))

  const setToken = (val) => {
    token.value = val
    sessionStorage.setItem('token', val)
  }

  const setUser = (val) => {
    user.value = val
    sessionStorage.setItem('user', JSON.stringify(val))
  }

  const setPermissions = (val) => {
    permissions.value = val || []
    sessionStorage.setItem('permissions', JSON.stringify(val || []))
  }

  const login = async (username, password) => {
    const data = await loginApi({ username, password })
    setToken(data.token)
    setUser(data.user)
    setPermissions(data.permissions || [])
    return data
  }

  const getUserInfo = async () => {
    const data = await getCurrentUser()
    setUser(data)
    return data
  }

  const refreshPermissions = async () => {
    const data = await getCurrentUserPermissions()
    setPermissions(data || [])
    return data
  }

  const logout = () => {
    token.value = ''
    user.value = null
    permissions.value = []
    sessionStorage.removeItem('token')
    sessionStorage.removeItem('user')
    sessionStorage.removeItem('permissions')
  }

  /**
   * 检查是否有指定权限
   */
  const hasPermission = (permission) => {
    if (!permission) return true
    if (!permissions.value || permissions.value.length === 0) return false
    return permissions.value.includes(permission)
  }

  /**
   * 检查是否有任意一个权限
   */
  const hasAnyPermission = (permissionList) => {
    if (!permissionList || permissionList.length === 0) return true
    return permissionList.some(permission => hasPermission(permission))
  }

  /**
   * 检查是否有所有权限
   */
  const hasAllPermissions = (permissionList) => {
    if (!permissionList || permissionList.length === 0) return true
    return permissionList.every(permission => hasPermission(permission))
  }

  /**
   * 为用户分配角色
   */
  const assignRoles = async (userId, roleIds) => {
    return await assignRolesApi(userId, roleIds)
  }

  /**
   * 获取用户的角色ID列表
   */
  const getUserRoleIds = async (userId) => {
    return await getUserRoleIdsApi(userId)
  }

  return {
    token,
    user,
    permissions,
    setToken,
    setUser,
    setPermissions,
    login,
    getUserInfo,
    refreshPermissions,
    logout,
    hasPermission,
    hasAnyPermission,
    hasAllPermissions,
    assignRoles,
    getUserRoleIds
  }
})