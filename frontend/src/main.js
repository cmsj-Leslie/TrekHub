/**
 * 前端应用入口
 * 功能：创建 Vue 实例，注册 Pinia 状态管理和 Vue Router 路由
 */
import { createApp } from 'vue'
import { createPinia } from 'pinia'   // 状态管理
import router from './router'          // 路由配置
import App from './App.vue'            // 根组件
import './style.css'                   // 全局样式

const app = createApp(App)
app.use(createPinia())  // 注册 Pinia（管理用户登录态、聊天数据等）
app.use(router)         // 注册路由
app.mount('#app')       // 挂载到 DOM
