<template>
  <div class="create-page">
    <!-- 顶部 Banner -->
    <div class="page-banner">
      <div class="banner-bg" />
      <div class="banner-content">
        <n-button text style="color:#fff;font-size:14px" @click="$router.back()">← 返回</n-button>
        <h2>🗺️ 创建新线路</h2>
        <p>在地图上绘制你的徒步轨迹，分享给社区</p>
      </div>
    </div>

    <!-- 📋 基本信息 -->
    <div class="section-card">
      <div class="section-header">
        <span class="section-icon">📋</span>
        <h3>基本信息</h3>
      </div>
      <div class="section-body">
        <n-form ref="formRef" :model="form" :rules="rules" label-placement="top">
          <n-form-item label="线路名称" path="title">
            <n-input v-model:value="form.title" placeholder="给线路起一个好记的名字" size="large">
              <template #prefix><span style="opacity:.5">🏷️</span></template>
            </n-input>
          </n-form-item>

          <n-grid :cols="3" :x-gap="16" responsive="screen" :collapsed-rows="1">
            <n-grid-item>
              <n-form-item label="难度等级" path="difficulty">
                <n-select v-model:value="form.difficulty" :options="difficultyOptions" />
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="所在地区" path="region">
                <n-input v-model:value="form.region" placeholder="如：四川成都"
                  @blur="gotoPlace(form.region)" @keyup.enter="gotoPlace(form.region)">
                  <template #prefix><span style="opacity:.5">📍</span></template>
                </n-input>
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="线路距离 (km)" path="distance_km">
                <n-input-number v-model:value="form.distance_km" :min="0" :precision="1" style="width:100%" placeholder="0.0" />
              </n-form-item>
            </n-grid-item>
          </n-grid>

          <n-grid :cols="3" :x-gap="16" responsive="screen">
            <n-grid-item>
              <n-form-item label="累计爬升 (m)">
                <n-input-number v-model:value="form.elevation_m" :min="0" style="width:100%" placeholder="0" />
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="预计时长 (h)">
                <n-input-number v-model:value="form.duration_h" :min="0" :precision="1" style="width:100%" placeholder="0.0" />
              </n-form-item>
            </n-grid-item>
            <n-grid-item>
              <n-form-item label="封面图片">
                <n-upload :max="1" list-type="image-card" accept="image/*" @change="onCoverChange">
                  <n-button size="small" quaternary>📷 选择图片</n-button>
                </n-upload>
              </n-form-item>
            </n-grid-item>
          </n-grid>

          <n-form-item label="线路描述">
            <n-input v-model:value="form.description" type="textarea" :rows="4"
              placeholder="描述线路特点、途经风景、难点路段、最佳季节..."
              :maxlength="2000" show-count />
          </n-form-item>
        </n-form>
      </div>
    </div>

    <!-- ⚠️ 安全与装备 -->
    <div class="section-card warning-section">
      <div class="section-header">
        <span class="section-icon warn">⚠️</span>
        <h3>安全与装备</h3>
        <span class="section-hint">帮助队友做好充分准备</span>
      </div>
      <div class="section-body">
        <n-form label-placement="top">
          <n-form-item label="安全提示 / 注意事项">
            <n-input v-model:value="form.safety_note" type="textarea" :rows="3"
              placeholder="如：部分路段陡峭需要手脚并用，雨天路滑请谨慎通行，沿途无补给点需自带饮水..."
              :maxlength="1000" show-count />
          </n-form-item>
          <n-form-item label="建议携带装备">
            <n-input v-model:value="form.gear_list" placeholder="如：登山杖、防水外套、头灯、急救包、充足饮水">
              <template #prefix><span style="opacity:.5">🎒</span></template>
            </n-input>
          </n-form-item>
        </n-form>
      </div>
    </div>

    <!-- 🗺️ 轨迹绘制 -->
    <div class="section-card map-section">
      <div class="section-header">
        <span class="section-icon map">🗺️</span>
        <h3>绘制轨迹</h3>
        <span class="section-hint">在地图上点击绘制线路，或导入 GPX 文件</span>
      </div>
      <div class="section-body">
        <!-- 工具栏 -->
        <div class="map-toolbar">
          <div class="toolbar-left">
            <n-button :type="isDrawing ? 'warning' : 'primary'" size="small" round @click="isDrawing ? stopDraw() : startDraw()">
              {{ isDrawing ? '⏸️ 停止绘制' : '✏️ 开始绘制' }}
            </n-button>
            <n-button size="small" round quaternary @click="undoLast" :disabled="!drawPoints.length">
              ↩️ 撤销
            </n-button>
            <n-button size="small" round quaternary @click="doClear" :disabled="!drawPoints.length">
              🗑️ 清除
            </n-button>
            <n-upload :max="1" accept=".gpx" :show-file-list="false" @change="onGpxChange">
              <n-button size="small" round quaternary>📂 导入GPX</n-button>
            </n-upload>
          </div>
          <div class="toolbar-right">
            <div :class="['point-counter', { active: drawPoints.length > 0 }]">
              <span class="counter-dot" />
              <span>{{ drawPoints.length }} 个坐标点</span>
            </div>
          </div>
        </div>

        <!-- 绘制提示 -->
        <div v-if="isDrawing" class="draw-hint">
          <span class="hint-pulse" />
          点击地图添加坐标点，按顺序绘制徒步轨迹
        </div>

        <!-- 地图容器 -->
        <div id="create-map" class="map-container" />

        <!-- 轨迹预览统计 -->
        <div v-if="drawPoints.length >= 2" class="track-stats">
          <div class="track-stat">
            <span class="track-stat-label">起点</span>
            <span class="track-stat-value">{{ drawPoints[0].lng.toFixed(4) }}, {{ drawPoints[0].lat.toFixed(4) }}</span>
          </div>
          <div class="track-stat">
            <span class="track-stat-label">终点</span>
            <span class="track-stat-value">{{ drawPoints[drawPoints.length - 1].lng.toFixed(4) }}, {{ drawPoints[drawPoints.length - 1].lat.toFixed(4) }}</span>
          </div>
          <div class="track-stat">
            <span class="track-stat-label">坐标数</span>
            <span class="track-stat-value highlight">{{ drawPoints.length }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部按钮 -->
    <div class="submit-bar">
      <n-button size="large" round @click="$router.back()">取消</n-button>
      <n-button type="primary" size="large" round :loading="submitting" @click="submit" style="min-width:200px">
        🚀 发布线路
      </n-button>
    </div>
  </div>
</template>

<script setup>
/**
 * 创建线路页面
 * 功能：填写线路基本信息 + 安全提示 + 地图绘制轨迹 → 发布线路
 * 支持：手动打点绘制、GPX文件导入、撤销/清除操作
 */
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import {
  NForm, NFormItem, NInput, NInputNumber, NSelect,
  NGrid, NGridItem, NButton, NSpace, NUpload, useMessage
} from 'naive-ui'
import { createRoute, uploadGpx } from '@/api/route'
import { useMap } from '@/composables/useMap'

const router = useRouter()
const msg = useMessage()
const formRef = ref(null)
const isDrawing = ref(false)
const { drawPoints, init, enableDraw, disableDraw, clearDraw, drawRoute, undoLastPoint, gotoPlace } = useMap('create-map')

// 表单数据（含新增安全/装备字段）
const form = ref({
  title: '', difficulty: 2, region: '', distance_km: 0,
  elevation_m: 0, duration_h: 0, description: '',
  safety_note: '', gear_list: ''
})
const coverFile = ref(null)
const submitting = ref(false)

// 难度选项（带颜色标识）
const difficultyOptions = [
  { label: '🟢 简单 — 平坦步道', value: 1 },
  { label: '🔵 中等 — 有一定坡度', value: 2 },
  { label: '🟠 困难 — 陡峭路段多', value: 3 },
  { label: '🔴 专家 — 需要丰富经验', value: 4 }
]

// 表单校验规则
const rules = {
  title: { required: true, message: '请输入线路名称', trigger: 'blur' },
  difficulty: { required: true, type: 'number', message: '请选择难度等级', trigger: 'change' },
  region: { required: true, message: '请输入所在地区', trigger: 'blur' },
  distance_km: { required: true, type: 'number', min: 0.1, message: '请输入线路距离', trigger: 'blur' }
}

// 封面图选择
function onCoverChange({ fileList }) { coverFile.value = fileList[0]?.file || null }

// GPX 文件导入
async function onGpxChange({ fileList }) {
  const file = fileList[0]?.file
  if (!file) return
  const fd = new FormData()
  fd.append('gpx', file)
  const res = await uploadGpx(fd)
  drawPoints.value = res.data.points
  drawRoute(res.data.points)
  msg.success(`已解析 ${res.data.points.length} 个坐标点`)
}

// 开始/停止绘制
function startDraw() { isDrawing.value = true; enableDraw() }
function stopDraw() { isDrawing.value = false; disableDraw() }

// 撤销最后一个坐标点（调用 useMap 的方法，会同步移除地图标记）
function undoLast() { undoLastPoint() }

// 清除所有坐标（useMap 的 clearDraw 会移除所有标记+停止绘制）
function doClear() { clearDraw(); isDrawing.value = false }

// 提交发布
async function submit() {
  try { await formRef.value?.validate() } catch { return }
  if (!drawPoints.value.length) return msg.warning('请在地图上绘制线路轨迹')
  submitting.value = true
  try {
    const fd = new FormData()
    Object.entries(form.value).forEach(([k, v]) => fd.append(k, v))
    if (coverFile.value) fd.append('cover_image', coverFile.value)
    fd.append('start_lng', drawPoints.value[0].lng)
    fd.append('start_lat', drawPoints.value[0].lat)
    fd.append('points', JSON.stringify(drawPoints.value))
    const res = await createRoute(fd)
    msg.success('线路发布成功 🎉')
    router.push(`/routes/${res.data.id}`)
  } catch (e) {
    msg.error(e?.msg || '发布失败')
  } finally { submitting.value = false }
}

onMounted(init)
</script>

<style scoped>
.create-page {
  max-width: 900px;
  margin: 0 auto;
  padding-bottom: 40px;
}

/* === Banner === */
.page-banner {
  position: relative;
  border-radius: 16px;
  overflow: hidden;
  margin-bottom: 20px;
  padding: 32px 28px 28px;
  color: #fff;
}
.banner-bg {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, #1e3a5f 0%, #2d8cf0 40%, #0ea5e9 100%);
  z-index: 0;
}
.banner-bg::after {
  content: '';
  position: absolute;
  inset: 0;
  background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='80' height='80' viewBox='0 0 80 80'%3E%3Cg fill='%23ffffff' fill-opacity='0.05'%3E%3Cpath d='M0 60 L20 30 L40 50 L60 20 L80 45 L80 80 L0 80Z'/%3E%3C/g%3E%3C/svg%3E") repeat-x bottom;
  background-size: 120px 80px;
}
.banner-content {
  position: relative;
  z-index: 1;
}
.banner-content h2 {
  margin: 10px 0 6px;
  font-size: 26px;
  font-weight: 800;
  letter-spacing: .5px;
}
.banner-content p {
  margin: 0;
  font-size: 14px;
  opacity: .85;
}

/* === Section Card === */
.section-card {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 14px;
  margin-bottom: 16px;
  overflow: hidden;
  transition: box-shadow .3s;
}
.section-card:hover {
  box-shadow: 0 4px 20px rgba(0,0,0,.06);
}
.section-header {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 16px 22px;
  background: #fafbfc;
  border-bottom: 1px solid #f0f0f0;
}
.section-header h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 700;
  color: #1a1a2e;
}
.section-icon {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  background: linear-gradient(135deg, #e8f4ff, #dbeafe);
  flex-shrink: 0;
}
.section-icon.warn {
  background: linear-gradient(135deg, #fef3c7, #fde68a);
}
.section-icon.map {
  background: linear-gradient(135deg, #d1fae5, #a7f3d0);
}
.section-hint {
  font-size: 12px;
  color: #aaa;
  margin-left: auto;
}
.section-body {
  padding: 22px;
}

/* === Warning Section === */
.warning-section {
  border-left: 4px solid #f59e0b;
}

/* === Map Section === */
.map-toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
  flex-wrap: wrap;
  gap: 8px;
}
.toolbar-left {
  display: flex;
  align-items: center;
  gap: 6px;
  flex-wrap: wrap;
}
.toolbar-right {
  display: flex;
  align-items: center;
}
.point-counter {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;
  color: #999;
  padding: 4px 12px;
  border-radius: 16px;
  background: #f5f5f5;
  transition: all .3s;
}
.point-counter.active {
  background: #e8f4ff;
  color: #2d8cf0;
  font-weight: 600;
}
.counter-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #ccc;
}
.point-counter.active .counter-dot {
  background: #2d8cf0;
  animation: dot-pulse 1.5s ease infinite;
}

/* 绘制提示 */
.draw-hint {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 16px;
  background: linear-gradient(135deg, #f0fdf4, #ecfdf5);
  border: 1px solid #bbf7d0;
  border-radius: 8px;
  margin-bottom: 12px;
  font-size: 13px;
  color: #16a34a;
  font-weight: 500;
  animation: hint-in .3s ease;
}
.hint-pulse {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #22c55e;
  animation: dot-pulse 1.2s ease infinite;
}

/* 地图 */
.map-container {
  height: 450px;
  border-radius: 12px;
  border: 2px solid #e8e8e8;
  overflow: hidden;
  transition: border-color .3s;
}
.map-section:hover .map-container {
  border-color: #c8ddf5;
}

/* 轨迹统计 */
.track-stats {
  display: flex;
  gap: 16px;
  margin-top: 12px;
  padding: 12px 16px;
  background: #fafbfc;
  border-radius: 10px;
  border: 1px solid #f0f0f0;
}
.track-stat {
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.track-stat-label {
  font-size: 11px;
  color: #aaa;
  font-weight: 500;
}
.track-stat-value {
  font-size: 13px;
  color: #555;
  font-family: 'Courier New', monospace;
}
.track-stat-value.highlight {
  color: #2d8cf0;
  font-weight: 700;
  font-size: 16px;
}

/* === Submit Bar === */
.submit-bar {
  display: flex;
  justify-content: center;
  gap: 16px;
  margin-top: 28px;
  padding: 20px 0;
}

/* === Animations === */
@keyframes dot-pulse {
  0%, 100% { opacity: .4; transform: scale(.8); }
  50% { opacity: 1; transform: scale(1.3); }
}
@keyframes hint-in {
  from { opacity: 0; transform: translateY(-8px); }
  to { opacity: 1; transform: translateY(0); }
}

/* === Responsive === */
@media (max-width: 768px) {
  .page-banner { padding: 24px 20px 20px; }
  .banner-content h2 { font-size: 22px; }
  .section-body { padding: 16px; }
  .map-container { height: 320px; }
  .track-stats { flex-direction: column; gap: 8px; }
  .submit-bar { flex-direction: column; align-items: stretch; }
}
</style>
