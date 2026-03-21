<template>
  <div class="match-page">
    <!-- 顶部 Banner -->
    <div class="match-banner">
      <div class="banner-content">
        <h2>🎲 随机组队</h2>
        <p>加入即时匹配，快速找到志同道合的队友</p>
      </div>
      <div class="banner-stats">
        <div class="pool-stat">
          <span class="pool-num">{{ poolCount }}</span>
          <span class="pool-label">人等待匹配</span>
        </div>
      </div>
    </div>

    <div class="match-body">
      <!-- 左：匹配状态 + 说明 -->
      <div class="match-left">
        <!-- 状态卡片 -->
        <div :class="['status-card', inPool ? 'active' : 'idle']">
          <div class="status-anim" v-if="inPool">
            <span class="pulse-dot" /><span class="pulse-dot d2" /><span class="pulse-dot d3" />
          </div>
          <div v-else class="status-idle-icon">🎯</div>
          <div class="status-text">
            <h3>{{ inPool ? '正在匹配中...' : '未加入组队池' }}</h3>
            <p>{{ inPool ? '系统正在为你即时匹配队友，成功后将自动通知' : '设置偏好后加入匹配池，系统将即时为你配对' }}</p>
          </div>
        </div>

        <!-- 匹配流程说明 -->
        <div class="flow-card">
          <h4>🔄 匹配流程</h4>
          <div class="flow-steps">
            <div class="flow-step">
              <div class="step-num">1</div>
              <div class="step-info">
                <strong>设置偏好</strong>
                <span>选择意向线路、日期和等级范围</span>
              </div>
            </div>
            <div class="flow-step">
              <div class="step-num">2</div>
              <div class="step-info">
                <strong>加入队列</strong>
                <span>进入匹配池等待系统自动配对</span>
              </div>
            </div>
            <div class="flow-step">
              <div class="step-num">3</div>
              <div class="step-info">
                <strong>自动组队</strong>
                <span>匹配成功自动创建活动和群聊</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 右：偏好设置表单 -->
      <div class="match-right">
        <div class="form-card">
          <h4>⚙️ 匹配偏好设置</h4>
          <n-form :model="form" label-placement="top">
            <n-form-item label="🗺️ 意向线路">
              <n-select v-model:value="form.route_id" :options="routeOptions" placeholder="不限（可选）" clearable filterable />
            </n-form-item>
            <n-form-item label="📅 出行日期">
              <n-date-picker v-model:value="form.prefer_date" type="date" style="width:100%" placeholder="不限（可选）" clearable />
            </n-form-item>
            <n-grid :cols="2" :x-gap="12">
              <n-grid-item>
                <n-form-item label="最低等级">
                  <n-slider v-model:value="form.min_level" :min="1" :max="5" :marks="{1:'Lv1',3:'Lv3',5:'Lv5'}" />
                </n-form-item>
              </n-grid-item>
              <n-grid-item>
                <n-form-item label="最高等级">
                  <n-slider v-model:value="form.max_level" :min="1" :max="5" :marks="{1:'Lv1',3:'Lv3',5:'Lv5'}" />
                </n-form-item>
              </n-grid-item>
            </n-grid>
            <n-form-item label="🏷️ 技能偏好">
              <n-select v-model:value="form.skill_tags" :options="skillOptions" multiple placeholder="选择技能标签（可选）" />
            </n-form-item>
            <div style="text-align:center;padding-top:8px">
              <n-button v-if="!inPool" type="primary" size="large" round :loading="loading" @click="joinPool" style="min-width:200px">
                🚀 加入组队池
              </n-button>
              <n-button v-else size="large" round type="error" :loading="loading" @click="leavePool" style="min-width:200px">
                ⏹️ 退出组队池
              </n-button>
            </div>
          </n-form>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  NForm, NFormItem, NSelect, NDatePicker,
  NGrid, NGridItem, NSlider, NButton, useMessage
} from 'naive-ui'
import { joinMatch, leaveMatch, matchStatus } from '@/api/social'
import { getRoutes } from '@/api/route'
import { getAllSkillTags } from '@/api/user'

