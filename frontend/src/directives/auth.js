import { useUserStore } from '@/stores/user'

const isDev = import.meta.env.DEV

/**
 * 权限指令
 * 用法：v-auth="'user:add'"
 * 用法：v-auth="['user:add', 'user:edit']" （任意一个权限即可）
 * 用法：v-auth.any="['user:add', 'user:edit']" （任意一个权限即可，默认行为）
 * 用法：v-auth.all="['user:add', 'user:edit']" （必须拥有所有权限）
 */
export default {
  mounted(el, binding) {
    checkPermission(el, binding)
  },
  updated(el, binding) {
    checkPermission(el, binding)
  }
}

function checkPermission(el, binding) {
  const { value, modifiers } = binding
  const userStore = useUserStore()

  if (value === null || value === undefined || value === '') {
    if (isDev) {
      console.warn('[v-auth] 权限值为空，默认显示元素')
    }
    return
  }

  let hasAuth = false

  if (modifiers.all) {
    // 必须拥有所有权限
    hasAuth = Array.isArray(value)
      ? userStore.hasAllPermissions(value)
      : userStore.hasPermission(value)
  } else {
    // 任意一个权限即可（默认行为）
    hasAuth = Array.isArray(value)
      ? userStore.hasAnyPermission(value)
      : userStore.hasPermission(value)
  }

  if (!hasAuth) {
    if (isDev) {
      console.warn(`[v-auth] 权限不足，移除元素:`, value)
    }
    // 如果没有权限，移除元素
    el.parentNode?.removeChild(el)
  } else if (isDev) {
    console.log(`[v-auth] 权限检查通过:`, value)
  }
}