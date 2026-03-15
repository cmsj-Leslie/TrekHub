<template>
  <div class="ai-page">
    <!-- 顶部 Banner -->
    <div class="ai-banner">
      <div class="banner-left">
        <h2>🤖 AI 徒步助手</h2>
        <p>基于 DeepSeek 大模型，为你提供专业徒步建议</p>
      </div>
      <n-button size="small" ghost style="color:#fff;border-color:rgba(255,255,255,.5)" @click="clearSession">🗑️ 清除对话</n-button>
    </div>

    <div class="ai-body">
      <!-- 左侧：场景选择 + 快捷提问 -->
      <div class="ai-sidebar">
        <div class="sidebar-section">
          <h4>🎯 对话场景</h4>
          <div v-for="s in scenes" :key="s.key"
            :class="['scene-item', sessionType === s.key && 'active']"
            @click="sessionType = s.key">
            <span class="scene-icon">{{ s.icon }}</span>
            <div class="scene-text">
              <strong>{{ s.label }}</strong>
              <span>{{ s.desc }}</span>
            </div>
          </div>
        </div>

        <div class="sidebar-section">
          <h4>⚡ 快捷提问</h4>
          <div v-for="q in quickQuestions[sessionType]" :key="q"
            class="quick-item" @click="sendQuick(q)">{{ q }}</div>
        </div>
      </div>

      <!-- 右侧：聊天区域 -->
      <div class="ai-chat">
        <!-- 当前场景提示 -->
        <div class="hint-bar">💡 {{ sessionHints[sessionType] }}</div>

        <!-- 消息列表 -->
        <div class="msg-container" ref="chatRef">
          <div v-if="!messages.length" class="empty-chat">
            <div class="empty-icon">🏔️</div>
            <h3>你好！我是 AI 徒步助手</h3>
            <p>试试从左侧选择场景，或直接输入你的问题</p>
          </div>
          <div v-for="(m, i) in messages" :key="i" :class="['msg-row', m.role]">
            <div :class="['msg-avatar', m.role]">
              {{ m.role === 'user' ? '🧑' : '🤖' }}
            </div>
            <div class="msg-content">
              <div class="msg-label">{{ m.role === 'user' ? '你' : 'AI 助手' }}</div>
              <div :class="['msg-bubble', m.role]">{{ m.content }}</div>
            </div>
          </div>
          <div v-if="aiStore.loading" class="msg-row assistant">
            <div class="msg-avatar assistant">🤖</div>
            <div class="msg-content">
              <div class="msg-label">AI 助手</div>
              <div class="msg-bubble assistant typing">
                <span class="dot-anim"><span /><span /><span /></span>
                AI 正在思考...
              </div>
            </div>
          </div>
        </div>

        <!-- 输入区 -->
        <div class="input-area">
          <n-input v-model:value="inputMsg" type="textarea" :rows="2"
            :autosize="{ minRows: 1, maxRows: 4 }"
            placeholder="输入你的问题... Ctrl+Enter 发送"
            style="flex:1"
            @keydown.ctrl.enter.prevent="send" />
          <n-button type="primary" round :loading="aiStore.loading" @click="send"
            style="height:auto;min-width:80px;align-self:flex-end">
            发送 ✈️
          </n-button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, nextTick } from 'vue'
import { NInput, NButton, useMessage } from 'naive-ui'
import { useAiStore } from '@/stores/ai'

const aiStore = useAiStore()
const msg = useMessage()
const sessionType = ref('route_plan')
const inputMsg = ref('')
const chatRef = ref(null)

const messages = computed(() => aiStore.sessions[sessionType.value])

const scenes = [
  { key: 'route_plan', icon: '📍', label: '路线规划', desc: '规划适合你的徒步线路' },
  { key: 'team_match', icon: '👥', label: '组队建议', desc: '找到理想的徒步搭档' },
  { key: 'general', icon: '💬', label: '通用问答', desc: '徒步相关的一切问题' }
]

const sessionHints = {
  route_plan: '告诉我你的徒步等级、偏好地区和时间，AI 将为你规划合适的线路。',
  team_match: '描述你的技能特长和想找的队友类型，AI 将给出组队建议。',
  general: '有任何徒步相关问题都可以问我。'
}

const quickQuestions = {
  route_plan: [
    '推荐一条适合新手的周末线路',
    '云南有哪些经典徒步路线？',
    '秋季适合去哪里徒步？'
  ],
  team_match: [
    '我是新手，怎么找靠谱的队友？',
    '组队徒步需要注意什么？',
    '多少人的队伍最合适？'
  ],
  general: [
    '徒步需要准备哪些装备？',
    '高原徒步如何预防高反？',
    '下雨天徒步要注意什么？'
  ]
}

function scrollToBottom() {
  nextTick(() => { if (chatRef.value) chatRef.value.scrollTop = chatRef.value.scrollHeight })
}

