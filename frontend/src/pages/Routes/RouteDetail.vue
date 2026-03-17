<template>
  <div v-if="route" class="route-detail">
    <!-- 顶部标题栏 -->
    <n-page-header :title="route.title" @back="$router.back()">
      <template #extra>
        <n-space>
          <n-button :type="favorited ? 'error' : 'default'" @click="toggle">
            {{ favorited ? '❤️ 已收藏' : '🩶 收藏' }}
          </n-button>
          <n-button @click="shareRoute">📤 分享</n-button>
          <router-link :to="`/activities/create?routeId=${route.id}`">
            <n-button type="primary">基于此线路发起活动</n-button>
          </router-link>
        </n-space>
      </template>
    </n-page-header>

    <!-- 地图 + 统计 双栏布局 -->
    <div class="map-layout">
      <!-- 左侧：地图 + 海拔剖面图 -->
      <div class="map-col">
        <div id="route-map" class="map-container"></div>
        <!-- 海拔剖面图 -->
        <div v-if="route.points?.length" class="elevation-profile">
          <div class="profile-title">📈 海拔剖面图</div>
          <canvas ref="elevCanvas" class="profile-canvas"></canvas>
          <div class="profile-axis">
            <span>起点</span>
            <span>距离 ({{ route.distance_km }} km)</span>
            <span>终点</span>
          </div>
        </div>
      </div>

      <!-- 右侧：线路统计 -->
      <div class="stats-col">
        <div class="stats-card">
          <div class="stats-header">
            <n-tag :type="difficultyType(route.difficulty)" size="large">
              {{ difficultyLabel(route.difficulty) }}
            </n-tag>
          </div>

          <div class="stat-value-big">{{ route.distance_km }}<span class="stat-unit">km</span></div>
          <div class="stat-label">总距离</div>
          <n-divider style="margin:12px 0" />

          <div class="stat-grid">
            <div class="stat-item">
              <div class="stat-num">{{ route.duration_h }}<span class="stat-unit">h</span></div>
              <div class="stat-sub">预计时长</div>
            </div>
            <div class="stat-item">
              <div class="stat-num">{{ avgSpeed }}<span class="stat-unit">km/h</span></div>
              <div class="stat-sub">平均速度</div>
            </div>
          </div>
          <n-divider style="margin:12px 0" />

          <div class="stat-grid">
            <div class="stat-item">
              <div class="stat-num up">{{ route.elevation_m }}<span class="stat-unit">m</span></div>
              <div class="stat-sub">↑ 累计爬升</div>
            </div>
            <div class="stat-item">
              <div class="stat-num">{{ maxElevation }}<span class="stat-unit">m</span></div>
              <div class="stat-sub">最高海拔</div>
            </div>
          </div>
          <n-divider style="margin:12px 0" />

          <div class="stat-grid">
            <div class="stat-item">
              <div class="stat-num">{{ minElevation }}<span class="stat-unit">m</span></div>
              <div class="stat-sub">最低海拔</div>
            </div>
            <div class="stat-item">
              <div class="stat-num">{{ elevDiff }}<span class="stat-unit">m</span></div>
              <div class="stat-sub">海拔落差</div>
            </div>
          </div>
          <n-divider style="margin:12px 0" />

          <div class="stat-meta">
            <div><n-avatar :src="route.creator?.avatar" size="small" round /> {{ route.creator?.nickname }}</div>
            <div>👁 {{ route.view_count }} 浏览 · ❤️ {{ route.like_count }} 收藏</div>
            <div>📍 {{ route.region }}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 线路描述 -->
    <n-card v-if="route.description" title="线路介绍" style="margin-top:16px">
      <div style="line-height:1.8;white-space:pre-wrap">{{ route.description }}</div>
    </n-card>

    <!-- 安全提示（醒目警告横幅） -->
    <div v-if="route.safety_note || route.gear_list" class="safety-banner" style="margin-top:16px">
      <div class="safety-banner-header">
        <span class="safety-icon-pulse">⚠️</span>
        <span class="safety-banner-title">安全警告 · 出行前请仔细阅读</span>
      </div>
      <div v-if="route.safety_note" class="safety-banner-body">
        <div class="safety-label">🚨 注意事项</div>
        <div class="safety-text">{{ route.safety_note }}</div>
      </div>
      <div v-if="route.gear_list" class="safety-banner-body" style="border-top:1px dashed #fde68a">
        <div class="safety-label">🎒 必备装备</div>
        <div class="safety-text">{{ route.gear_list }}</div>
      </div>
    </div>

    <!-- 评论 -->
    <n-card title="评价与讨论" style="margin-top:16px">
      <CommentList :target-type="1" :target-id="route.id" />
    </n-card>
  </div>
  <n-spin v-else :show="true" style="margin-top:80px" />
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import { useRoute } from 'vue-router'
import {
  NPageHeader, NTag, NAvatar, NCard, NButton, NSpace, NSpin, NDivider, useMessage
} from 'naive-ui'
import { getRoute } from '@/api/route'
import { useFavorite } from '@/composables/useFavorite'
import { useMap } from '@/composables/useMap'
import CommentList from '@/components/CommentList.vue'

