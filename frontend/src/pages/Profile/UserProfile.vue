<template>
  <div v-if="user" class="profile-page">
    <!-- 顶部渐变 Banner -->
    <div class="profile-banner">
      <div class="banner-pattern" />
    </div>

    <!-- 个人信息卡片 -->
    <div class="profile-card">
      <div class="profile-avatar">
        <img v-if="user.avatar" :src="user.avatar" class="avatar-img" />
        <div v-else class="avatar-char">{{ user.nickname?.[0] }}</div>
      </div>

      <div class="profile-info">
        <h2 class="profile-name">{{ user.nickname }}</h2>
        <div class="profile-meta">
          <span class="level-badge">Lv.{{ user.level }} {{ '⭐'.repeat(user.level || 1) }}</span>
          <span class="profile-username">@{{ user.username }}</span>
        </div>
        <p class="profile-bio">{{ user.bio || '这个人很懒，什么都没写~' }}</p>
      </div>

      <!-- 操作按钮 -->
      <div class="profile-actions">
        <router-link v-if="isSelf" to="/settings"><n-button type="primary" round size="small">✏️ 编辑资料</n-button></router-link>
        <template v-else>
          <n-button :type="followInfo.isFollowed ? 'default' : 'primary'" round size="small" @click="doToggleFollow">
            {{ followInfo.isFollowed ? '✓ 已关注' : '+ 关注' }}
          </n-button>
          <n-button round size="small" @click="startChat">💬 私信</n-button>
        </template>
      </div>
    </div>

    <!-- 数据面板 -->
    <div class="stats-row">
      <div class="stat-item">
        <div class="stat-icon" style="background:linear-gradient(135deg,#3b82f6,#60a5fa)">📍</div>
        <div class="stat-detail">
          <span class="stat-value">{{ user.total_km }}</span>
          <span class="stat-label">总里程(km)</span>
        </div>
      </div>
      <div class="stat-item">
        <div class="stat-icon" style="background:linear-gradient(135deg,#10b981,#34d399)">✅</div>
        <div class="stat-detail">
          <span class="stat-value">{{ user.total_checkin }}</span>
          <span class="stat-label">打卡次数</span>
        </div>
      </div>
      <div class="stat-item clickable" @click="openFollowModal('following')">
        <div class="stat-icon" style="background:linear-gradient(135deg,#f59e0b,#fbbf24)">❤️</div>
        <div class="stat-detail">
          <span class="stat-value">{{ followInfo.followingCount }}</span>
          <span class="stat-label">关注</span>
        </div>
      </div>
      <div class="stat-item clickable" @click="openFollowModal('followers')">
        <div class="stat-icon" style="background:linear-gradient(135deg,#8b5cf6,#a78bfa)">👥</div>
        <div class="stat-detail">
          <span class="stat-value">{{ followInfo.followerCount }}</span>
          <span class="stat-label">粉丝</span>
        </div>
      </div>
    </div>

    <!-- 技能标签 -->
    <div v-if="skills.length" class="skill-bar">
      <span class="skill-title">🎯 擅长领域</span>
      <div class="skill-list">
        <span v-for="s in skills" :key="s.id" class="skill-chip">{{ s.name }}</span>
      </div>
    </div>

    <!-- 内容标签页 -->
    <n-tabs type="card" style="margin-top:20px" animated>
      <n-tab-pane name="routes" tab="🗺️ 发布的线路">
        <n-grid :cols="3" :x-gap="14" :y-gap="14" style="margin-top:12px" responsive="screen">
          <n-grid-item v-for="r in user.routes" :key="r.id">
            <RouteCard :route="r" />
          </n-grid-item>
        </n-grid>
        <n-empty v-if="!user.routes?.length" description="暂无线路" style="margin-top:40px" />
      </n-tab-pane>
      <n-tab-pane name="checkins" tab="📍 打卡记录">
        <CheckinTimeline :user-id="userId" />
      </n-tab-pane>
    </n-tabs>

    <!-- 关注/粉丝列表弹窗 -->
    <n-modal v-model:show="showFollowModal" preset="card"
      :title="followModalType === 'followers' ? '👥 粉丝列表' : '❤️ 关注列表'"
      style="width:480px;border-radius:12px">
      <n-spin :show="followListLoading">
        <div v-if="followList.length" class="follow-list">
          <div v-for="u in followList" :key="u.id" class="follow-item" @click="goProfile(u.id)">
            <n-avatar v-if="u.avatar" :src="u.avatar" :size="44" round />
            <div v-else class="follow-avatar-fallback" :style="{ background: avatarColor(u.id) }">
              {{ u.nickname?.[0] || '?' }}
            </div>
            <div class="follow-info">
              <div class="follow-name">{{ u.nickname }}
                <span class="follow-level">Lv.{{ u.level }}</span>
              </div>
              <div class="follow-bio">{{ u.bio || '暂无简介' }}</div>
            </div>
            <span class="follow-arrow">›</span>
          </div>
        </div>
        <n-empty v-else-if="!followListLoading"
          :description="followModalType === 'followers' ? '暂无粉丝' : '暂未关注任何人'" />
      </n-spin>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NAvatar, NTag, NTabs, NTabPane, NGrid, NGridItem, NButton, NEmpty, NModal, NSpin, useMessage } from 'naive-ui'
