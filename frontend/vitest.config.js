import { defineConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './test/setup.js',
    coverage: {
      reporter: ['text', 'html'],
      exclude: [
        'node_modules/',
        'test/setup.js',
      ]
    }
  },
  resolve: {
    alias: {
      '@': new URL('./src', import.meta.url).pathname
    }
  }
})