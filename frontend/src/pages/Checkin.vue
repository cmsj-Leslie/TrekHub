<template>
  <div class="checkin-page">
    <!-- 页面头部 -->
    <div class="page-banner">
      <div>
        <h2 style="margin:0;font-size:24px">📍 打卡记录</h2>
        <p style="margin:6px 0 0;opacity:.85;font-size:14px">记录每一次出发，留下属于你的足迹</p>
      </div>
      <n-button type="primary" @click="showCreate = true">+ 发布打卡</n-button>
    </div>

    <!-- 打卡日历 -->
    <n-card style="margin-bottom:20px;border-radius:12px">
      <template #header>
        <n-space align="center" :size="12">
          <n-button text @click="changeMonth(-1)" style="font-size:18px">‹</n-button>
          <span style="font-size:16px;font-weight:600;min-width:110px;text-align:center">
            {{ currentYear }}年{{ currentMonth }}月
          </span>
          <n-button text @click="changeMonth(1)" style="font-size:18px">›</n-button>
        </n-space>
      </template>
      <template #header-extra>
        <span class="calendar-summary">本月 {{ monthCheckinCount }} 次打卡</span>
      </template>
      <div class="calendar-grid">
        <div v-for="d in ['日','一','二','三','四','五','六']" :key="d" class="calendar-header">{{ d }}</div>
        <div v-for="n in firstDayOfMonth" :key="'empty'+n" class="calendar-cell empty" />
        <div v-for="day in daysInMonth" :key="day"
          :class="['calendar-cell', { active: calendarData[day], today: isToday(day) }]"
          @click="calendarData[day] && scrollToDay(day)">
          <span>{{ day }}</span>
          <div v-if="calendarData[day]" class="dot" />
        </div>
      </div>
    </n-card>

    <!-- 打卡列表 -->
    <n-spin :show="loading">
      <div class="checkin-list">
        <div v-for="c in list" :key="c.id" class="checkin-item">
          <div class="item-left">
            <n-avatar v-if="c.user?.avatar" :src="c.user?.avatar" :size="36" round />
            <n-avatar v-else :size="36" round>{{ c.user?.nickname?.[0] }}</n-avatar>
            <div class="timeline-line" />
          </div>
          <div class="item-content">
            <div class="item-header">
              <span class="item-nickname">{{ c.user?.nickname }}</span>
              <span class="item-time">{{ dayjs(c.checkin_at).format('MM-DD HH:mm') }}</span>
            </div>
            <div v-if="c.title" class="item-title">{{ c.title }}</div>
            <div v-if="c.content" class="item-text">{{ c.content }}</div>
            <div v-if="c.images?.length" class="item-images">
              <n-image-group>
                <n-space :size="6">
                  <n-image v-for="img in c.images.slice(0,4)" :key="img" :src="img"
                    width="80" height="80" object-fit="cover"
                    style="border-radius:8px;border:1px solid #f0f0f0;cursor:pointer" />
                </n-space>
              </n-image-group>
            </div>
            <div class="item-meta">
              <span v-if="c.distance_km" class="meta-tag blue">📏 {{ c.distance_km }} km</span>
              <span v-if="c.route_id" class="meta-tag green">🗺️ 关联线路</span>
            </div>
          </div>
        </div>
      </div>
      <n-empty v-if="!loading && !list.length" description="还没有打卡记录，快去记录第一次徒步吧！" style="margin-top:40px" />
    </n-spin>

    <n-pagination v-if="total > pageSize" v-model:page="page" :page-count="Math.ceil(total / pageSize)"
      style="margin-top:20px;justify-content:center" @update:page="loadCheckins" />

    <!-- 发布打卡弹窗 -->
    <n-modal v-model:show="showCreate" preset="card" title="📍 发布打卡" style="width:540px;border-radius:12px">
      <n-form :model="form" label-placement="top">
        <n-form-item label="标题（可选）">
          <n-input v-model:value="form.title" placeholder="今天打卡的主题" />
        </n-form-item>
        <n-form-item label="打卡内容">
          <n-input v-model:value="form.content" type="textarea" :rows="3" placeholder="记录今天的徒步心得..." />
        </n-form-item>
        <n-grid :cols="2" :x-gap="12">
          <n-grid-item>
            <n-form-item label="本次里程(km)">
              <n-input-number v-model:value="form.distance_km" :min="0" :precision="1" style="width:100%" />
            </n-form-item>
          </n-grid-item>
          <n-grid-item>
            <n-form-item label="关联线路">
              <n-select v-model:value="form.route_id" :options="routeOptions" placeholder="可选" clearable filterable />
            </n-form-item>
          </n-grid-item>
        </n-grid>
        <n-form-item label="打卡图片（最多9张）">
          <n-upload multiple :max="9" list-type="image-card" accept="image/*" @change="onImagesChange">
            点击上传
          </n-upload>
        </n-form-item>
        <n-divider style="margin:8px 0 16px" />
        <n-space justify="end">
          <n-button @click="showCreate = false">取消</n-button>
          <n-button type="primary" :loading="submitting" @click="submitCheckin">发布打卡</n-button>
        </n-space>
      </n-form>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import {
  NCard, NSpace, NButton, NSpin, NAvatar, NModal, NEmpty, NPagination,
  NForm, NFormItem, NInput, NInputNumber, NUpload, NSelect, NGrid, NGridItem, NDivider,
  NImage, NImageGroup, useMessage
} from 'naive-ui'
import dayjs from 'dayjs'
import { createCheckin, getCheckins, getCheckinCalendar } from '@/api/social'
import { getRoutes } from '@/api/route'

