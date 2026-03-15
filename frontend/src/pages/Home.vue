<template>
  <div>
    <!-- Banner -->
    <div style="background:linear-gradient(135deg,#2d8cf0,#0070c0);color:#fff;padding:48px 24px;text-align:center;border-radius:12px;margin-bottom:32px">
      <h1 style="margin:0 0 12px;font-size:32px">发现你的下一段徒步旅程</h1>
      <p style="margin:0 0 24px;opacity:.85">专业线路规划 · 可信组队搭档 · AI智能助手</p>
      <n-space justify="center">
        <router-link to="/routes"><n-button type="primary" size="large">探索线路</n-button></router-link>
        <router-link to="/match"><n-button size="large" ghost>随机组队</n-button></router-link>
      </n-space>
    </div>

    <!-- 平台数据统计 -->
    <div class="platform-stats">
      <router-link to="/routes" class="stat-block" style="text-decoration:none">
        <div class="stat-number">{{ platformStats.routeCount || 0 }}</div>
        <div class="stat-desc">精选线路</div>
      </router-link>
      <router-link to="/activities" class="stat-block" style="text-decoration:none">
        <div class="stat-number">{{ platformStats.activityCount || 0 }}</div>
        <div class="stat-desc">徒步活动</div>
      </router-link>
      <router-link to="/routes" class="stat-block" style="text-decoration:none">
        <div class="stat-number">{{ platformStats.userCount || 0 }}</div>
        <div class="stat-desc">注册徒步者</div>
      </router-link>
      <router-link to="/checkin" class="stat-block" style="text-decoration:none">
        <div class="stat-number">{{ platformStats.checkinCount || 0 }}</div>
        <div class="stat-desc">打卡记录</div>
      </router-link>
    </div>

    <!-- 推荐线路 -->
    <div v-if="userStore.isLoggedIn">
      <n-divider>为你推荐</n-divider>
      <n-spin :show="recLoading">
        <n-grid :cols="4" :x-gap="16" :y-gap="16" responsive="screen">
          <n-grid-item v-for="r in recommended" :key="r.id">
            <RouteCard :route="r" />
          </n-grid-item>
        </n-grid>
      </n-spin>
    </div>

    <!-- 热门活动 -->
    <n-divider>热门活动</n-divider>
    <n-spin :show="actLoading">
      <n-grid :cols="3" :x-gap="16" :y-gap="16" responsive="screen">
        <n-grid-item v-for="a in hotActivities" :key="a.id">
          <n-card hoverable style="cursor:pointer" @click="$router.push(`/activities/${a.id}`)">
            <template #header>
              <n-ellipsis style="max-width:200px">{{ a.title }}</n-ellipsis>
            </template>
            <template #header-extra>
              <n-tag :type="a.status === 1 ? 'success' : 'warning'" size="small">
                {{ a.status === 1 ? '招募中' : '已满' }}
              </n-tag>
            </template>
            <n-space vertical :size="6">
              <span style="font-size:13px;color:#666">📍 {{ a.route?.title || '未关联' }}</span>
              <span style="font-size:13px;color:#666">👥 {{ a.current_members }}/{{ a.max_members }} 人</span>
              <span style="font-size:13px;color:#999">🧑 {{ a.organizer?.nickname }}</span>
            </n-space>
          </n-card>
        </n-grid-item>
      </n-grid>
      <n-empty v-if="!actLoading && !hotActivities.length" description="暂无活动" />
    </n-spin>
    <div style="text-align:center;margin-top:12px">
      <router-link to="/activities"><n-button text>查看全部活动 →</n-button></router-link>
    </div>

    <!-- 最新线路 -->
    <n-divider>最新线路</n-divider>
    <n-spin :show="loading">
      <n-grid :cols="4" :x-gap="16" :y-gap="16" responsive="screen">
        <n-grid-item v-for="r in list" :key="r.id">
          <RouteCard :route="r" />
        </n-grid-item>
      </n-grid>
    </n-spin>
    <div style="text-align:center;margin-top:24px">
      <router-link to="/routes"><n-button>查看全部线路</n-button></router-link>
    </div>

    <!-- 最近打卡动态 -->
    <n-divider>最近打卡动态</n-divider>
    <n-spin :show="checkinLoading">
      <n-grid :cols="2" :x-gap="16" :y-gap="16" responsive="screen">
        <n-grid-item v-for="c in recentCheckins" :key="c.id">
          <n-card size="small" hoverable style="cursor:pointer" @click="$router.push('/checkin')">
            <n-space align="center" justify="space-between">
              <n-space align="center">
                <n-avatar :src="c.user?.avatar" round size="small" />
                <span style="font-weight:600;font-size:14px">{{ c.user?.nickname }}</span>
              </n-space>
              <span style="color:#999;font-size:12px">{{ dayjs(c.checkin_at).fromNow() }}</span>
            </n-space>
            <div v-if="c.title" style="font-weight:600;margin-top:6px;font-size:14px">{{ c.title }}</div>
            <div v-if="c.content" style="color:#666;font-size:13px;margin-top:4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ c.content }}</div>
            <n-space v-if="c.images?.length" style="margin-top:6px">
              <img v-for="img in c.images.slice(0,3)" :key="img" :src="img" style="width:60px;height:60px;object-fit:cover;border-radius:4px" />
            </n-space>
            <div v-if="c.distance_km" style="margin-top:6px;color:#2d8cf0;font-size:12px">📏 {{ c.distance_km }} km</div>
          </n-card>
        </n-grid-item>
      </n-grid>
      <n-empty v-if="!checkinLoading && !recentCheckins.length" description="暂无打卡" />
    </n-spin>
    <div style="text-align:center;margin-top:12px">
      <router-link to="/checkin"><n-button text>查看更多打卡 →</n-button></router-link>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { NGrid, NGridItem, NDivider, NButton, NSpace, NSpin, NCard, NTag, NAvatar, NEmpty, NEllipsis } from 'naive-ui'
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'
import { useUserStore } from '@/stores/user'
import { getRoutes, getRecommended } from '@/api/route'
import { getActivities } from '@/api/activity'
import { getCheckins } from '@/api/social'
import { getPublicStats } from '@/api/admin'
import RouteCard from '@/components/RouteCard.vue'

dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

const userStore = useUserStore()
const list = ref([])
const recommended = ref([])
const hotActivities = ref([])
const recentCheckins = ref([])
const platformStats = ref({})
const loading = ref(false)
const recLoading = ref(false)
const actLoading = ref(false)
const checkinLoading = ref(false)

onMounted(async () => {
  loading.value = true
  actLoading.value = true
  checkinLoading.value = true

  // 各自独立请求，互不影响
  getPublicStats().then(r => { platformStats.value = r.data }).catch(() => {})

  getRoutes({ pageSize: 8 }).then(r => { list.value = r.data.list }).catch(() => {}).finally(() => { loading.value = false })

  getActivities({ pageSize: 6, status: 1 }).then(r => { hotActivities.value = r.data.list }).catch(() => {}).finally(() => { actLoading.value = false })

  // 打卡需要 user_id，登录用户才加载
  if (userStore.isLoggedIn && userStore.info?.id) {
    getCheckins({ pageSize: 4, user_id: userStore.info.id }).then(r => { recentCheckins.value = r.data.list }).catch(() => {}).finally(() => { checkinLoading.value = false })
  } else {
    checkinLoading.value = false
  }

  if (userStore.isLoggedIn) {
    recLoading.value = true
    getRecommended().then(r => { recommended.value = r.data.slice(0, 4) }).catch(() => {}).finally(() => { recLoading.value = false })
  }
})
</script>

<style scoped>
.platform-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 16px;
  margin-bottom: 32px;
}
.stat-block {
  text-align: center;
  background: #fff;
  border-radius: 10px;
  padding: 20px 12px;
  border: 1px solid #e8e8e8;
}
.stat-number {
  font-size: 28px;
  font-weight: 700;
  color: #2d8cf0;
}
.stat-desc {
  font-size: 13px;
  color: #999;
  margin-top: 4px;
}
@media (max-width: 768px) {
  .platform-stats { grid-template-columns: repeat(2, 1fr); }
}
</style>