const msg = useMessage()
const vueRoute = useRoute()
const route = ref(null)
const elevCanvas = ref(null)

const { favorited, check, toggle: rawToggle } = useFavorite(1, +vueRoute.params.id)

// 收藏切换后同步更新页面显示的收藏数
async function toggle() {
  await rawToggle()
  if (route.value) {
    route.value.like_count += favorited.value ? 1 : -1
  }
}

const { init, drawRoute } = useMap('route-map')

const difficultyLabel = (d) => ['', '简单', '中等', '困难', '专家', '极限'][d] || '中等'
const difficultyType  = (d) => ['', 'success', 'info', 'warning', 'error', 'error'][d] || 'info'

// 计算统计数据
const avgSpeed = computed(() => {
  if (!route.value?.duration_h || !route.value?.distance_km) return '-'
  return (route.value.distance_km / route.value.duration_h).toFixed(1)
})
const elevations = computed(() => {
  if (!route.value?.points?.length) return []
  return route.value.points.map(p => +(p.elevation || p.el || 0))
})
const maxElevation = computed(() => elevations.value.length ? Math.max(...elevations.value) : '-')
const minElevation = computed(() => elevations.value.length ? Math.min(...elevations.value) : '-')
const elevDiff = computed(() => {
  if (maxElevation.value === '-') return '-'
  return maxElevation.value - minElevation.value
})

// 绘制海拔剖面图
function drawElevationProfile() {
  const canvas = elevCanvas.value
  if (!canvas || !elevations.value.length) return

  const dpr = window.devicePixelRatio || 1
  const rect = canvas.getBoundingClientRect()
  canvas.width = rect.width * dpr
  canvas.height = rect.height * dpr

  const ctx = canvas.getContext('2d')
  ctx.scale(dpr, dpr)

  const w = rect.width
  const h = rect.height
  const pad = { top: 20, right: 50, bottom: 25, left: 10 }
  const cw = w - pad.left - pad.right
  const ch = h - pad.top - pad.bottom

  const data = elevations.value
  const maxE = Math.max(...data)
  const minE = Math.min(...data)
  const range = maxE - minE || 1

  // 背景
  ctx.fillStyle = '#fafafa'
  ctx.fillRect(0, 0, w, h)

  // 水平网格线
  ctx.strokeStyle = '#e0e0e0'
  ctx.lineWidth = 0.5
  for (let i = 0; i <= 4; i++) {
    const y = pad.top + (ch / 4) * i
    ctx.beginPath()
    ctx.moveTo(pad.left, y)
    ctx.lineTo(w - pad.right, y)
    ctx.stroke()
    // 海拔标注
    const elev = Math.round(maxE - (range / 4) * i)
    ctx.fillStyle = '#999'
    ctx.font = '11px sans-serif'
    ctx.textAlign = 'left'
    ctx.fillText(`${elev}m`, w - pad.right + 5, y + 4)
  }

  // 绘制填充区域
  const gradient = ctx.createLinearGradient(0, pad.top, 0, pad.top + ch)
  gradient.addColorStop(0, 'rgba(231, 76, 60, 0.4)')
  gradient.addColorStop(1, 'rgba(231, 76, 60, 0.05)')

  ctx.beginPath()
  ctx.moveTo(pad.left, pad.top + ch)
  for (let i = 0; i < data.length; i++) {
    const x = pad.left + (cw / (data.length - 1)) * i
    const y = pad.top + ch - ((data[i] - minE) / range) * ch
    if (i === 0) ctx.lineTo(x, y)
    else ctx.lineTo(x, y)
  }
  ctx.lineTo(pad.left + cw, pad.top + ch)
  ctx.closePath()
  ctx.fillStyle = gradient
  ctx.fill()

  // 绘制折线
  ctx.beginPath()
  for (let i = 0; i < data.length; i++) {
    const x = pad.left + (cw / (data.length - 1)) * i
    const y = pad.top + ch - ((data[i] - minE) / range) * ch
    if (i === 0) ctx.moveTo(x, y)
    else ctx.lineTo(x, y)
  }
  ctx.strokeStyle = '#e74c3c'
  ctx.lineWidth = 2.5
  ctx.lineJoin = 'round'
  ctx.stroke()

  // 标注最高点
  const maxIdx = data.indexOf(maxE)
  const maxX = pad.left + (cw / (data.length - 1)) * maxIdx
  const maxY = pad.top
  ctx.fillStyle = '#e74c3c'
  ctx.beginPath()
  ctx.arc(maxX, maxY + 2, 4, 0, Math.PI * 2)
  ctx.fill()
  ctx.fillStyle = '#c0392b'
  ctx.font = 'bold 11px sans-serif'
  ctx.textAlign = 'center'
  ctx.fillText(`▲ ${maxE}m`, maxX, maxY - 5)
}

