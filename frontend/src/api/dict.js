import request from '@/utils/request'

/**
 * 获取字典列表
 */
export const getDictList = (params) => {
  return request({
    url: '/sys/dicts',
    method: 'get',
    params
  })
}

/**
 * 根据字典类型查询
 */
export const getDictByType = (dictType) => {
  return request({
    url: `/sys/dicts/type/${dictType}`,
    method: 'get'
  })
}

/**
 * 根据ID查询字典
 */
export const getDictById = (id) => {
  return request({
    url: `/sys/dicts/${id}`,
    method: 'get'
  })
}

/**
 * 创建字典
 */
export const createDict = (data) => {
  return request({
    url: '/sys/dicts',
    method: 'post',
    data
  })
}

/**
 * 更新字典
 */
export const updateDict = (id, data) => {
  return request({
    url: `/sys/dicts/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除字典
 */
export const deleteDict = (id) => {
  return request({
    url: `/sys/dicts/${id}`,
    method: 'delete'
  })
}

/**
 * 更新字典状态
 */
export const updateDictStatus = (id, status) => {
  return request({
    url: `/sys/dicts/${id}/status`,
    method: 'put',
    params: { status }
  })
}

/**
 * 获取字典项列表
 */
export const getDictItems = (dictId) => {
  return request({
    url: `/sys/dicts/${dictId}/items`,
    method: 'get'
  })
}

/**
 * 获取字典项树形结构
 */
export const getDictItemTree = (dictId) => {
  return request({
    url: `/sys/dicts/${dictId}/items/tree`,
    method: 'get'
  })
}

/**
 * 根据字典类型查询字典项
 */
export const getDictItemsByType = (dictType) => {
  return request({
    url: `/sys/dicts/type/${dictType}/items`,
    method: 'get'
  })
}

/**
 * 创建字典项
 */
export const createDictItem = (dictId, data) => {
  return request({
    url: `/sys/dicts/${dictId}/items`,
    method: 'post',
    data
  })
}

/**
 * 更新字典项
 */
export const updateDictItem = (dictId, id, data) => {
  return request({
    url: `/sys/dicts/${dictId}/items/${id}`,
    method: 'put',
    data
  })
}

/**
 * 删除字典项
 */
export const deleteDictItem = (dictId, id) => {
  return request({
    url: `/sys/dicts/${dictId}/items/${id}`,
    method: 'delete'
  })
}

/**
 * 更新字典项状态
 */
export const updateDictItemStatus = (dictId, id, status) => {
  return request({
    url: `/sys/dicts/${dictId}/items/${id}/status`,
    method: 'put',
    params: { status }
  })
}