import request from '@/utils/request'

export const getUserList = (params) => {
  return request({
    url: '/sys/users',
    method: 'get',
    params
  })
}

export const getUserById = (id) => {
  return request({
    url: `/sys/users/${id}`,
    method: 'get'
  })
}

export const createUser = (data) => {
  return request({
    url: '/sys/users',
    method: 'post',
    data
  })
}

export const updateUser = (id, data) => {
  return request({
    url: `/sys/users/${id}`,
    method: 'put',
    data
  })
}

export const deleteUser = (id) => {
  return request({
    url: `/sys/users/${id}`,
    method: 'delete'
  })
}

export const updateUserStatus = (id, status) => {
  return request({
    url: `/sys/users/${id}/status`,
    method: 'put',
    params: { status }
  })
}

export const resetPassword = (id, password) => {
  return request({
    url: `/sys/users/${id}/password`,
    method: 'put',
    params: { password }
  })
}

export const assignRoles = (userId, roleIds) => {
  return request({
    url: `/sys/users/${userId}/roles`,
    method: 'put',
    data: { roleIds }
  })
}

export const getUserRoleIds = (userId) => {
  return request({
    url: `/sys/users/${userId}/roles`,
    method: 'get'
  })
}