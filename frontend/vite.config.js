/**
 * Vite 构建工具配置
 * 功能：Vue 插件、路径别名、API 代理（将 /api 转发到后端）
 */
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd()) // 加载 .env 文件中的环境变量
  const apiTarget = env.VITE_API_BASE_URL || 'http://localhost:3000' // 后端地址

  return {
    plugins: [
      vue(),
      // 自定义插件：将 index.html 中的 %VITE_XXX% 替换为 .env 中的实际值
      {
        name: 'html-env-replace',
        transformIndexHtml(html) {
          return html.replace(/%(\w+)%/g, (_, key) => env[key] || '')
        }
      }
    ],
    resolve: {
      alias: { '@': resolve(__dirname, 'src') } // @ 指向 src 目录
    },
    optimizeDeps: {
      include: ['dayjs', 'dayjs/plugin/relativeTime', 'dayjs/locale/zh-cn'] // 预构建常用依赖
    },
    server: {
      host: '0.0.0.0',   // 允许局域网访问
      port: 5173,
      proxy: {
        // 将 /api 和 /uploads 请求代理到后端（解决跨域）
        '/api': { target: apiTarget, changeOrigin: true },
        '/uploads': { target: apiTarget, changeOrigin: true }
      }
    }
  }
})