import { getProfile, getUserSkills, toggleFollow, getFollowInfo, getFollowers, getFollowing } from '@/api/user'
import { createPrivateRoom } from '@/api/chat'
import { useUserStore } from '@/stores/user'
import RouteCard from '@/components/RouteCard.vue'
import CheckinTimeline from '@/components/CheckinTimeline.vue'

const vueRoute = useRoute()
const router = useRouter()
const userStore = useUserStore()
const msg = useMessage()

const userId = computed(() => +vueRoute.params.id)
const user = ref(null)
const skills = ref([])
const followInfo = ref({ followerCount: 0, followingCount: 0, isFollowed: false })

const isSelf = computed(() => userStore.info?.id === userId.value)

// 头像颜色调色板（无头像时按 ID 生成稳定的彩色背景）
const avatarColors = ['#3b82f6','#10b981','#f59e0b','#ef4444','#8b5cf6','#ec4899','#06b6d4','#f97316']
function avatarColor(id) { return avatarColors[(id || 0) % avatarColors.length] }

const showFollowModal = ref(false)
const followModalType = ref('followers')
const followList = ref([])
const followListLoading = ref(false)

async function openFollowModal(type) {
  followModalType.value = type
  showFollowModal.value = true
  followListLoading.value = true
  try {
    const res = type === 'followers' ? await getFollowers(userId.value) : await getFollowing(userId.value)
    followList.value = res.data
  } finally { followListLoading.value = false }
}

function goProfile(id) {
  showFollowModal.value = false
  router.push(`/profile/${id}`)
}

// 加载用户资料、技能、关注信息
async function loadProfileData() {
  const id = userId.value
  const [profileRes, skillRes, followRes] = await Promise.all([
    getProfile(id),
    getUserSkills(id),
    getFollowInfo(id)
  ])
  user.value   = profileRes.data
  skills.value = skillRes.data
  followInfo.value = followRes.data
}

onMounted(loadProfileData)

// 监听路由参数变化，切换不同用户主页时重新加载数据
watch(userId, () => { loadProfileData() })

async function doToggleFollow() {
  if (!userStore.isLoggedIn) return msg.warning('请先登录')
  const res = await toggleFollow(userId.value)
  followInfo.value.isFollowed = res.data.followed
  followInfo.value.followerCount += res.data.followed ? 1 : -1
  msg.success(res.data.followed ? '已关注' : '已取消关注')
}

async function startChat() {
  const res = await createPrivateRoom(userId.value)
  router.push(`/chat/${res.data.roomId}`)
}
</script>

<style scoped>
.profile-page { max-width: 900px; margin: 0 auto; }

