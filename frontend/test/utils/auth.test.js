import { describe, it, expect, vi, beforeEach } from 'vitest'
import { setToken, getToken, removeToken, isLoggedIn } from '@/utils/auth'

describe('auth utils', () => {
  beforeEach(() => {
    // 清除 localStorage 模拟
    localStorage.clear()
  })

  describe('setToken', () => {
    it('sets token in localStorage', () => {
      setToken('test-token')
      expect(localStorage.setItem).toHaveBeenCalledWith('token', 'test-token')
    })
  })

  describe('getToken', () => {
    it('gets token from localStorage', () => {
      localStorage.getItem.mockReturnValue('test-token')
      const token = getToken()
      expect(token).toBe('test-token')
      expect(localStorage.getItem).toHaveBeenCalledWith('token')
    })

    it('returns null when no token exists', () => {
      localStorage.getItem.mockReturnValue(null)
      const token = getToken()
      expect(token).toBeNull()
    })
  })

  describe('removeToken', () => {
    it('removes token from localStorage', () => {
      removeToken()
      expect(localStorage.removeItem).toHaveBeenCalledWith('token')
    })
  })

  describe('isLoggedIn', () => {
    it('returns true when token exists', () => {
      localStorage.getItem.mockReturnValue('test-token')
      expect(isLoggedIn()).toBe(true)
    })

    it('returns false when no token exists', () => {
      localStorage.getItem.mockReturnValue(null)
      expect(isLoggedIn()).toBe(false)
    })

    it('returns false when token is empty string', () => {
      localStorage.getItem.mockReturnValue('')
      expect(isLoggedIn()).toBe(false)
    })
  })
})