async function send() {
  if (!inputMsg.value.trim() || aiStore.loading) return
  const text = inputMsg.value
  inputMsg.value = ''
  scrollToBottom()
  await aiStore.sendMessage(sessionType.value, text)
  scrollToBottom()
}

function sendQuick(q) {
  inputMsg.value = q
  send()
}

async function clearSession() {
  await aiStore.clear(sessionType.value)
  msg.success('对话已清除 ✅')
}
</script>

<style scoped>
.ai-page { max-width: 1000px; margin: 0 auto; }

/* Banner */
.ai-banner {
  background: linear-gradient(135deg, #0d9488 0%, #2563eb 100%);
  color: #fff;
  padding: 28px 24px;
  border-radius: 14px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}
.ai-banner h2 { margin: 0; font-size: 24px; font-weight: 800; }
.ai-banner p { margin: 6px 0 0; opacity: .85; font-size: 14px; }

/* Body */
.ai-body { display: flex; gap: 16px; }

/* Sidebar */
.ai-sidebar { width: 240px; flex-shrink: 0; display: flex; flex-direction: column; gap: 12px; }
.sidebar-section {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 14px;
}
.sidebar-section h4 { margin: 0 0 10px; font-size: 13px; color: #888; font-weight: 600; }

.scene-item {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px;
  border-radius: 10px;
  cursor: pointer;
  transition: all .2s;
  margin-bottom: 4px;
}
.scene-item:hover { background: #f5f7fa; }
.scene-item.active { background: #e8f4ff; }
.scene-icon { font-size: 20px; flex-shrink: 0; margin-top: 2px; }
.scene-text { display: flex; flex-direction: column; }
.scene-text strong { font-size: 13px; color: #333; }
.scene-text span { font-size: 11px; color: #999; margin-top: 2px; }

.quick-item {
  padding: 8px 10px;
  border-radius: 8px;
  font-size: 12px;
  color: #555;
  cursor: pointer;
  transition: background .2s;
  border: 1px solid #f0f0f0;
  margin-bottom: 6px;
}
.quick-item:hover { background: #f0f5ff; border-color: #d0e3ff; color: #2d8cf0; }

/* Chat Area */
.ai-chat {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  overflow: hidden;
}

.hint-bar {
  background: #f0f9ff;
  border-bottom: 1px solid #e0f2fe;
  color: #0284c7;
  padding: 8px 16px;
  font-size: 12px;
}

.msg-container {
  flex: 1;
  overflow-y: auto;
  padding: 16px;
  background: #f8f9fb;
  min-height: 380px;
  max-height: calc(100vh - 340px);
}
.empty-chat {
  text-align: center;
  color: #bbb;
  padding-top: 80px;
}
.empty-icon { font-size: 48px; margin-bottom: 8px; }
.empty-chat h3 { margin: 0; font-size: 16px; color: #999; }
.empty-chat p { margin: 4px 0 0; font-size: 13px; }

/* Messages */
.msg-row { display: flex; gap: 10px; margin-bottom: 16px; }
.msg-row.user { flex-direction: row-reverse; }

.msg-avatar {
  width: 36px; height: 36px; border-radius: 50%;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px; flex-shrink: 0;
}
.msg-avatar.user { background: linear-gradient(135deg, #667eea, #764ba2); }
.msg-avatar.assistant { background: linear-gradient(135deg, #0d9488, #2563eb); }

.msg-content { max-width: 65%; }
.msg-label { font-size: 11px; color: #999; margin-bottom: 3px; }
.msg-row.user .msg-label { text-align: right; }

.msg-bubble {
  padding: 10px 14px;
  border-radius: 16px;
  font-size: 14px;
  line-height: 1.7;
  white-space: pre-wrap;
  word-break: break-word;
}
.msg-bubble.user {
  background: linear-gradient(135deg, #2d8cf0, #0ea5e9);
  color: #fff;
  border-top-right-radius: 4px;
}
.msg-bubble.assistant {
  background: #fff;
  color: #333;
  border: 1px solid #eee;
  border-top-left-radius: 4px;
}
.msg-bubble.typing {
  display: flex;
  align-items: center;
  gap: 8px;
  color: #999;
}

/* Dot animation */
.dot-anim { display: flex; gap: 4px; }
.dot-anim span {
  width: 6px; height: 6px; border-radius: 50%;
  background: #0d9488;
  animation: dotBounce 1.2s ease infinite;
}
.dot-anim span:nth-child(2) { animation-delay: .2s; }
.dot-anim span:nth-child(3) { animation-delay: .4s; }
@keyframes dotBounce {
  0%,100% { opacity: .3; transform: translateY(0); }
  50% { opacity: 1; transform: translateY(-4px); }
}

/* Input */
.input-area {
  display: flex;
  gap: 10px;
  padding: 12px 16px;
  border-top: 1px solid #f0f0f0;
  background: #fff;
}
</style>
