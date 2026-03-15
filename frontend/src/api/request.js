/**
 * Axios 请求封装
 * 功能：统一 baseURL、自动注入 Token、统一错误处理（401 跳转登录）
 */
import axios from 'axios'

const request = axios.create({
  baseURL: '/api',     // 所有请求自动加上 /api 前缀（由 Vite 代理转发到后端）
  timeout: 15000       // 请求超时时间 15 秒
})

// 请求拦截器：自动注入 JWT Token 到请求头
request.interceptors.request.use(config => {
  const token = localStorage.getItem('token')
  if (token) config.headers.Authorization = `Bearer ${token}`
  return config
})

// 响应拦截器：统一处理错误
request.interceptors.response.use(
  res => res.data,  // 成功时直接返回 data（省去每次 .data）
  err => {
    if (err.response?.status === 401) {
      // token 过期或无效 → 清除本地 token → 跳转登录页
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(err.response?.data || err)
  }
)

export default request