const msg = useMessage()
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 10
const loading = ref(false)
const showCreate = ref(false)
const submitting = ref(false)
const calendarData = ref({})
const imageFiles = ref([])
const routeOptions = ref([])

const today = new Date()
const currentYear  = ref(today.getFullYear())
const currentMonth = ref(today.getMonth() + 1)

const firstDayOfMonth = computed(() => new Date(currentYear.value, currentMonth.value - 1, 1).getDay())
const daysInMonth     = computed(() => new Date(currentYear.value, currentMonth.value, 0).getDate())
const monthCheckinCount = computed(() => Object.values(calendarData.value).reduce((s, arr) => s + arr.length, 0))

const form = ref({ title: '', content: '', distance_km: 0, route_id: null })

function isToday(day) {
  return currentYear.value === today.getFullYear() && currentMonth.value === today.getMonth() + 1 && day === today.getDate()
}

function changeMonth(delta) {
  let m = currentMonth.value + delta
  if (m < 1) { m = 12; currentYear.value-- }
  if (m > 12) { m = 1; currentYear.value++ }
  currentMonth.value = m
  loadCalendar()
}

function scrollToDay(day) {
  // future: scroll to checkin of that day
}

function onImagesChange({ fileList }) { imageFiles.value = fileList.map(f => f.file).filter(Boolean) }

async function loadCalendar() {
  const res = await getCheckinCalendar({ year: currentYear.value, month: currentMonth.value })
  calendarData.value = res.data
}

async function submitCheckin() {
  submitting.value = true
  try {
    const fd = new FormData()
    Object.entries(form.value).forEach(([k, v]) => v && fd.append(k, v))
    imageFiles.value.forEach(f => fd.append('images', f))
    await createCheckin(fd)
    msg.success('打卡成功！🎉')
    showCreate.value = false
    form.value = { title: '', content: '', distance_km: 0, route_id: null }
    imageFiles.value = []
    loadCheckins()
    loadCalendar()
  } finally { submitting.value = false }
}

async function loadCheckins() {
  loading.value = true
  const res = await getCheckins({ page: page.value, pageSize }).finally(() => loading.value = false)
  list.value = res.data.list
  total.value = res.data.total
}

onMounted(async () => {
  loadCheckins()
  loadCalendar()
  const routeRes = await getRoutes({ pageSize: 100 })
  routeOptions.value = routeRes.data.list.map(r => ({ label: r.title, value: r.id }))
})
</script>

<style scoped>
.checkin-page { max-width: 800px; margin: 0 auto; }

.page-banner {
  background: linear-gradient(135deg, #059669, #0ea5e9);
  color: #fff;
  padding: 28px 24px;
  border-radius: 12px;
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.page-banner .n-button { color: #fff; border-color: rgba(255,255,255,.6); }

.calendar-summary { font-size: 13px; color: #999; }
.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
  text-align: center;
}
.calendar-header { color: #999; font-size: 12px; padding: 6px; }
.calendar-cell {
  padding: 8px 2px;
  border-radius: 8px;
  font-size: 13px;
  cursor: default;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 3px;
  transition: background .2s;
}
.calendar-cell.active {
  background: #e8f4ff;
  color: #2d8cf0;
  font-weight: 700;
  cursor: pointer;
}
.calendar-cell.active:hover { background: #d0e8ff; }
.calendar-cell.today {
  border: 2px solid #2d8cf0;
}
.dot { width: 5px; height: 5px; background: #2d8cf0; border-radius: 50%; }

/* 打卡列表 */
.checkin-list { display: flex; flex-direction: column; gap: 0; }
.checkin-item {
  display: flex;
  gap: 14px;
  padding-bottom: 20px;
}
.item-left {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex-shrink: 0;
  width: 36px;
}
.timeline-line {
  width: 2px;
  flex: 1;
  background: #e8e8e8;
  margin-top: 8px;
}
.item-content {
  flex: 1;
  min-width: 0;
  background: #fff;
  border: 1px solid #eee;
  border-radius: 10px;
  padding: 14px 16px;
  transition: box-shadow .3s;
}
.item-content:hover { box-shadow: 0 4px 16px rgba(0,0,0,.06); }
.item-header { display: flex; justify-content: space-between; align-items: center; }
.item-nickname { font-weight: 600; font-size: 14px; color: #333; }
.item-time { font-size: 12px; color: #bbb; }
.item-title { font-weight: 600; font-size: 15px; color: #1a1a2e; margin-top: 6px; }
.item-text { color: #666; font-size: 14px; line-height: 1.7; margin-top: 4px; }
.item-images {
  display: flex;
  gap: 6px;
  margin-top: 10px;
  flex-wrap: wrap;
}
.thumb {
  width: 80px;
  height: 80px;
  object-fit: cover;
  border-radius: 8px;
  border: 1px solid #f0f0f0;
}
.item-meta { display: flex; gap: 8px; margin-top: 10px; }
.meta-tag {
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 4px;
}
.meta-tag.blue { background: #e8f4ff; color: #2d8cf0; }
.meta-tag.green { background: #e8fff0; color: #19be6b; }
</style>
