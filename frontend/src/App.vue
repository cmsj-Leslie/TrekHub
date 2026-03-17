<template>
  <n-config-provider :theme="null">
    <n-message-provider>
      <n-notification-provider>
        <n-dialog-provider>
        <n-layout style="min-height:100vh;display:flex;flex-direction:column">
          <!-- 导航栏 -->
          <n-layout-header bordered class="nav-header">
            <div class="nav-left">
              <router-link to="/" class="logo">🏔 TrekHub</router-link>
              <nav class="nav-links">
                <router-link to="/routes">🗺️ 探索线路</router-link>
                <router-link to="/activities">🎯 找活动</router-link>
                <router-link to="/match">🎲 随机组队</router-link>
                <router-link to="/ai">🤖 AI助手</router-link>
                <router-link to="/checkin">📍 打卡</router-link>
                <router-link v-if="userStore.isAdmin" to="/admin" class="admin-link">🛡️ 管理</router-link>
              </nav>
            </div>
            <div class="nav-right">
              <template v-if="userStore.isLoggedIn">
                <router-link to="/chat" class="msg-link">
                  <n-badge :value="chatStore.unreadTotal" :max="99">
                    <div class="msg-btn">💬 消息</div>
                  </n-badge>
                </router-link>
                <n-dropdown :options="userMenuOptions" @select="handleUserMenu">
                  <div class="user-trigger">
                    <div class="nav-avatar">
                      <img v-if="userStore.info?.avatar" :src="userStore.info.avatar" />
                      <span v-else>{{ userStore.info?.nickname?.[0] }}</span>
                    </div>
                    <span class="user-name">{{ userStore.info?.nickname }}</span>
                  </div>
                </n-dropdown>
              </template>
              <template v-else>
                <router-link to="/login"><n-button size="small">登录</n-button></router-link>
                <router-link to="/register"><n-button type="primary" size="small">注册</n-button></router-link>
              </template>
            </div>
          </n-layout-header>
          <n-layout-content style="flex:1;overflow:auto;padding:24px">
            <router-view />
          </n-layout-content>
          <footer class="app-footer">
            <div>
              <router-link to="/">首页</router-link>
              <router-link to="/routes">线路</router-link>
              <router-link to="/activities">活动</router-link>
              <router-link to="/ai">AI助手</router-link>
            </div>
            <div style="margin-top:8px">© 2026 TrekHub · 基于 Vue.js 的徒步旅行线路规划与同伴组队平台</div>
          </footer>
        </n-layout>
        </n-dialog-provider>
      </n-notification-provider>
    </n-message-provider>
  </n-config-provider>
</template>

<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  NConfigProvider, NMessageProvider, NNotificationProvider, NDialogProvider,
  NLayout, NLayoutHeader, NLayoutContent,
  NSpace, NButton, NBadge, NAvatar, NDropdown
} from 'naive-ui'
import { useUserStore } from '@/stores/user'
import { useChatStore } from '@/stores/chat'

const router = useRouter()
const userStore = useUserStore()
const chatStore = useChatStore()

const userMenuOptions = computed(() => {
  const items = [
    { label: '👤 个人主页', key: 'profile' },
    { label: '📍 打卡记录', key: 'checkin' },
    { label: '⚙️ 设置', key: 'settings' }
  ]
  if (userStore.isAdmin) {
    items.push({ type: 'divider', key: 'd1' })
    items.push({ label: '🛡️ 后台管理', key: 'admin' })
  }
  items.push({ type: 'divider', key: 'd2' }, { label: '🚪 退出登录', key: 'logout' })
  return items
})

function handleUserMenu(key) {
  if (key === 'logout') { userStore.logout(); router.push('/login') }
  else if (key === 'profile') router.push(`/profile/${userStore.info.id}`)
  else router.push(`/${key}`)
}

onMounted(async () => {
  if (userStore.isLoggedIn) {
    await userStore.fetchMe()
    chatStore.connect(userStore.token)
    chatStore.loadRooms()
  }
})
</script>

<style scoped>
.nav-header {
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  background: #fff;
}
.nav-left { display: flex; align-items: center; gap: 24px; }
.logo {
  font-size: 20px; font-weight: 700; color: #2d8cf0;
  text-decoration: none; white-space: nowrap;
}
.nav-links {
  display: flex; gap: 4px;
}
.nav-links a {
  text-decoration: none; color: #555; font-size: 14px;
  padding: 6px 12px; border-radius: 6px; transition: all .2s;
}
.nav-links a:hover { background: #f0f5ff; color: #2d8cf0; }
.nav-links a.router-link-active { color: #2d8cf0; font-weight: 600; background: #e8f4ff; }
.admin-link { color: #e6a700 !important; }

.nav-right { display: flex; align-items: center; gap: 16px; }
.msg-link { text-decoration: none; }
.msg-btn {
  height: 34px; border-radius: 18px;
  padding: 0 14px;
  display: flex; align-items: center; justify-content: center; gap: 4px;
  font-size: 13px; font-weight: 500; color: #2d8cf0; cursor: pointer;
  background: #f0f5ff; border: 1px solid #e0e8f5;
  transition: all .25s; white-space: nowrap;
}
.msg-btn:hover {
  background: #dbeafe;
  transform: scale(1.08);
  box-shadow: 0 2px 8px rgba(45,140,240,.2);
}
.user-trigger {
  display: flex; align-items: center; gap: 8px; cursor: pointer;
  padding: 4px 8px; border-radius: 8px; transition: background .2s;
}
.user-trigger:hover { background: #f5f5f5; }
.user-name { font-size: 14px; color: #333; font-weight: 500; max-width: 80px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.nav-avatar {
  width: 32px; height: 32px; border-radius: 50%; overflow: hidden;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 14px; color: #fff; font-weight: 600; flex-shrink: 0;
}
.nav-avatar img { width: 100%; height: 100%; object-fit: cover; }
</style>

