/**
 * 节流函数
 * @param {Function} func - 要执行的函数
 * @param {number} delay - 延迟时间（毫秒）
 * @returns {Function} - 节流后的函数
 */
export function throttle(func, delay = 300) {
  let timer = null
  let lastTime = 0

  return function (...args) {
    const now = Date.now()
    const remaining = delay - (now - lastTime)

    if (remaining <= 0) {
      if (timer) {
        clearTimeout(timer)
        timer = null
      }
      lastTime = now
      func.apply(this, args)
    } else if (!timer) {
      timer = setTimeout(() => {
        lastTime = Date.now()
        timer = null
        func.apply(this, args)
      }, remaining)
    }
  }
}