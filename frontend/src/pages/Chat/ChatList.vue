<template>
  <div class="chat-page">
    <!-- 侧边栏 -->
    <div class="chat-sidebar">
      <div class="sidebar-header">
        <h3>💬 消息</h3>
        <span class="room-count" v-if="chatStore.rooms.length">{{ chatStore.rooms.length }} 个会话</span>
      </div>
      <div class="room-list">
        <div v-if="!chatStore.rooms.length" class="empty-rooms">
          <div style="font-size:32px">📭</div>
          <div>暂无消息</div>
        </div>
        <div v-for="room in chatStore.rooms" :key="room.id"
          :class="['room-item', { active: room.id === selectedRoomId }]"
          @click="selectRoom(room)">
          <!-- 头像：私聊显示对方头像，群聊显示类型标识 -->
          <div v-if="room.type === 1 && room.other_avatar" class="room-avatar-img">
            <img :src="room.other_avatar" />
          </div>
          <div v-else class="room-avatar" :style="{ background: room.type === 1 ? 'linear-gradient(135deg,#a78bfa,#7c3aed)' : 'linear-gradient(135deg,#667eea,#764ba2)' }">
            {{ room.type === 1 ? ('私') : '组' }}
          </div>
          <div class="room-info">
            <div class="room-name">
              <span>{{ roomDisplayName(room) }}</span>
              <n-badge v-if="room.unread" :value="room.unread" :max="99" />
            </div>
            <div class="room-last-msg">{{ formatLastMsg(room) }}</div>
          </div>
          <span class="room-delete-btn" title="删除会话" @click.stop="confirmDelete(room)">×</span>
        </div>
      </div>
    </div>

    <!-- 聊天区域 -->
    <div class="chat-main">
      <template v-if="selectedRoomId">
        <div class="chat-topbar">
          <h3>{{ roomDisplayName(currentRoom) }}</h3>
          <n-tag v-if="currentRoom?.type === 2" size="small" round type="info">群聊</n-tag>
          <n-tag v-else-if="currentRoom?.type === 1" size="small" round type="success">私信</n-tag>
        </div>
        <div ref="msgListRef" class="msg-list" @scroll="onScroll">
          <div v-for="(msg, idx) in chatStore.messages" :key="msg.id">
            <!-- 时间分隔 -->
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
        <!-- 输入区 -->
        <div class="chat-input-bar">
          <label class="img-btn">
            <input type="file" accept="image/*" style="display:none" @change="sendImage" />
            🖼️
          </label>
          <n-input v-model:value="inputMsg" type="textarea" :rows="1"
            :autosize="{ minRows: 1, maxRows: 4 }"
            placeholder="输入消息… Enter 发送"
            style="flex:1"
            @keydown.enter.exact.prevent="send" />
          <n-button type="primary" round :disabled="!inputMsg.trim()" @click="send">发送</n-button>
        </div>
      </template>

      <!-- 空状态 -->
      <div v-else class="chat-empty">
        <div class="empty-icon">💬</div>
        <h3>选择一个会话开始聊天</h3>
        <p>从左侧列表选择或通过用户主页发起私信</p>
      </div>
    </div>

    <!-- 图片预览 -->
    <n-modal :show="!!previewSrc" @update:show="previewSrc = ''" style="width:auto;max-width:90vw">
      <img :src="previewSrc" style="max-width:80vw;max-height:80vh;border-radius:8px" />
    </n-modal>

    <!-- 删除确认弹窗 -->
    <n-modal :show="!!deleteTarget" @update:show="deleteTarget = null">
      <div class="delete-dialog">
        <div class="delete-dialog-icon">🗑️</div>
        <h3 class="delete-dialog-title">删除会话</h3>
        <p class="delete-dialog-desc">确定要删除「{{ deleteTarget?.name || '私信' }}」吗？<br>删除后该会话将从你的列表中移除。</p>
        <div class="delete-dialog-actions">
          <button class="dlg-btn cancel" @click="deleteTarget = null">取消</button>
          <button class="dlg-btn confirm" @click="doDeleteRoom">确认删除</button>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, nextTick, onMounted, onUnmounted, watch } from 'vue'
import { NInput, NButton, NBadge, NTag, NModal, useMessage } from 'naive-ui'
import dayjs from 'dayjs'
import { useChatStore } from '@/stores/chat'
import { useUserStore } from '@/stores/user'
import { leaveRoom } from '@/api/chat'
import request from '@/api/request'

const chatStore = useChatStore()
const userStore = useUserStore()
const msg = useMessage()

const selectedRoomId = ref(null)
const inputMsg = ref('')
const msgListRef = ref(null)
const previewSrc = ref('')
const deleteTarget = ref(null)