const msg = useMessage()
const inPool = ref(false)
const loading = ref(false)
const poolCount = ref(0)
const routeOptions = ref([])
const skillOptions = ref([])

const form = ref({ route_id: null, prefer_date: null, min_level: 1, max_level: 5, skill_tags: [] })

onMounted(async () => {
  const [statusRes, routeRes, skillRes] = await Promise.all([matchStatus(), getRoutes({ pageSize: 100 }), getAllSkillTags()])
  inPool.value = statusRes.data.inPool
  poolCount.value = statusRes.data.poolCount || 0
  routeOptions.value = routeRes.data.list.map(r => ({ label: r.title, value: r.id }))
  skillOptions.value = skillRes.data.map(t => ({ label: t.name, value: t.name }))
})

async function joinPool() {
  loading.value = true
  try {
    await joinMatch({ ...form.value, prefer_date: form.value.prefer_date ? new Date(form.value.prefer_date).toISOString().slice(0, 10) : null })
    inPool.value = true
    poolCount.value++
    msg.success('已加入组队池，等待匹配 🎯')
  } finally { loading.value = false }
}

async function leavePool() {
  loading.value = true
  try {
    await leaveMatch()
    inPool.value = false
    poolCount.value = Math.max(0, poolCount.value - 1)
    msg.info('已退出组队池')
  } finally { loading.value = false }
}
</script>

<style scoped>
.match-page { max-width: 960px; margin: 0 auto; }

/* Banner */
.match-banner {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: #fff;
  padding: 32px 28px;
  border-radius: 14px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.banner-content h2 { margin: 0; font-size: 24px; font-weight: 800; }
.banner-content p { margin: 6px 0 0; opacity: .85; font-size: 14px; }
.pool-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: rgba(255,255,255,.15);
  border-radius: 12px;
  padding: 12px 20px;
  backdrop-filter: blur(4px);
}
.pool-num { font-size: 28px; font-weight: 800; line-height: 1.1; }
.pool-label { font-size: 11px; opacity: .8; margin-top: 2px; }

/* Body */
.match-body {
  display: flex;
  gap: 16px;
  margin-top: 16px;
}
.match-left { flex: 1; display: flex; flex-direction: column; gap: 16px; }
.match-right { width: 400px; flex-shrink: 0; }

/* Status Card */
.status-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px;
  border-radius: 12px;
  border: 1px solid #eee;
  background: #fff;
}
.status-card.active { border-color: #19be6b; background: #f0fdf4; }
.status-card.idle { border-color: #e0e0e0; }

.status-anim { display: flex; gap: 6px; align-items: center; }
.pulse-dot {
  width: 10px; height: 10px; border-radius: 50%;
  background: #19be6b;
  animation: pulse 1.4s ease infinite;
}
.pulse-dot.d2 { animation-delay: .2s; }
.pulse-dot.d3 { animation-delay: .4s; }
@keyframes pulse { 0%,100% { opacity: .3; transform: scale(.8); } 50% { opacity: 1; transform: scale(1.2); } }

.status-idle-icon { font-size: 28px; }
.status-text h3 { margin: 0; font-size: 15px; font-weight: 600; color: #333; }
.status-text p { margin: 4px 0 0; font-size: 13px; color: #999; }

/* Flow Card */
.flow-card {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 20px;
}
.flow-card h4 { margin: 0 0 16px; font-size: 14px; font-weight: 600; color: #333; }
.flow-steps { display: flex; flex-direction: column; gap: 14px; }
.flow-step {
  display: flex; align-items: flex-start; gap: 12px;
}
.step-num {
  width: 28px; height: 28px; border-radius: 50%;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: #fff; font-size: 13px; font-weight: 700;
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}
.step-info { display: flex; flex-direction: column; }
.step-info strong { font-size: 13px; color: #333; }
.step-info span { font-size: 12px; color: #999; margin-top: 2px; }

/* Form Card */
.form-card {
  background: #fff;
  border: 1px solid #eee;
  border-radius: 12px;
  padding: 20px;
}
.form-card h4 { margin: 0 0 16px; font-size: 14px; font-weight: 600; color: #333; }
</style>
