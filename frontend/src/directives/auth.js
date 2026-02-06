import { useUserStore } from '@/stores/user'

/**
 * 权限指令
 * 用法：v-auth="'user:add'"
 */
export default {
  mounted(el, binding) {
    const { value } = binding
    const userStore = useUserStore()

    if (value && !userStore.hasPermission(value)) {
      // 如果没有权限，移除元素
      el.parentNode?.removeChild(el)
    }
  }
}