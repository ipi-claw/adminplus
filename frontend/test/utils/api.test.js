import { describe, it, expect, vi, beforeEach } from 'vitest'
import axios from 'axios'
import { request, get, post, put, del } from '@/utils/request'

// Mock axios
vi.mock('axios')

describe('API utils', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('request', () => {
    it('makes successful request', async () => {
      // Mock successful response
      axios.mockResolvedValue({
        data: {
          code: 200,
          data: { id: 1, name: 'test' },
          message: 'success'
        }
      })

      const result = await request({
        url: '/test',
        method: 'GET'
      })

      expect(result).toEqual({ id: 1, name: 'test' })
      expect(axios).toHaveBeenCalledWith({
        url: '/test',
        method: 'GET',
        headers: {}
      })
    })

    it('handles request error', async () => {
      // Mock error response
      axios.mockRejectedValue({
        response: {
          status: 500,
          data: { message: 'Internal Server Error' }
        }
      })

      await expect(request({
        url: '/test',
        method: 'GET'
      })).rejects.toThrow('Internal Server Error')
    })

    it('handles network error', async () => {
      // Mock network error
      axios.mockRejectedValue(new Error('Network Error'))

      await expect(request({
        url: '/test',
        method: 'GET'
      })).rejects.toThrow('Network Error')
    })
  })

  describe('HTTP method helpers', () => {
    it('get method works', async () => {
      axios.mockResolvedValue({
        data: { code: 200, data: { id: 1 }, message: 'success' }
      })

      const result = await get('/users/1')

      expect(result).toEqual({ id: 1 })
      expect(axios).toHaveBeenCalledWith({
        url: '/users/1',
        method: 'GET',
        headers: {}
      })
    })

    it('post method works', async () => {
      axios.mockResolvedValue({
        data: { code: 200, data: { id: 2 }, message: 'created' }
      })

      const payload = { name: 'new user' }
      const result = await post('/users', payload)

      expect(result).toEqual({ id: 2 })
      expect(axios).toHaveBeenCalledWith({
        url: '/users',
        method: 'POST',
        data: payload,
        headers: {}
      })
    })

    it('put method works', async () => {
      axios.mockResolvedValue({
        data: { code: 200, data: { id: 1, name: 'updated' }, message: 'updated' }
      })

      const payload = { name: 'updated user' }
      const result = await put('/users/1', payload)

      expect(result).toEqual({ id: 1, name: 'updated' })
      expect(axios).toHaveBeenCalledWith({
        url: '/users/1',
        method: 'PUT',
        data: payload,
        headers: {}
      })
    })

    it('delete method works', async () => {
      axios.mockResolvedValue({
        data: { code: 200, data: null, message: 'deleted' }
      })

      const result = await del('/users/1')

      expect(result).toBeNull()
      expect(axios).toHaveBeenCalledWith({
        url: '/users/1',
        method: 'DELETE',
        headers: {}
      })
    })
  })

  describe('request with auth token', () => {
    it('includes auth token in headers', async () => {
      // Mock localStorage
      localStorage.getItem.mockReturnValue('test-token')
      
      axios.mockResolvedValue({
        data: { code: 200, data: {}, message: 'success' }
      })

      await request({
        url: '/protected',
        method: 'GET'
      })

      expect(axios).toHaveBeenCalledWith({
        url: '/protected',
        method: 'GET',
        headers: {
          Authorization: 'Bearer test-token'
        }
      })
    })

    it('does not include auth token when no token exists', async () => {
      // Mock no token
      localStorage.getItem.mockReturnValue(null)
      
      axios.mockResolvedValue({
        data: { code: 200, data: {}, message: 'success' }
      })

      await request({
        url: '/public',
        method: 'GET'
      })

      expect(axios).toHaveBeenCalledWith({
        url: '/public',
        method: 'GET',
        headers: {}
      })
    })
  })
})