const currentRoom = computed(() => chatStore.rooms.find(r => r.id === selectedRoomId.value))
const isSelf = (msg) => (msg.sender?.id ?? msg.sender_id) === userStore.info?.id

function isImageUrl(str) {
  if (!str) return false
  return /\.(png|jpe?g|gif|webp|bmp|svg)(\?.*)?$/i.test(str) || str.startsWith('/uploads/images/')
}

// 智能显示房间名称
function roomDisplayName(room) {
  if (!room) return '聊天'
  if (room.type === 1) {
    // 私聊：显示对方昵称
    return room.other_nickname || '私信'
  }
  // 群聊：优先显示活动标题，其次显示房间名
  return room.activity_title || room.name || '群聊'
}

function formatLastMsg(room) {
  if (!room.last_msg) return '暂无消息'
  if (isImageUrl(room.last_msg)) return '📷 图片'
  return room.last_msg
}

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

async function selectRoom(room) {
  selectedRoomId.value = room.id
  chatStore.joinRoom(room.id)
  await chatStore.loadMessages(room.id)
  scrollToBottom()
}

function send() {
  if (!inputMsg.value.trim() || !selectedRoomId.value) return
  chatStore.sendMessage(selectedRoomId.value, inputMsg.value.trim())
  inputMsg.value = ''
  nextTick(scrollToBottom)
}

async function sendImage(e) {
  const file = e.target.files?.[0]
  if (!file) return
  const fd = new FormData()
  fd.append('images', file)
  try {
    const res = await request.post('/checkins', fd)
    const url = res?.data?.images?.[0]
    if (url) chatStore.sendMessage(selectedRoomId.value, url, 2)
  } catch (err) { console.error('图片发送失败', err) }
}

function scrollToBottom() {
  nextTick(() => {
    const el = msgListRef.value
    if (el) el.scrollTop = el.scrollHeight
  })
}

function onScroll(e) {
  if (e.target.scrollTop === 0 && chatStore.messages.length) {
    chatStore.loadMessages(selectedRoomId.value, chatStore.messages[0]?.id)
  }
}

const stopWatch = watch(() => chatStore.messages.length, () => scrollToBottom())

onMounted(() => chatStore.loadRooms())
onUnmounted(() => stopWatch())

// 删除会话
function confirmDelete(room) {
  deleteTarget.value = room
}

async function doDeleteRoom() {
  const room = deleteTarget.value
  if (!room) return
  deleteTarget.value = null
  try {
    await leaveRoom(room.id)
    chatStore.rooms = chatStore.rooms.filter(r => r.id !== room.id)
    if (selectedRoomId.value === room.id) {
      selectedRoomId.value = null
      chatStore.messages = []
    }
    msg.success('会话已删除')
  } catch (e) {
    msg.error('删除失败')
  }
}
</script>

<style scoped>
.chat-page {
  display: flex;
  gap: 0;
  height: calc(100vh - 80px);
  max-width: 1000px;
  margin: 0 auto;
  background: #fff;
  border-radius: 14px;
  border: 1px solid #eee;
  overflow: hidden;
}

