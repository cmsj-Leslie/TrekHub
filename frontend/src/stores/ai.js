import { defineStore } from 'pinia'
import { ref } from 'vue'
import { aiChat, clearAiSession } from '@/api/social'

export const useAiStore = defineStore('ai', () => {
  // 三种会话类型各自维护消息列表（仅前端展示用，上下文在后端管理）
  const sessions = ref({
    route_plan: [],
    team_match: [],
    general: []
  })
  const loading = ref(false)

  async function sendMessage(sessionType, content) {
    sessions.value[sessionType].push({ role: 'user', content })
    loading.value = true
    try {
      const res = await aiChat({ message: content, sessionType })
      sessions.value[sessionType].push({ role: 'assistant', content: res.data.reply })
    } finally {
      loading.value = false
    }
  }

  async function clear(sessionType) {
    await clearAiSession(sessionType)
    sessions.value[sessionType] = []
  }

  return { sessions, loading, sendMessage, clear }
})
