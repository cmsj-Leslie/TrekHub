/**
 * 聊天状态管理（Pinia Store）
 * 功能：管理 WebSocket 连接、聊天室列表、消息收发、未读计数
 */
import { defineStore } from 'pinia'
import { ref } from 'vue'
import { io } from 'socket.io-client'
import { getMyRooms, getMessages } from '@/api/chat'

export const useChatStore = defineStore('chat', () => {
  const socket = ref(null)         // Socket.IO 连接实例
  const rooms  = ref([])           // 聊天室列表
  const activeRoomId = ref(null)   // 当前打开的聊天室 ID
  const messages = ref([])         // 当前聊天室的消息列表
  const unreadTotal = ref(0)       // 全局未读消息总数

  // 建立 WebSocket 连接
  function connect(token) {
    if (socket.value?.connected) return
    socket.value = io(import.meta.env.VITE_API_BASE_URL || 'http://localhost:3000', { auth: { token }, transports: ['websocket'] })

    // 收到新消息：如果是当前房间则追加到列表，同时更新房间最后一条消息
    socket.value.on('chat:message', (msg) => {
      if (msg.roomId === activeRoomId.value) {
        messages.value.push(msg)
      }
      const room = rooms.value.find(r => r.id === msg.roomId)
      if (room) room.last_msg = msg.content
    })

    // 组队成功通知
    socket.value.on('match:success', (data) => {
      window.$notification?.success({ title: '🎉 组队成功！', content: `已为你匹配到 ${data.memberCount} 人队伍` })
    })
  }

  // 断开 WebSocket 连接
  function disconnect() {
    socket.value?.disconnect()
    socket.value = null
  }

  // 加入聊天室（通知服务端开始接收该房间消息）
  function joinRoom(roomId) {
    socket.value?.emit('chat:join', { roomId })
    activeRoomId.value = roomId
  }

  // 发送消息（type: 1=文字, 2=图片）
  function sendMessage(roomId, content, type = 1) {
    socket.value?.emit('chat:send', { roomId, content, type })
  }

  // 加载聊天室列表（含未读数）
  async function loadRooms() {
    const res = await getMyRooms()
    rooms.value = res.data
    unreadTotal.value = res.data.reduce((s, r) => s + (r.unread || 0), 0)
  }

  // 加载历史消息（支持向上翻页 before 参数）
  async function loadMessages(roomId, before) {
    const res = await getMessages(roomId, before ? { before } : {})
    if (before) {
      messages.value = [...res.data, ...messages.value] // 追加到顶部
    } else {
      messages.value = res.data
    }
    socket.value?.emit('chat:read', { roomId }) // 标记已读
  }

  return { socket, rooms, activeRoomId, messages, unreadTotal, connect, disconnect, joinRoom, sendMessage, loadRooms, loadMessages }
})
