<template>
  <div class="route-card" @click="router.push(`/routes/${route.id}`)">
    <div class="card-cover">
      <img :src="route.cover_image || '/default-route.jpg'" alt="" />
      <div class="cover-overlay">
        <n-tag :type="difficultyType(route.difficulty)" size="small" class="diff-tag">
          {{ difficultyLabel(route.difficulty) }}
        </n-tag>
      </div>
      <div class="like-badge">❤️ {{ route.like_count || 0 }}</div>
    </div>
    <div class="card-body">
      <div class="card-title">{{ route.title }}</div>
      <div class="card-meta">
        <span>📍 {{ route.region || '未知' }}</span>
      </div>
      <div class="card-stats">
        <span>📏 {{ route.distance_km }}km</span>
        <span>⛰ {{ route.elevation_m }}m</span>
      </div>
      <div class="card-author" v-if="route.creator">
        <n-avatar :src="route.creator.avatar" size="tiny" round />
        <span>{{ route.creator.nickname }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { NTag, NAvatar } from 'naive-ui'
import { useRouter } from 'vue-router'

defineProps({ route: { type: Object, required: true } })
const router = useRouter()

const difficultyLabel = (d) => ['', '简单', '中等', '困难', '专家', '极限'][d] || '中等'
const difficultyType  = (d) => ['', 'success', 'info', 'warning', 'error', 'error'][d] || 'info'
</script>

<style scoped>
.route-card {
  cursor: pointer;
  border-radius: 12px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #eee;
  transition: all .3s ease;
}
.route-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0,0,0,.1);
  border-color: #d0e3ff;
}
.card-cover {
  position: relative;
  overflow: hidden;
}
.card-cover img {
  width: 100%;
  height: 170px;
  object-fit: cover;
  transition: transform .4s ease;
}
.route-card:hover .card-cover img {
  transform: scale(1.05);
}
.cover-overlay {
  position: absolute;
  top: 8px;
  left: 8px;
}
.diff-tag {
  backdrop-filter: blur(4px);
}
.like-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(0,0,0,.45);
  color: #fff;
  font-size: 12px;
  padding: 2px 8px;
  border-radius: 12px;
  backdrop-filter: blur(4px);
}
.card-body {
  padding: 12px 14px 14px;
}
.card-title {
  font-weight: 600;
  font-size: 15px;
  line-height: 1.4;
  color: #222;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-bottom: 6px;
}
.card-meta {
  font-size: 12px;
  color: #888;
  margin-bottom: 6px;
}
.card-stats {
  display: flex;
  gap: 12px;
  font-size: 13px;
  color: #555;
  margin-bottom: 8px;
}
.card-author {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #999;
  padding-top: 8px;
  border-top: 1px solid #f0f0f0;
}
</style>
