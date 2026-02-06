import request from '@/utils/request'

export const getRoleList = () => {
  return request({
    url: '/sys/roles',
    method: 'get'
  })
}

export const getRoleById = (id) => {
  return request({
    url: `/sys/roles/${id}`,
    method: 'get'
  })
}

export const createRole = (data) => {
  return request({
    url: '/sys/roles',
    method: 'post',
    data
  })
}

export const updateRole = (id, data) => {
  return request({
    url: `/sys/roles/${id}`,
    method: 'put',
    data
  })
}

export const deleteRole = (id) => {
  return request({
    url: `/sys/roles/${id}`,
    method: 'delete'
  })
}

export const assignMenus = (id, menuIds) => {
  return request({
    url: `/sys/roles/${id}/menus`,
    method: 'put',
    data: menuIds
  })
}

export const getRoleMenuIds = (id) => {
  return request({
    url: `/sys/roles/${id}/menus`,
    method: 'get'
  })
}