import { config } from '@vue/test-utils'
import ElementPlus from 'element-plus'

// 配置 Vue Test Utils
config.global.plugins = [ElementPlus]

// 模拟 localStorage
const localStorageMock = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}
global.localStorage = localStorageMock

// 模拟 window.location
Object.defineProperty(window, 'location', {
  value: {
    href: '',
    hash: '',
  },
  writable: true,
})