onMounted(async () => {
  const res = await getRoute(vueRoute.params.id)
  route.value = res.data
  await check()
  await init()
  if (route.value.points?.length) {
    drawRoute(route.value.points)
    await nextTick()
    drawElevationProfile()
  }
})

// 分享线路
async function shareRoute() {
  const url = window.location.href
  const title = `TrekHub 线路：${route.value.title}`
  // 尝试使用系统原生分享
  if (navigator.share) {
    try {
      await navigator.share({ title, url })
      return
    } catch { /* 用户取消或不支持，回退到复制 */ }
  }
  // 回退：复制链接到剪贴板
  try {
    await navigator.clipboard.writeText(url)
    msg.success('线路链接已复制到剪贴板')
  } catch {
    msg.info(url)
  }
}
</script>

<style scoped>
.route-detail { max-width: 1200px; margin: 0 auto; }

.map-layout {
  display: flex; gap: 16px; margin-top: 16px;
}
.map-col { flex: 1; min-width: 0; }
.stats-col { width: 260px; flex-shrink: 0; }

.map-container {
  height: 420px; border-radius: 10px; overflow: hidden;
  border: 1px solid #e8e8e8;
}

/* 海拔剖面图 */
.elevation-profile {
  margin-top: 12px; background: #fafafa; border-radius: 10px;
  border: 1px solid #e8e8e8; padding: 12px 16px;
}
.profile-title {
  font-size: 14px; font-weight: 600; color: #333; margin-bottom: 8px;
}
.profile-canvas { width: 100%; height: 140px; display: block; }
.profile-axis {
  display: flex; justify-content: space-between;
  font-size: 11px; color: #aaa; margin-top: 4px;
}

/* 统计卡片 */
.stats-card {
  background: #fff; border-radius: 12px; padding: 20px;
  border: 1px solid #e8e8e8; position: sticky; top: 16px;
}
.stats-header { text-align: center; margin-bottom: 16px; }
.stat-value-big {
  text-align: center; font-size: 36px; font-weight: 700; color: #2d8cf0;
}
.stat-unit { font-size: 14px; font-weight: 400; color: #999; margin-left: 2px; }
.stat-label { text-align: center; color: #999; font-size: 13px; margin-top: 2px; }

.stat-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px; }
.stat-item { text-align: center; }
.stat-num { font-size: 20px; font-weight: 600; color: #333; }
.stat-num.up { color: #27ae60; }
.stat-sub { font-size: 12px; color: #999; margin-top: 2px; }

.stat-meta {
  display: flex; flex-direction: column; gap: 6px;
  font-size: 13px; color: #666;
}

/* 安全警告横幅（增强版） */
.safety-banner {
  background: linear-gradient(135deg, #fffbeb, #fef3c7);
  border: 2px solid #f59e0b;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 12px rgba(245, 158, 11, 0.15);
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

@media (max-width: 768px) {
  .map-layout { flex-direction: column; }
  .stats-col { width: 100%; }
}
</style>
