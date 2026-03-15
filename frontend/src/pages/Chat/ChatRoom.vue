<template>
  <div class="chatroom-page">
    <!-- 顶部栏 -->
    <div class="room-topbar">
      <n-button text @click="$router.push('/chat')" style="font-size:18px">‹</n-button>
      <h3>{{ roomName }}</h3>
      <n-tag v-if="members.length" size="small" round type="info">{{ members.length }} 人</n-tag>
      <div style="flex:1" />
      <n-button text size="small" v-if="members.length" @click="showMembers = !showMembers">👥 成员</n-button>
    </div>

    <div class="room-body">
      <!-- 消息区域 -->
      <div ref="msgListRef" class="msg-list">
        <div style="text-align:center;margin-bottom:12px">
          <n-button text size="small" :disabled="noMore" @click="loadMore">
            {{ noMore ? '没有更多了' : '加载更多' }}
          </n-button>
        </div>
        <div v-for="(msg, idx) in chatStore.messages" :key="msg.id">
          <div v-if="showTime(idx)" class="time-divider">{{ formatTime(msg.createdAt || msg.created_at) }}</div>
          <div :class="['msg-row', { self: isSelf(msg) }]">
            <div v-if="!isSelf(msg)" class="msg-avatar" @click="$router.push(`/profile/${msg.sender?.id}`)">
              <img v-if="msg.sender?.avatar" :src="msg.sender.avatar" />
              <span v-else>{{ msg.sender?.nickname?.[0] }}</span>
            </div>
            <div class="msg-body">
              <div v-if="!isSelf(msg)" class="msg-sender">{{ msg.sender?.nickname }}</div>
              <div v-if="(msg.type || 1) === 1" :class="['msg-bubble', { self: isSelf(msg) }]">{{ msg.content }}</div>
              <img v-else-if="msg.type === 2" :src="msg.content" class="msg-image" @click="previewSrc = msg.content" />
              <div class="msg-time">{{ dayjs(msg.createdAt || msg.created_at).format('HH:mm') }}</div>
            </div>
            <div v-if="isSelf(msg)" class="msg-avatar self-avatar">
              <img v-if="userStore.info?.avatar" :src="userStore.info.avatar" />
              <span v-else>{{ userStore.info?.nickname?.[0] }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 成员面板 -->
      <div v-if="showMembers" class="members-panel">
        <div class="members-title">👥 群成员 ({{ members.length }})</div>
        <div v-for="m in members" :key="m.id" class="member-item" @click="$router.push(`/profile/${m.id}`)">
          <div class="member-avatar">
            <img v-if="m.avatar" :src="m.avatar" />
            <span v-else>{{ m.nickname?.[0] }}</span>
          </div>
          <span class="member-name">{{ m.nickname }}</span>
        </div>
      </div>
    </div>

    <!-- 输入区 -->
    <div class="chat-input-bar">
      <label class="img-btn">
        <input type="file" accept="image/*" style="display:none" @change="sendImageFile" />
        🖼️
      </label>
      <n-input v-model:value="inputMsg" type="textarea" :rows="1"
        :autosize="{ minRows: 1, maxRows: 4 }"
        placeholder="输入消息… Enter 发送"
        style="flex:1"
        @keydown.enter.exact.prevent="send" />
      <n-button type="primary" round :disabled="!inputMsg.trim()" @click="send">发送</n-button>
    </div>

    <!-- 图片预览 -->
    <n-modal :show="!!previewSrc" @update:show="previewSrc = ''" style="width:auto;max-width:90vw">
      <img :src="previewSrc" style="max-width:80vw;max-height:80vh;border-radius:8px" />
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { useRoute } from 'vue-router'
import { NButton, NTag, NInput, NModal } from 'naive-ui'
import dayjs from 'dayjs'
import { useChatStore } from '@/stores/chat'
import { useUserStore } from '@/stores/user'
import { getRoomMembers } from '@/api/chat'
import request from '@/api/request'

const vueRoute  = useRoute()
const chatStore = useChatStore()
const userStore = useUserStore()

const roomId    = +vueRoute.params.roomId
const members   = ref([])
const inputMsg  = ref('')
const msgListRef = ref(null)
const previewSrc = ref('')
const noMore    = ref(false)
const showMembers = ref(false)

const roomName = computed(() => {
  const room = chatStore.rooms.find(r => r.id === roomId)
  return room?.name || (room?.type === 1 ? '私信' : '群聊')
})

const isSelf = (msg) => (msg.sender?.id ?? msg.sender_id) === userStore.info?.id

function showTime(idx) {
  if (idx === 0) return true
  const cur = dayjs(chatStore.messages[idx].createdAt || chatStore.messages[idx].created_at)
  const prev = dayjs(chatStore.messages[idx - 1].createdAt || chatStore.messages[idx - 1].created_at)
  return cur.diff(prev, 'minute') > 5
}
function formatTime(ts) {
  const d = dayjs(ts)
  if (d.isSame(dayjs(), 'day')) return d.format('HH:mm')
  if (d.isSame(dayjs().subtract(1, 'day'), 'day')) return '昨天 ' + d.format('HH:mm')
  return d.format('MM/DD HH:mm')
}

function scrollToBottom() {
  nextTick(() => { const el = msgListRef.value; if (el) el.scrollTop = el.scrollHeight })
}

async function loadMore() {
  const firstId = chatStore.messages[0]?.id
  if (!firstId) return
  const prev = chatStore.messages.length
  await chatStore.loadMessages(roomId, firstId)
  if (chatStore.messages.length === prev) noMore.value = true
}

function send() {
  if (!inputMsg.value.trim()) return
  chatStore.sendMessage(roomId, inputMsg.value.trim())
  inputMsg.value = ''
  scrollToBottom()
}

async function sendImageFile(e) {
  const file = e.target.files?.[0]
  if (!file) return
  const fd = new FormData()
  fd.append('images', file)
  try {
    const res = await request.post('/checkins', fd)
    const url = res?.data?.images?.[0]
    if (url) chatStore.sendMessage(roomId, url, 2)
  } catch (err) { console.error('图片发送失败', err) }
}

const stopWatch = watch(() => chatStore.messages.length, () => scrollToBottom())

onMounted(async () => {
  await chatStore.loadMessages(roomId)
  chatStore.joinRoom(roomId)
  scrollToBottom()
  const res = await getRoomMembers(roomId)
  members.value = res.data
})

onUnmounted(() => {
  stopWatch()
  chatStore.socket?.emit('chat:leave', { roomId })
})
</script>

<style scoped>
.chatroom-page {
  max-width: 860px;
  margin: 0 auto;
  height: calc(100vh - 80px);
  display: flex;
  flex-direction: column;
  background: #fff;
  border-radius: 14px;
  border: 1px solid #eee;
  overflow: hidden;
}

.room-topbar {
  padding: 12px 20px;
  border-bottom: 1px solid #f0f0f0;
  display: flex;
  align-items: center;
  gap: 8px;
  background: #fff;
}
.room-topbar h3 { margin: 0; font-size: 15px; font-weight: 600; }

.room-body { flex: 1; display: flex; overflow: hidden; }
.msg-list { flex: 1; overflow-y: auto; padding: 16px 20px; background: #f8f9fb; }

/* 成员面板 */
.members-panel {
  width: 200px;
  border-left: 1px solid #f0f0f0;
  background: #fafbfc;
  overflow-y: auto;
  padding: 12px;
}
.members-title { font-size: 13px; font-weight: 600; color: #666; margin-bottom: 12px; }
.member-item {
  display: flex; align-items: center; gap: 8px;
  padding: 6px 8px; border-radius: 8px; cursor: pointer; transition: background .2s;
}
.member-item:hover { background: #eef3f9; }
.member-avatar {
  width: 28px; height: 28px; border-radius: 50%; overflow: hidden;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; color: #fff; font-weight: 600; flex-shrink: 0;
}
.member-avatar img { width: 100%; height: 100%; object-fit: cover; }
.member-name { font-size: 13px; color: #333; }

/* 时间分隔 */
.time-divider {
  text-align: center; font-size: 11px; color: #bbb; margin: 16px 0; position: relative;
}
.time-divider::before, .time-divider::after {
  content: ''; display: inline-block; width: 50px; height: 1px;
  background: #e8e8e8; vertical-align: middle; margin: 0 8px;
}

/* 消息行 */
.msg-row { display: flex; align-items: flex-start; margin-bottom: 14px; gap: 8px; }
.msg-row.self { flex-direction: row-reverse; }

.msg-avatar {
  width: 36px; height: 36px; border-radius: 50%; overflow: hidden; flex-shrink: 0; cursor: pointer;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; color: #fff; font-weight: 600;
}
.msg-avatar img { width: 100%; height: 100%; object-fit: cover; }

.msg-body { max-width: 60%; }
.msg-sender { font-size: 11px; color: #999; margin-bottom: 3px; }
.msg-bubble {
  padding: 10px 14px; border-radius: 16px; font-size: 14px; line-height: 1.6;
  word-break: break-word; background: #fff; color: #333;
  border: 1px solid #eee; border-top-left-radius: 4px;
}
.msg-bubble.self {
  background: linear-gradient(135deg, #2d8cf0, #0ea5e9); color: #fff;
  border: none; border-top-right-radius: 4px; border-top-left-radius: 16px;
}
.msg-image { max-width: 200px; border-radius: 10px; cursor: pointer; transition: transform .2s; }
.msg-image:hover { transform: scale(1.03); }
.msg-time { font-size: 10px; color: #bbb; margin-top: 3px; }
.msg-row.self .msg-time { text-align: right; }

/* 输入区 */
.chat-input-bar {
  padding: 12px 16px; border-top: 1px solid #f0f0f0;
  display: flex; align-items: flex-end; gap: 8px; background: #fff;
}
.img-btn {
  font-size: 22px; cursor: pointer; padding: 4px;
  border-radius: 6px; transition: background .2s; line-height: 1;
}
.img-btn:hover { background: #f0f5ff; }
</style>
