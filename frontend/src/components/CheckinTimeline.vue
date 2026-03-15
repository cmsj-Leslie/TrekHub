<template>
  <div>
    <n-spin :show="loading">
      <div v-if="list.length" class="timeline-list">
        <div v-for="c in list" :key="c.id" class="tl-item">
          <div class="tl-dot" />
          <div class="tl-card">
            <div class="tl-header">
              <span class="tl-title">{{ c.title || '打卡' }}</span>
              <span class="tl-time">{{ dayjs(c.checkin_at).format('YYYY-MM-DD HH:mm') }}</span>
            </div>
            <div v-if="c.content" class="tl-text">{{ c.content }}</div>
            <div v-if="c.images?.length" class="tl-images">
              <img v-for="img in c.images.slice(0,4)" :key="img" :src="img" class="tl-thumb" />
            </div>
            <div v-if="c.distance_km" class="tl-distance">📏 {{ c.distance_km }} km</div>
          </div>
        </div>
      </div>
      <n-empty v-else-if="!loading" description="暂无打卡记录" style="margin-top:20px" />
    </n-spin>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { NSpin, NEmpty } from 'naive-ui'
import dayjs from 'dayjs'
import { getCheckins } from '@/api/social'

const props = defineProps({ userId: { type: Number, required: true } })
const list = ref([])
const loading = ref(true)

onMounted(async () => {
  try {
    const res = await getCheckins({ user_id: props.userId, pageSize: 20 })
    list.value = res.data.list
  } finally { loading.value = false }
})
</script>

<style scoped>
.timeline-list {
  position: relative;
  padding-left: 20px;
  margin-top: 16px;
}
.timeline-list::before {
  content: '';
  position: absolute;
  left: 6px;
  top: 0;
  bottom: 0;
  width: 2px;
  background: #e8e8e8;
}
.tl-item {
  position: relative;
  margin-bottom: 16px;
}
.tl-dot {
  position: absolute;
  left: -20px;
  top: 16px;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  background: #fff;
  border: 3px solid #19be6b;
  z-index: 1;
}
.tl-card {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 10px;
  padding: 14px 16px;
  transition: box-shadow .3s;
}
.tl-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,.06); }
.tl-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.tl-title { font-weight: 600; font-size: 14px; color: #333; }
.tl-time { font-size: 12px; color: #bbb; }
.tl-text { color: #666; font-size: 14px; margin-top: 6px; line-height: 1.6; }
.tl-images { display: flex; gap: 6px; margin-top: 10px; flex-wrap: wrap; }
.tl-thumb {
  width: 64px;
  height: 64px;
  object-fit: cover;
  border-radius: 6px;
  border: 1px solid #f0f0f0;
}
.tl-distance {
  margin-top: 8px;
  font-size: 12px;
  color: #2d8cf0;
  background: #e8f4ff;
  display: inline-block;
  padding: 2px 8px;
  border-radius: 4px;
}
</style>
