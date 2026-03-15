<template>
  <div class="activity-card" @click="router.push(`/activities/${activity.id}`)">
    <!-- 渐变头部 -->
    <div :class="['card-banner', `status-${activity.status}`]">
      <div class="banner-status">
        <span class="status-dot" />
        {{ statusLabel(activity.status) }}
      </div>
      <div class="banner-date">📅 {{ formatDate(activity.start_time) }}</div>
    </div>
    <!-- 内容 -->
    <div class="card-body">
      <div class="card-title">{{ activity.title }}</div>
      <div class="info-row">
        <span class="info-icon">👥</span>
        <span>{{ activity.current_members }}/{{ activity.max_members }} 人</span>
        <div class="member-bar">
          <div class="member-fill" :style="{ width: fillWidth }" />
        </div>
      </div>
      <div class="info-row" v-if="activity.route">
        <span class="info-icon">📍</span>
        <span class="route-name">{{ activity.route.title }}</span>
      </div>
      <div class="info-row" v-if="activity.min_level > 1">
        <span class="info-icon">⭐</span>
        <span>最低 Lv.{{ activity.min_level }}</span>
      </div>
    </div>
    <div class="card-footer" v-if="activity.organizer">
      <div class="organizer">
        <img v-if="activity.organizer.avatar" :src="activity.organizer.avatar" class="org-avatar" />
        <span v-else class="org-avatar-fallback">{{ activity.organizer.nickname?.[0] }}</span>
        <span>{{ activity.organizer.nickname }}</span>
      </div>
      <span class="footer-action">查看详情 →</span>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import dayjs from 'dayjs'

const props = defineProps({ activity: { type: Object, required: true } })
const router = useRouter()

const formatDate = (d) => dayjs(d).format('MM-DD HH:mm')
const statusLabel = (s) => ['已取消', '招募中', '已满员', '已结束'][s] || '未知'
const fillWidth = computed(() => Math.min((props.activity.current_members / props.activity.max_members) * 100, 100) + '%')
</script>

<style scoped>
.activity-card {
  cursor: pointer;
  border-radius: 14px;
  background: #fff;
  border: 1px solid #eee;
  transition: all .3s ease;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.activity-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0,0,0,.1);
  border-color: #d0e3ff;
}

/* 渐变头部 */
.card-banner {
  padding: 14px 16px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  color: #fff;
  font-size: 13px;
}
.card-banner.status-1 { background: linear-gradient(135deg, #19be6b, #0ea5e9); }
.card-banner.status-2 { background: linear-gradient(135deg, #f0a020, #e65100); }
.card-banner.status-3 { background: linear-gradient(135deg, #8e99a4, #636e72); }
.card-banner.status-0 { background: linear-gradient(135deg, #e74c3c, #c0392b); }
.banner-status {
  display: flex; align-items: center; gap: 6px;
  font-weight: 700; font-size: 13px;
}
.status-dot {
  width: 8px; height: 8px; border-radius: 50%;
  background: rgba(255,255,255,.8);
  display: inline-block;
}
.banner-date { opacity: .9; font-size: 12px; }

/* 内容 */
.card-body { padding: 14px 16px; flex: 1; display: flex; flex-direction: column; gap: 10px; }
.card-title {
  font-weight: 700; font-size: 15px; line-height: 1.4; color: #222;
  overflow: hidden; text-overflow: ellipsis;
  display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2; -webkit-box-orient: vertical;
}
.info-row {
  display: flex; align-items: center; gap: 6px;
  font-size: 13px; color: #555;
}
.info-icon { font-size: 14px; flex-shrink: 0; }
.route-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.member-bar {
  flex: 1; max-width: 80px; height: 5px;
  background: #f0f0f0; border-radius: 3px; overflow: hidden; margin-left: 6px;
}
.member-fill {
  height: 100%; background: linear-gradient(90deg, #19be6b, #2d8cf0);
  border-radius: 3px; transition: width .3s ease;
}

/* 底部 */
.card-footer {
  display: flex; align-items: center; justify-content: space-between;
  padding: 10px 16px; border-top: 1px solid #f0f0f0;
}
.organizer { display: flex; align-items: center; gap: 6px; font-size: 13px; color: #666; }
.org-avatar {
  width: 22px; height: 22px; border-radius: 50%; object-fit: cover;
}
.org-avatar-fallback {
  width: 22px; height: 22px; border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  display: flex; align-items: center; justify-content: center;
  font-size: 11px; color: #fff; font-weight: 600;
}
.footer-action {
  font-size: 12px; color: #2d8cf0; font-weight: 500;
}
</style>
