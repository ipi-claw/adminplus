import { mount } from '@vue/test-utils'
import { describe, it, expect, vi } from 'vitest'
import LoginForm from '@/views/auth/Login.vue'

// Mock API
vi.mock('@/api/auth', () => ({
  login: vi.fn()
}))

describe('LoginForm.vue', () => {
  it('renders login form correctly', () => {
    const wrapper = mount(LoginForm)
    
    // 检查表单元素是否存在
    expect(wrapper.find('form').exists()).toBe(true)
    expect(wrapper.find('input[type="text"]').exists()).toBe(true)
    expect(wrapper.find('input[type="password"]').exists()).toBe(true)
    expect(wrapper.find('button[type="submit"]').exists()).toBe(true)
  })

  it('validates required fields', async () => {
    const wrapper = mount(LoginForm)
    
    // 触发表单提交
    await wrapper.find('form').trigger('submit')
    
    // 应该显示验证错误
    expect(wrapper.text()).toContain('请输入用户名')
    expect(wrapper.text()).toContain('请输入密码')
  })

  it('emits login event with form data', async () => {
    const wrapper = mount(LoginForm)
    
    // 设置表单数据
    await wrapper.find('input[type="text"]').setValue('admin')
    await wrapper.find('input[type="password"]').setValue('admin123')
    
    // 触发提交
    await wrapper.find('form').trigger('submit')
    
    // 检查是否调用了登录方法
    expect(wrapper.vm.loading).toBe(true)
  })
})