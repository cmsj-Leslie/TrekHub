<template>
  <div>
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px">
      <h2 style="margin:0;font-size:22px">🎯 找活动</h2>
      <n-space>
        <router-link to="/match"><n-button size="small">🎲 随机组队</n-button></router-link>
        <router-link to="/activities/create"><n-button type="primary" size="small">+ 发起活动</n-button></router-link>
      </n-space>
    </div>

    <!-- 我的活动 -->
    <div v-if="userStore.isLoggedIn && myList.length" class="my-activities">
      <h4>📌 我参加的活动</h4>
      <div class="my-list">
        <div v-for="m in myList" :key="m.id" class="my-item"
          @click="$router.push(`/activities/${m.Activity?.id}`)">
          <span class="my-dot" :class="`s-${m.Activity?.status}`" />
          <span class="my-title">{{ m.Activity?.title }}</span>
          <span class="my-role" v-if="m.role === 1">组织者</span>
          <span class="my-route" v-if="m.Activity?.route">📍 {{ m.Activity.route.title }}</span>
        </div>
      </div>
    </div>

    <!-- 筛选栏 -->
    <n-card size="small" style="margin-bottom:20px;border-radius:10px">
      <n-space align="center" wrap>
        <n-input v-model:value="keyword" placeholder="🔍 搜索活动名称" clearable style="width:220px" @keyup.enter="doSearch" />
        <n-divider vertical />
        <n-radio-group v-model:value="statusFilter" size="small" @update:value="doSearch">
          <n-radio-button value="">全部</n-radio-button>
          <n-radio-button value="1">招募中</n-radio-button>
          <n-radio-button value="2">已满员</n-radio-button>
          <n-radio-button value="3">已结束</n-radio-button>
        </n-radio-group>
        <n-button type="primary" size="small" @click="doSearch">搜索</n-button>
      </n-space>
    </n-card>

    <n-spin :show="loading">
      <n-grid :cols="3" :x-gap="16" :y-gap="16" responsive="screen">
        <n-grid-item v-for="a in list" :key="a.id">
          <ActivityCard :activity="a" />
        </n-grid-item>
      </n-grid>
      <n-empty v-if="!loading && !list.length" description="没有找到活动" style="margin-top:40px" />
    </n-spin>

    <n-pagination v-if="total > pageSize" v-model:page="page" :page-count="Math.ceil(total/pageSize)"
      style="margin-top:24px;justify-content:center" @update:page="load" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import {
  NSpace, NInput, NButton, NGrid, NGridItem, NSpin, NEmpty,
  NPagination, NCard, NDivider, NRadioGroup, NRadioButton
} from 'naive-ui'
import { getActivities, myActivities } from '@/api/activity'
import { useUserStore } from '@/stores/user'
import ActivityCard from '@/components/ActivityCard.vue'

const userStore = useUserStore()
const list = ref([])
const total = ref(0)
const page = ref(1)
const pageSize = 9
const keyword = ref('')
const statusFilter = ref('')
const loading = ref(false)
const myList = ref([])

async function load() {
  loading.value = true
  const params = { page: page.value, pageSize, keyword: keyword.value }
  if (statusFilter.value) params.status = statusFilter.value
  const res = await getActivities(params).finally(() => loading.value = false)
  list.value = res.data.list
  total.value = res.data.total
}

async function loadMyActivities() {
  if (!userStore.isLoggedIn) return
  try {
    const res = await myActivities()
    myList.value = res.data || []
  } catch {}
}

function doSearch() { page.value = 1; load() }

onMounted(() => {
  load()
  loadMyActivities()
})
</script>

<style scoped>
.my-activities {
  margin-bottom: 20px;
  background: linear-gradient(135deg, #eef4ff, #f8faff);
  border: 1px solid #d0e3ff;
  border-radius: 12px;
  padding: 14px 18px;
}
.my-activities h4 {
  margin: 0 0 10px;
  font-size: 14px;
  font-weight: 700;
  color: #1e3a5f;
}
.my-list {
  display: flex;
  flex-direction: column;
  gap: 6px;
}
.my-item {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 10px;
  border-radius: 8px;
  cursor: pointer;
  transition: background .2s;
  font-size: 13px;
}
.my-item:hover { background: rgba(45,140,240,.08); }
.my-dot {
  width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0;
}
.my-dot.s-1 { background: #19be6b; }
.my-dot.s-2 { background: #f0a020; }
.my-dot.s-3 { background: #999; }
.my-dot.s-0 { background: #e74c3c; }
.my-title { font-weight: 600; color: #333; }
.my-role {
  font-size: 11px; background: #e3f2fd; color: #1565c0;
  padding: 1px 8px; border-radius: 8px; font-weight: 600;
}
.my-route { color: #999; font-size: 12px; margin-left: auto; }
</style>
