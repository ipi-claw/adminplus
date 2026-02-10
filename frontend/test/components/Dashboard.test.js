import { mount } from '@vue/test-utils'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import Dashboard from '@/views/dashboard/Index.vue'

// Mock API
vi.mock('@/api/dashboard', () => ({
  getDashboardData: vi.fn()
}))

describe('Dashboard.vue', () => {
  let wrapper

  beforeEach(() => {
    wrapper = mount(Dashboard)
  })

  it('renders dashboard correctly', () => {
    // 检查页面标题
    expect(wrapper.text()).toContain('仪表板')
    
    // 检查统计卡片
    expect(wrapper.find('.stat-card').exists()).toBe(true)
    expect(wrapper.findAll('.stat-card').length).toBeGreaterThan(0)
  })

  it('loads dashboard data on mount', async () => {
    // 检查组件是否尝试加载数据
    expect(wrapper.vm.loading).toBe(true)
  })

  it('displays loading state', () => {
    // 设置加载状态
    wrapper.vm.loading = true
    await wrapper.vm.$nextTick()
    
    // 应该显示加载指示器
    expect(wrapper.find('.el-loading').exists()).toBe(true)
  })

  it('displays error message when data loading fails', async () => {
    // 模拟 API 失败
    wrapper.vm.loading = false
    wrapper.vm.error = '数据加载失败'
    await wrapper.vm.$nextTick()
    
    // 应该显示错误信息
    expect(wrapper.text()).toContain('数据加载失败')
  })

  it('has refresh button', () => {
    // 检查刷新按钮
    const refreshBtn = wrapper.find('button[type="button"]')
    expect(refreshBtn.exists()).toBe(true)
    expect(refreshBtn.text()).toContain('刷新')
  })
})