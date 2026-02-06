import request from '@/utils/request'

export const getMenuTree = () => {
  return request({
    url: '/sys/menus/tree',
    method: 'get'
  })
}

export const getMenuById = (id) => {
  return request({
    url: `/sys/menus/${id}`,
    method: 'get'
  })
}

export const createMenu = (data) => {
  return request({
    url: '/sys/menus',
    method: 'post',
    data
  })
}

export const updateMenu = (id, data) => {
  return request({
    url: `/sys/menus/${id}`,
    method: 'put',
    data
  })
}

export const deleteMenu = (id) => {
  return request({
    url: `/sys/menus/${id}`,
    method: 'delete'
  })
}