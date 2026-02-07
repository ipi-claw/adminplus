import { createApp } from 'vue'
import { createPinia } from 'pinia'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import router from './router'
import App from './App.vue'
import { setupDirectives } from './directives'
import { setupErrorHandler } from './utils/errorHandler'
import LoginDialog from './components/LoginDialog.vue'

const app = createApp(App)
const pinia = createPinia()

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 注册全局登录对话框组件
app.component('LoginDialog', LoginDialog)

// 注册自定义指令
setupDirectives(app)

app.use(pinia)
app.use(router)
app.use(ElementPlus)

// 设置全局错误处理
setupErrorHandler(app)

app.mount('#app')