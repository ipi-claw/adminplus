import request from '@/utils/request'

/**
 * 获取验证码
 * @returns {Promise<Object>} 验证码信息，包含 captchaId 和 captchaImage
 */
export const getCaptcha = () => {
  return request({
    url: '/v1/captcha',
    method: 'get'
  })
}