/* === 侧边栏 === */
.chat-sidebar {
  width: 280px;
  flex-shrink: 0;
  display: flex;
  flex-direction: column;
  border-right: 1px solid #f0f0f0;
  background: #fafbfc;
}
.sidebar-header {
  padding: 16px 16px 12px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid #f0f0f0;
}
.sidebar-header h3 { margin: 0; font-size: 16px; font-weight: 700; color: #1a1a2e; }
.room-count { font-size: 11px; color: #999; }
.room-list { flex: 1; overflow-y: auto; padding: 8px; }
.empty-rooms { text-align: center; padding: 40px 16px; color: #bbb; font-size: 13px; }

.room-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 10px;
  cursor: pointer;
  transition: all .2s;
  margin-bottom: 2px;
}
.room-item:hover { background: #eef3f9; }
.room-item.active { background: #e0edff; }
.room-avatar {
  width: 40px; height: 40px; border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; color: #fff; font-weight: 600; flex-shrink: 0;
}
.room-avatar-img {
  width: 40px; height: 40px; border-radius: 50%;
  overflow: hidden; flex-shrink: 0;
}
.room-avatar-img img {
  width: 100%; height: 100%; object-fit: cover;
}
.room-info { flex: 1; min-width: 0; }
.room-name {
  display: flex; align-items: center; justify-content: space-between;
  font-weight: 600; font-size: 14px; color: #333;
}
.room-last-msg {
  font-size: 12px; color: #999; margin-top: 2px;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.room-delete-btn {
  display: none;
  width: 20px; height: 20px;
  border-radius: 50%;
  background: #e5e5e5;
  color: #666;
  font-size: 14px; font-weight: 700;
  align-items: center; justify-content: center;
  flex-shrink: 0;
  cursor: pointer;
  transition: all .2s;
  line-height: 20px;
  text-align: center;
}
.room-item:hover .room-delete-btn { display: flex; }
.room-delete-btn:hover { background: #ff4d4f; color: #fff; }

/* === 聊天主区 === */
.chat-main {
  flex: 1; display: flex; flex-direction: column; overflow: hidden;
}
.chat-topbar {
  padding: 14px 20px;
  border-bottom: 1px solid #f0f0f0;
  display: flex; align-items: center; gap: 8px;
  background: #fff;
}
.chat-topbar h3 { margin: 0; font-size: 15px; font-weight: 600; }
.msg-list { flex: 1; overflow-y: auto; padding: 16px 20px; background: #f8f9fb; }

/* 时间分隔 */
.time-divider {
  text-align: center;
  font-size: 11px;
  color: #bbb;
  margin: 16px 0;
  position: relative;
}
.time-divider::before, .time-divider::after {
  content: '';
  display: inline-block;
  width: 60px;
  height: 1px;
  background: #e8e8e8;
  vertical-align: middle;
  margin: 0 10px;
}

/* 消息行 */
.msg-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 14px;
  gap: 8px;
}
.msg-row.self { flex-direction: row-reverse; }

.msg-avatar {
  width: 36px; height: 36px; border-radius: 50%;
  overflow: hidden; flex-shrink: 0; cursor: pointer;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; color: #fff; font-weight: 600;
}
.msg-avatar img { width: 100%; height: 100%; object-fit: cover; }

.msg-body { max-width: 60%; }
.msg-sender { font-size: 11px; color: #999; margin-bottom: 3px; }

.msg-bubble {
  padding: 10px 14px;
  border-radius: 16px;
  font-size: 14px;
  line-height: 1.6;
  word-break: break-word;
  background: #fff;
  color: #333;
  border: 1px solid #eee;
  border-top-left-radius: 4px;
}
.msg-bubble.self {
  background: linear-gradient(135deg, #2d8cf0, #0ea5e9);
  color: #fff;
  border: none;
  border-top-right-radius: 4px;
  border-top-left-radius: 16px;
}
.msg-image {
  max-width: 200px;
  border-radius: 10px;
  cursor: pointer;
  transition: transform .2s;
}
.msg-image:hover { transform: scale(1.03); }
.msg-time {
  font-size: 10px; color: #bbb; margin-top: 3px;
}
.msg-row.self .msg-time { text-align: right; }

/* 输入区 */
.chat-input-bar {
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
  display: flex;
  align-items: flex-end;
  gap: 8px;
  background: #fff;
}
.img-btn {
  font-size: 22px;
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  transition: background .2s;
  line-height: 1;
}
.img-btn:hover { background: #f0f5ff; }

/* 空状态 */
.chat-empty {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #bbb;
}
.empty-icon { font-size: 48px; margin-bottom: 12px; }
.chat-empty h3 { margin: 0; font-size: 16px; color: #999; }
.chat-empty p { margin: 4px 0 0; font-size: 13px; }

/* 删除确认弹窗 */
.delete-dialog {
  background: #fff;
  border-radius: 16px;
  padding: 32px 28px 24px;
  text-align: center;
  max-width: 340px;
  margin: 0 auto;
  box-shadow: 0 20px 60px rgba(0,0,0,.15);
  animation: dlg-in .25s ease;
}
@keyframes dlg-in {
  from { opacity: 0; transform: scale(.9) translateY(10px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}
.delete-dialog-icon {
  font-size: 42px;
  margin-bottom: 8px;
}
.delete-dialog-title {
  margin: 0 0 8px;
  font-size: 18px;
  font-weight: 700;
  color: #1a1a2e;
}
.delete-dialog-desc {
  margin: 0 0 24px;
  font-size: 13px;
  color: #888;
  line-height: 1.7;
}
.delete-dialog-actions {
  display: flex;
  gap: 12px;
  justify-content: center;
}
.dlg-btn {
  padding: 9px 28px;
  border-radius: 10px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  border: none;
  transition: all .2s;
}
.dlg-btn.cancel {
  background: #f5f5f5;
  color: #666;
}
.dlg-btn.cancel:hover {
  background: #e8e8e8;
}
.dlg-btn.confirm {
  background: linear-gradient(135deg, #ff4d4f, #e03e3e);
  color: #fff;
  box-shadow: 0 4px 14px rgba(255, 77, 79, .3);
}
.dlg-btn.confirm:hover {
  transform: translateY(-1px);
  box-shadow: 0 6px 20px rgba(255, 77, 79, .4);
}
</style>
