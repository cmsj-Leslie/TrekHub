/**
 * 用户状态管理（Pinia Store）
 * 功能：管理登录态（token）、用户信息、登录/注册/登出操作
 */
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as apiLogin, register as apiRegister, getProfile } from '@/api/user'

export const useUserStore = defineStore('user', () => {
  const token = ref(localStorage.getItem('token') || '') // 从本地存储恢复 token
  const info  = ref(null)                                // 用户信息对象

  const isLoggedIn = computed(() => !!token.value)        // 是否已登录
  const isAdmin = computed(() => info.value?.role === 1)   // 是否是管理员

  // 登录：调用 API → 保存 token 和用户信息
  async function doLogin(data) {
    const res = await apiLogin(data)
    token.value = res.data.token
    info.value  = res.data.user
    localStorage.setItem('token', token.value)
  }

  // 注册：调用 API → 自动登录
  async function doRegister(data) {
    const res = await apiRegister(data)
    token.value = res.data.token
    info.value  = res.data.user
    localStorage.setItem('token', token.value)
  }

  // 获取当前用户信息（刷新页面后恢复用户数据）
  async function fetchMe() {
    if (!token.value) return
    const res = await getProfile()
    info.value = res.data
  }

  // 登出：清除 token 和用户信息
  function logout() {
    token.value = ''
    info.value  = null
    localStorage.removeItem('token')
  }

  return { token, info, isLoggedIn, isAdmin, doLogin, doRegister, fetchMe, logout }
})
