<template>
  <div>
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px">
      <h2 style="margin:0;font-size:22px">🗺️ 探索线路</h2>
      <router-link to="/routes/create">
        <n-button type="primary" size="small">+ 发布线路</n-button>
      </router-link>
    </div>

    <!-- 筛选栏 -->
    <n-card size="small" style="margin-bottom:20px;border-radius:10px">
      <n-space align="center" wrap>
        <n-input v-model:value="filters.keyword" placeholder="🔍 搜索线路名称" clearable style="width:220px" @keyup.enter="doSearch" />
        <n-select v-model:value="filters.difficulty" :options="difficultyOptions" placeholder="全部难度" clearable style="width:130px" />
        <n-input v-model:value="filters.region" placeholder="📍 地区" clearable style="width:140px" />
        <n-divider vertical />
        <n-radio-group v-model:value="filters.sort" size="small" @update:value="doSearch">
          <n-radio-button value="created_at">🕐 最新</n-radio-button>
          <n-radio-button value="hot">🔥 最热</n-radio-button>
          <n-radio-button value="difficulty">⛰️ 难度</n-radio-button>
        </n-radio-group>
        <n-button type="primary" size="small" @click="doSearch">搜索</n-button>
      </n-space>
    </n-card>

    <n-spin :show="loading">
      <n-grid :cols="4" :x-gap="16" :y-gap="16" responsive="screen">
        <n-grid-item v-for="r in list" :key="r.id">
          <RouteCard :route="r" />
        </n-grid-item>
      </n-grid>
      <n-empty v-if="!loading && !list.length" description="没有找到相关线路" style="margin-top:40px" />
    </n-spin>

    <n-pagination
      v-if="total > filters.pageSize"
      v-model:page="filters.page"
      :page-count="Math.ceil(total / filters.pageSize)"
      style="margin-top:24px;justify-content:center"
      @update:page="load"
    />
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import {
  NSpace, NInput, NSelect, NButton, NGrid, NGridItem, NSpin, NEmpty,
  NPagination, NCard, NDivider, NRadioGroup, NRadioButton
} from 'naive-ui'
import { getRoutes } from '@/api/route'
import RouteCard from '@/components/RouteCard.vue'

const list = ref([])
const total = ref(0)
const loading = ref(false)

const filters = reactive({ keyword: '', difficulty: null, region: '', sort: 'created_at', page: 1, pageSize: 12 })

const difficultyOptions = [
  { label: '简单 Lv.1', value: 1 }, { label: '中等 Lv.2', value: 2 },
  { label: '困难 Lv.3', value: 3 }, { label: '专家 Lv.4', value: 4 }
]

async function load() {
  loading.value = true
  const res = await getRoutes(filters).finally(() => loading.value = false)
  list.value  = res.data.list
  total.value = res.data.total
}

function doSearch() { filters.page = 1; load() }

onMounted(load)
</script>
