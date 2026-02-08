import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import router from './router'
import App from './App.vue'
import { setupDirectives } from './directives'
import { setupErrorHandler } from './utils/errorHandler'
import { getCsrfToken } from './utils/request'

// 引入全局样式
import './styles/index.scss'

const app = createApp(App)
const pinia = createPinia()

// 注册自定义指令
setupDirectives(app)

app.use(pinia)
app.use(router)
app.use(ElementPlus)

// 设置全局错误处理
setupErrorHandler(app)

// 初始化 CSRF Token
getCsrfToken().catch(() => {
  // 获取失败不影响应用启动
})

app.mount('#app')