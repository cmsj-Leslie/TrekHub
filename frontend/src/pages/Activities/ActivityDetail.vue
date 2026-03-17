<template>
  <div v-if="activity" class="activity-detail">
    <!-- 顶部 Banner -->
    <div :class="['detail-banner', `status-${activity.status}`]">
      <div class="banner-left">
        <n-button text style="color:#fff;font-size:14px" @click="$router.back()">← 返回</n-button>
        <h2>{{ activity.title }}</h2>
        <div class="banner-meta">
          <span>📅 {{ formatDate(activity.start_time) }} ~ {{ formatDate(activity.end_time) }}</span>
          <span>👥 {{ activity.current_members }}/{{ activity.max_members }} 人</span>
        </div>
      </div>
      <div class="banner-right">
        <div :class="['status-badge', `s-${activity.status}`]">{{ statusLabel(activity.status) }}</div>
        <n-button v-if="canApply" type="primary" strong round @click="showApply = true">🙋 申请参加</n-button>
        <n-button v-if="canChat" round @click="router.push(`/chat/${activity.chatRoomId}`)">💬 进入群聊</n-button>
      </div>
    </div>

    <div class="detail-grid">
      <!-- 左侧 -->
      <div class="detail-left">
        <!-- 基本信息 -->
        <div class="info-card">
          <h3>📋 活动信息</h3>
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">出发时间</span>
              <span class="info-value">{{ formatDate(activity.start_time) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">结束时间</span>
              <span class="info-value">{{ formatDate(activity.end_time) }}</span>
            </div>
            <div class="info-item">
              <span class="info-label">招募人数</span>
              <span class="info-value">
                {{ activity.current_members }}/{{ activity.max_members }} 人
                <div class="mini-bar"><div class="mini-fill" :style="{ width: fillWidth }" /></div>
              </span>
            </div>
            <div class="info-item">
              <span class="info-label">最低等级</span>
              <span class="info-value">Lv.{{ activity.min_level }}</span>
            </div>
            <div class="info-item" v-if="activity.route">
              <span class="info-label">关联线路</span>
              <router-link :to="`/routes/${activity.route.id}`" class="route-link">
                🗺️ {{ activity.route.title }}
              </router-link>
            </div>
          </div>
        </div>

        <!-- 安全警告横幅（醒目增强） -->
        <div class="safety-banner" v-if="activity.safety_info || activity.gear_require">
          <div class="safety-banner-header">
            <span class="safety-icon-pulse">⚠️</span>
            <span class="safety-banner-title">安全警告 · 出行前请仔细阅读</span>
          </div>
          <div v-if="activity.safety_info" class="safety-banner-body">
            <div class="safety-label">🚨 注意事项</div>
            <div class="safety-text">{{ activity.safety_info }}</div>
          </div>
          <div v-if="activity.gear_require" class="safety-banner-body" style="border-top:1px dashed #fde68a">
            <div class="safety-label">🎒 必备装备</div>
            <div class="safety-text">{{ activity.gear_require }}</div>
          </div>
        </div>

        <!-- 活动描述 -->
        <div class="info-card" v-if="activity.description">
          <h3>📝 活动介绍</h3>
          <p style="white-space:pre-wrap">{{ activity.description }}</p>
        </div>

        <!-- 待审核（仅组织者） -->
        <div class="info-card" v-if="isOrganizer && pendingMembers.length">
          <h3>🔔 待审核申请 <span class="pending-count">{{ pendingMembers.length }}</span></h3>
          <div v-for="m in pendingMembers" :key="m.id" class="review-item">
            <div class="review-user">
              <img v-if="m.user?.avatar" :src="m.user.avatar" class="member-img" />
              <span v-else class="member-fallback">{{ m.user?.nickname?.[0] }}</span>
              <div>
                <span class="review-name">{{ m.user?.nickname }}</span>
                <span class="review-level">Lv.{{ m.user?.level }}</span>
              </div>
            </div>
            <div v-if="m.apply_msg" class="review-msg">"{{ m.apply_msg }}"</div>
            <div class="review-actions">
              <n-button size="small" type="primary" round @click="review(m.id, 'approve')">✓ 通过</n-button>
              <n-button size="small" type="error" round @click="review(m.id, 'reject')">✗ 拒绝</n-button>
            </div>
          </div>
        </div>

        <!-- 评论 -->
        <div class="info-card">
          <h3>💬 讨论区</h3>
          <CommentList :target-type="2" :target-id="activity.id" />
        </div>

        <!-- 活动互评（仅活动已结束时展示） -->
        <div class="info-card" v-if="activity.status === 3">
          <h3>⭐ 活动互评</h3>

          <!-- 评价表单：仅已通过的成员且活动已结束 -->
          <div v-if="isApproved && reviewableMembers.length" class="review-section">
            <div v-for="m in reviewableMembers" :key="m.user?.id" class="review-form-item">
              <div class="review-target">
                <img v-if="m.user?.avatar" :src="m.user.avatar" class="member-img" />
                <span v-else class="member-fallback">{{ m.user?.nickname?.[0] }}</span>
                <span class="review-target-name">{{ m.user?.nickname }}</span>
                <n-rate v-if="!myReviewedIds.has(m.user?.id)" v-model:value="reviewForms[m.user?.id].rating" size="small" />
                <span v-else class="reviewed-tag">✓ 已评价</span>
              </div>
              <template v-if="!myReviewedIds.has(m.user?.id)">
                <n-input v-model:value="reviewForms[m.user?.id].content" placeholder="写一句评价（选填）" size="small" />
                <n-button size="small" type="primary" round :loading="reviewSubmitting" style="margin-top:6px;align-self:flex-end"
                  @click="doSubmitReview(m.user?.id)">提交评价</n-button>
              </template>
            </div>
          </div>
          <div v-else-if="isApproved" style="color:#999;font-size:13px">没有其他成员可评价</div>
          <div v-else-if="userStore.isLoggedIn" style="color:#999;font-size:13px">仅活动成员可参与互评</div>

          <!-- 已有评价列表 -->
          <div v-if="activityReviews.length" style="margin-top:16px">
            <div class="review-divider">已有评价（{{ activityReviews.length }}）</div>
            <div v-for="r in activityReviews" :key="r.id" class="review-card">
              <div class="review-card-header">
                <img v-if="r.reviewer?.avatar" :src="r.reviewer.avatar" class="member-img" />
                <span v-else class="member-fallback">{{ r.reviewer?.nickname?.[0] }}</span>
                <span class="review-card-name">{{ r.reviewer?.nickname }}</span>
                <span class="review-arrow">→</span>
                <img v-if="r.reviewee?.avatar" :src="r.reviewee.avatar" class="member-img" />
                <span v-else class="member-fallback">{{ r.reviewee?.nickname?.[0] }}</span>
                <span class="review-card-name">{{ r.reviewee?.nickname }}</span>
                <n-rate :value="r.rating" readonly size="small" style="margin-left:auto" />
              </div>
              <div v-if="r.content" class="review-card-content">{{ r.content }}</div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧：成员 -->
      <div class="detail-right">
        <div class="info-card members-card">
          <h3>👥 活动成员 <span class="member-count">{{ approvedMembers.length }}</span></h3>
          <div v-for="m in approvedMembers" :key="m.id" class="member-row"
            @click="router.push(`/profile/${m.user?.id}`)">
            <img v-if="m.user?.avatar" :src="m.user.avatar" class="member-img" />
            <span v-else class="member-fallback">{{ m.user?.nickname?.[0] }}</span>
            <span class="member-name">{{ m.user?.nickname }}</span>
            <span v-if="m.role === 1" class="org-tag">组织者</span>
          </div>
          <div v-if="!approvedMembers.length" class="no-members">暂无成员</div>
        </div>

        <!-- 组织者信息 -->
        <div class="info-card" v-if="activity.organizer">
          <h3>👤 发起人</h3>
          <div class="organizer-info" @click="router.push(`/profile/${activity.organizer.id}`)">
            <img v-if="activity.organizer.avatar" :src="activity.organizer.avatar" class="org-img" />
            <span v-else class="member-fallback lg">{{ activity.organizer.nickname?.[0] }}</span>
            <div>
              <div class="org-name">{{ activity.organizer.nickname }}</div>
              <div class="org-sub">Lv.{{ activity.organizer.level || 1 }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 申请弹窗 -->
    <n-modal v-model:show="showApply" title="申请参加活动" style="width:420px">
      <n-card title="🙋 申请参加" :bordered="false">
        <n-input v-model:value="applyMsg" type="textarea" placeholder="向组织者介绍自己（可选）" :rows="3" />
        <n-space justify="end" style="margin-top:14px">
          <n-button round @click="showApply = false">取消</n-button>
          <n-button type="primary" round :loading="applying" @click="doApply">提交申请</n-button>
        </n-space>
      </n-card>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { NButton, NCard, NModal, NInput, NSpace, NRate, useMessage } from 'naive-ui'
import dayjs from 'dayjs'
import { getActivity, applyActivity, reviewMember, submitReview, getActivityReviews } from '@/api/activity'
import { useUserStore } from '@/stores/user'
import CommentList from '@/components/CommentList.vue'

const vueRoute = useRoute()
const router = useRouter()
const msg = useMessage()
const userStore = useUserStore()

const activity = ref(null)
const showApply = ref(false)
const applyMsg = ref('')
const applying = ref(false)

// 活动互评相关
const activityReviews = ref([])
const myReviewedIds = reactive(new Set())  // 当前用户已评价过的成员 ID 集合
const reviewForms = reactive({})           // { userId: { rating: 0, content: '' } }
const reviewSubmitting = ref(false)

const isOrganizer = computed(() => activity.value?.organizer_id === userStore.info?.id)
const approvedMembers = computed(() => activity.value?.members?.filter(m => m.status === 1) || [])
const pendingMembers  = computed(() => activity.value?.members?.filter(m => m.status === 0) || [])
const isApproved = computed(() => approvedMembers.value.some(m => m.user?.id === userStore.info?.id))
const canApply = computed(() => {
  if (!userStore.isLoggedIn || isOrganizer.value) return false
  return activity.value?.status === 1 && activity.value?.myStatus === null
})
const canChat = computed(() => {
  if (!activity.value?.chatRoomId) return false
  return isOrganizer.value || isApproved.value
})
// 可评价的成员（排除自己）
const reviewableMembers = computed(() =>
  approvedMembers.value.filter(m => m.user?.id !== userStore.info?.id)
)
const fillWidth = computed(() => {
  if (!activity.value) return '0%'
  return Math.min((activity.value.current_members / activity.value.max_members) * 100, 100) + '%'
})

const formatDate = (d) => dayjs(d).format('YYYY-MM-DD HH:mm')
const statusLabel = (s) => ['已取消', '招募中', '已满员', '已结束'][s] || ''

async function load() {
  const res = await getActivity(vueRoute.params.id)
  activity.value = res.data
  // 如果活动已结束，加载评价数据
  if (res.data.status === 3) {
    await loadReviews()
  }
}

// 加载活动评价列表
async function loadReviews() {
  try {
    const res = await getActivityReviews(vueRoute.params.id)
    activityReviews.value = res.data
    // 标记当前用户已评过的成员
    myReviewedIds.clear()
    res.data.forEach(r => {
      if (r.reviewer_id === userStore.info?.id) myReviewedIds.add(r.reviewee_id)
    })
    // 初始化评价表单
    reviewableMembers.value.forEach(m => {
      if (!reviewForms[m.user?.id]) {
        reviewForms[m.user?.id] = { rating: 5, content: '' }
      }
    })
  } catch (e) { /* 忽略 */ }
}

// 提交评价
async function doSubmitReview(revieweeId) {
  const form = reviewForms[revieweeId]
  if (!form?.rating) return msg.warning('请选择评分')
  reviewSubmitting.value = true
  try {
    await submitReview({
      activity_id: activity.value.id,
      reviewee_id: revieweeId,
      rating: form.rating,
      content: form.content
    })
    msg.success('评价成功')
    myReviewedIds.add(revieweeId)
    await loadReviews()
  } catch (e) {
    msg.error(e.response?.data?.msg || '评价失败')
  } finally { reviewSubmitting.value = false }
}

async function doApply() {
  applying.value = true
  try {
    await applyActivity(activity.value.id, { apply_msg: applyMsg.value })
    msg.success('申请已提交，等待组织者审批')
    showApply.value = false
    load()
  } finally { applying.value = false }
}

async function review(memberId, action) {
  await reviewMember({ memberId, action })
  msg.success(action === 'approve' ? '已通过' : '已拒绝')
  load()
}

onMounted(load)
</script>

<style scoped>
.activity-detail { max-width: 1000px; margin: 0 auto; }

/* Banner */
.detail-banner {
  border-radius: 16px;
  padding: 28px 28px;
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
}
.detail-banner.status-1 { background: linear-gradient(135deg, #19be6b, #0ea5e9); }
.detail-banner.status-2 { background: linear-gradient(135deg, #f0a020, #e65100); }
.detail-banner.status-3 { background: linear-gradient(135deg, #8e99a4, #636e72); }
.detail-banner.status-0 { background: linear-gradient(135deg, #e74c3c, #c0392b); }
.banner-left h2 { margin: 8px 0 6px; font-size: 22px; font-weight: 800; }
.banner-meta { display: flex; gap: 16px; font-size: 13px; opacity: .9; }
.banner-right { display: flex; flex-direction: column; align-items: flex-end; gap: 10px; }
.status-badge {
  padding: 4px 16px; border-radius: 20px; font-weight: 700; font-size: 13px;
  background: rgba(255,255,255,.2); backdrop-filter: blur(4px);
}

/* Grid */
.detail-grid { display: flex; gap: 20px; }
.detail-left { flex: 2; display: flex; flex-direction: column; gap: 16px; }
.detail-right { flex: 1; display: flex; flex-direction: column; gap: 16px; }

/* Info Cards */
.info-card {
  background: #fff; border: 1px solid #eee; border-radius: 14px;
  padding: 18px 20px;
}
.info-card h3 { margin: 0 0 14px; font-size: 15px; font-weight: 700; color: #222; }
.warning-card { border-left: 4px solid #f0a020; background: #fffbf0; }
.warning-card p { color: #8a6d3b; }
.info-card p { margin: 0; color: #555; font-size: 14px; line-height: 1.7; }

.info-grid { display: flex; flex-direction: column; gap: 10px; }
.info-item { display: flex; align-items: center; gap: 8px; font-size: 14px; }
.info-label { color: #999; min-width: 70px; font-weight: 500; }
.info-value { color: #333; font-weight: 500; display: flex; align-items: center; gap: 8px; }
.route-link { color: #2d8cf0; text-decoration: none; font-weight: 500; font-size: 14px; }
.route-link:hover { text-decoration: underline; }

.mini-bar { width: 60px; height: 4px; background: #f0f0f0; border-radius: 2px; overflow: hidden; }
.mini-fill { height: 100%; background: linear-gradient(90deg, #19be6b, #2d8cf0); border-radius: 2px; }

/* Members */
.member-count, .pending-count {
  font-size: 12px; background: #2d8cf0; color: #fff; padding: 1px 8px;
  border-radius: 10px; margin-left: 6px; font-weight: 600;
}
.pending-count { background: #f0a020; }
.member-row {
  display: flex; align-items: center; gap: 8px;
  padding: 8px 0; border-bottom: 1px solid #f8f8f8;
  cursor: pointer; transition: background .2s;
}
.member-row:hover { background: #f8fafc; }
.member-row:last-child { border-bottom: none; }
.member-img { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; }
.member-fallback {
  width: 32px; height: 32px; border-radius: 50%; flex-shrink: 0;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; color: #fff; font-weight: 600;
}
.member-fallback.lg { width: 44px; height: 44px; font-size: 17px; }
.member-name { font-size: 14px; color: #333; font-weight: 500; }
.org-tag {
  font-size: 11px; background: #e3f2fd; color: #1565c0;
  padding: 1px 8px; border-radius: 8px; font-weight: 600; margin-left: auto;
}
.no-members { color: #ccc; text-align: center; padding: 20px; font-size: 13px; }

/* Review */
.review-item {
  padding: 12px; border: 1px solid #f0f0f0; border-radius: 10px;
  margin-bottom: 10px; background: #fafbfc;
}
.review-user { display: flex; align-items: center; gap: 8px; }
.review-name { font-weight: 600; font-size: 14px; color: #333; }
.review-level { font-size: 12px; color: #999; margin-left: 6px; }
.review-msg { font-size: 13px; color: #666; margin: 8px 0; font-style: italic; }
.review-actions { display: flex; gap: 8px; justify-content: flex-end; }

/* Organizer */
.organizer-info {
  display: flex; align-items: center; gap: 10px;
  cursor: pointer; padding: 4px 0;
}
.org-img { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; }
.org-name { font-weight: 600; font-size: 15px; color: #333; }
.org-sub { font-size: 12px; color: #999; }

/* === 安全警告横幅 === */
.safety-banner {
  background: linear-gradient(135deg, #fffbeb, #fef3c7);
  border: 2px solid #f59e0b;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(245, 158, 11, 0.15);
  margin-bottom: 14px;
}
.safety-banner-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 18px;
  background: linear-gradient(135deg, #f59e0b, #d97706);
  color: #fff;
  font-weight: 700;
  font-size: 15px;
}
.safety-icon-pulse {
  font-size: 20px;
  animation: safety-pulse 1.5s ease-in-out infinite;
}
@keyframes safety-pulse {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.25); }
}
.safety-banner-title { letter-spacing: 0.5px; }
.safety-banner-body { padding: 14px 18px; }
.safety-label {
  font-size: 13px;
  font-weight: 700;
  color: #92400e;
  margin-bottom: 6px;
}
.safety-text {
  font-size: 14px;
  color: #78350f;
  line-height: 1.8;
  white-space: pre-wrap;
}

/* === 活动互评 === */
.review-section { display: flex; flex-direction: column; gap: 14px; }
.review-form-item {
  display: flex; flex-direction: column; gap: 6px;
  padding: 12px; background: #f8fafc; border-radius: 10px;
  border: 1px solid #f0f0f0;
}
.review-target {
  display: flex; align-items: center; gap: 8px;
}
.review-target-name { font-weight: 600; font-size: 14px; color: #333; margin-right: 8px; }
.reviewed-tag {
  font-size: 12px; color: #10b981; font-weight: 600;
  background: #ecfdf5; padding: 2px 10px; border-radius: 12px;
}
.review-divider {
  font-size: 13px; color: #999; font-weight: 500;
  padding-bottom: 8px; border-bottom: 1px solid #f0f0f0; margin-bottom: 10px;
}
.review-card {
  padding: 12px; background: #fafbfc; border-radius: 10px;
  border: 1px solid #f0f0f0; margin-bottom: 8px;
}
.review-card-header {
  display: flex; align-items: center; gap: 6px; flex-wrap: wrap;
}
.review-card-name { font-weight: 600; font-size: 13px; color: #333; }
.review-arrow { color: #ccc; font-size: 14px; }
.review-card-content {
  margin-top: 8px; font-size: 13px; color: #555; line-height: 1.6;
  padding-left: 40px;
}
</style>