/* === Banner === */
.profile-banner {
  height: 140px;
  background: linear-gradient(135deg, #1e3a5f 0%, #2d8cf0 50%, #0ea5e9 100%);
  border-radius: 16px 16px 0 0;
  position: relative;
  overflow: hidden;
}
.banner-pattern {
  position: absolute; inset: 0;
  background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.06'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
}

/* === Profile Card === */
.profile-card {
  background: #fff;
  border: 1px solid #eee;
  border-top: none;
  border-radius: 0 0 16px 16px;
  padding: 0 28px 24px;
  display: flex;
  align-items: flex-start;
  gap: 20px;
  position: relative;
}
.profile-avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  margin-top: -40px;
  flex-shrink: 0;
  border: 4px solid #fff;
  box-shadow: 0 4px 20px rgba(0,0,0,.15);
  overflow: hidden;
  background: #e0e0e0;
}
.profile-avatar .avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}
.profile-avatar .avatar-char {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  color: #fff;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
}
.profile-info { flex: 1; min-width: 0; padding-top: 12px; }
.profile-name { margin: 0; font-size: 24px; font-weight: 800; color: #1a1a2e; }
.profile-meta {
  display: flex; align-items: center; gap: 10px; margin-top: 4px;
}
.level-badge {
  font-size: 12px;
  color: #f59e0b;
  font-weight: 600;
}
.profile-username { font-size: 13px; color: #aaa; }
.profile-bio {
  margin: 8px 0 0;
  font-size: 14px;
  color: #666;
  line-height: 1.6;
}
.profile-actions {
  display: flex;
  gap: 8px;
  padding-top: 16px;
  flex-shrink: 0;
}

/* === Stats Row === */
.stats-row {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12px;
  margin-top: 16px;
}
.stat-item {
  display: flex;
  align-items: center;
  gap: 12px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 14px 16px;
  transition: all .3s;
}
.stat-item.clickable { cursor: pointer; }
.stat-item.clickable:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 16px rgba(0,0,0,.08);
  border-color: #d0e3ff;
}
.stat-icon {
  width: 40px; height: 40px;
  border-radius: 10px;
  display: flex; align-items: center; justify-content: center;
  font-size: 18px;
  flex-shrink: 0;
}
.stat-detail { display: flex; flex-direction: column; }
.stat-value { font-size: 20px; font-weight: 700; color: #333; line-height: 1.2; }
.stat-label { font-size: 11px; color: #999; margin-top: 2px; }

/* === Skill Bar === */
.skill-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 14px;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 12px 16px;
}
.skill-title { font-size: 13px; color: #888; white-space: nowrap; font-weight: 500; }
.skill-list { display: flex; gap: 8px; flex-wrap: wrap; }
.skill-chip {
  font-size: 12px;
  padding: 4px 14px;
  border-radius: 20px;
  background: linear-gradient(135deg, #ecfdf5, #e0f2fe);
  color: #059669;
  font-weight: 600;
  letter-spacing: .5px;
}

/* === Follow Modal === */
.follow-list { display: flex; flex-direction: column; }
.follow-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 10px;
  cursor: pointer;
  transition: background .2s;
}
.follow-item:hover { background: #f5f7fa; }
.follow-info { flex: 1; min-width: 0; }
.follow-name {
  font-weight: 600; font-size: 14px; color: #333;
  display: flex; align-items: center; gap: 6px;
}
.follow-level {
  font-size: 11px;
  color: #f59e0b;
  font-weight: 600;
}
.follow-bio {
  font-size: 12px; color: #999; margin-top: 2px;
  overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
}
.follow-arrow { font-size: 18px; color: #ccc; }
.follow-avatar-fallback {
  width: 44px; height: 44px; border-radius: 50%; flex-shrink: 0;
  display: flex; align-items: center; justify-content: center;
  color: #fff; font-size: 18px; font-weight: 700;
  box-shadow: 0 2px 8px rgba(0,0,0,.1);
}
</style>
