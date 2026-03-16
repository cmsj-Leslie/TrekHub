<template>
  <div class="admin-page">
    <div class="admin-banner">
      <h2 style="margin:0;font-size:22px">🛡️ 后台管理</h2>
      <p style="margin:4px 0 0;opacity:.85;font-size:13px">用户、线路与评论内容管理</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-grid">
      <div v-for="s in statCards" :key="s.label" class="stat-card" @click="handleStatClick(s)">
        <div class="stat-icon" :style="{ background: s.color }">{{ s.icon }}</div>
        <div class="stat-info">
          <div class="stat-value">{{ s.value }}</div>
          <div class="stat-label">{{ s.label }}</div>
        </div>
        <div v-if="s.today !== undefined" class="stat-today">今日 +{{ s.today }}</div>
        <div class="stat-arrow">›</div>
      </div>
    </div>

    <!-- 管理标签页 -->
    <n-tabs type="card" style="margin-top:20px" v-model:value="activeTab" animated>
      <!-- 用户管理 -->
      <n-tab-pane name="users" tab="👥 用户管理">
        <n-card class="tab-card">
          <div class="toolbar">
            <div class="toolbar-left">
              <n-input v-model:value="userKeyword" placeholder="🔍 搜索用户名 / 昵称 / 邮箱" clearable
                style="width:300px" @keyup.enter="loadUsers" />
              <n-button type="primary" size="small" @click="loadUsers">搜索</n-button>
            </div>
            <span class="result-count">共 {{ userTotal }} 个用户</span>
          </div>
          <n-data-table :columns="userColumns" :data="users" :loading="userLoading" :pagination="false"
            :bordered="false" striped size="small" />
          <div class="table-footer">
            <n-pagination v-model:page="userPage" :page-count="userPageCount" size="small" @update:page="loadUsers" />
          </div>
        </n-card>
      </n-tab-pane>

      <!-- 线路管理 -->
      <n-tab-pane name="routes" tab="🗺️ 线路管理">
        <n-card class="tab-card">
          <div class="toolbar">
            <div class="toolbar-left">
              <n-input v-model:value="routeKeyword" placeholder="🔍 搜索线路名称" clearable
                style="width:300px" @keyup.enter="loadRoutes" />
              <n-button type="primary" size="small" @click="loadRoutes">搜索</n-button>
              <n-button type="success" size="small" @click="$router.push('/routes/create')">➕ 新增线路</n-button>
            </div>
            <span class="result-count">共 {{ routeTotal }} 条线路</span>
          </div>
          <n-data-table :columns="routeColumns" :data="adminRoutes" :loading="routeLoading" :pagination="false"
            :bordered="false" striped size="small" />
          <div class="table-footer">
            <n-pagination v-model:page="routePage" :page-count="routePageCount" size="small" @update:page="loadRoutes" />
          </div>
        </n-card>
      </n-tab-pane>

      <!-- 评论管理 -->
      <n-tab-pane name="comments" tab="💬 评论管理">
        <n-card class="tab-card">
          <div class="toolbar">
            <div class="toolbar-left">
              <n-input v-model:value="commentKeyword" placeholder="🔍 搜索评论内容" clearable
                style="width:300px" @keyup.enter="loadComments" />
              <n-button type="primary" size="small" @click="loadComments">搜索</n-button>
            </div>
            <span class="result-count">共 {{ commentTotal }} 条评论</span>
          </div>
          <n-data-table :columns="commentColumns" :data="adminComments" :loading="commentLoading" :pagination="false"
            :bordered="false" striped size="small" :row-props="commentRowProps" />
          <div class="table-footer">
            <n-pagination v-model:page="commentPage" :page-count="commentPageCount" size="small" @update:page="loadComments" />
          </div>
        </n-card>
      </n-tab-pane>
    </n-tabs>

    <!-- 编辑用户弹窗 -->
    <n-modal v-model:show="showUserModal" preset="dialog" title="编辑用户信息" positive-text="保存" negative-text="取消"
      @positive-click="saveUser" style="width:500px">
      <n-form :model="userForm" label-placement="left" label-width="70">
        <n-form-item label="昵称"><n-input v-model:value="userForm.nickname" /></n-form-item>
        <n-form-item label="邮箱"><n-input v-model:value="userForm.email" /></n-form-item>
        <n-form-item label="等级">
          <n-slider v-model:value="userForm.level" :min="1" :max="5" :marks="{1:'Lv1',2:'Lv2',3:'Lv3',4:'Lv4',5:'Lv5'}" />
        </n-form-item>
        <n-form-item label="简介"><n-input v-model:value="userForm.bio" type="textarea" :rows="2" /></n-form-item>
        <n-form-item label="角色">
          <n-select v-model:value="userForm.role" :options="roleOptions" />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 编辑线路弹窗 -->
    <n-modal v-model:show="showRouteModal" preset="dialog" title="编辑线路信息" positive-text="保存" negative-text="取消"
      @positive-click="saveRoute" style="width:500px">
      <n-form :model="routeForm" label-placement="left" label-width="70">
        <n-form-item label="线路名称"><n-input v-model:value="routeForm.title" /></n-form-item>
        <n-form-item label="难度">
          <n-select v-model:value="routeForm.difficulty" :options="difficultyOptions" />
        </n-form-item>
        <n-form-item label="地区"><n-input v-model:value="routeForm.region" /></n-form-item>
        <n-form-item label="距离(km)"><n-input-number v-model:value="routeForm.distance_km" :min="0" :precision="2" style="width:100%" /></n-form-item>
        <n-form-item label="海拔(m)"><n-input-number v-model:value="routeForm.elevation_m" :min="0" style="width:100%" /></n-form-item>
        <n-form-item label="状态">
          <n-select v-model:value="routeForm.status" :options="[{label:'正常',value:1},{label:'下架',value:0}]" />
        </n-form-item>
      </n-form>
    </n-modal>

    <!-- 查看评论详情弹窗 -->
    <n-modal v-model:show="showCommentDetail" preset="card" title="📝 评论详情" style="width:520px;border-radius:12px">
      <template v-if="currentComment">
        <div class="detail-section">
          <div class="detail-label">评论内容</div>
          <div class="detail-content">{{ currentComment.content }}</div>
        </div>
        <n-divider style="margin:12px 0" />
        <div class="detail-grid">
          <div class="detail-item">
            <span class="detail-label">👤 用户</span>
            <span>{{ currentComment.user?.nickname || '-' }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">📌 类型</span>
            <n-tag size="small">{{ currentComment.target_type === 1 ? '线路' : '活动' }}</n-tag>
          </div>
          <div class="detail-item">
            <span class="detail-label">⭐ 评分</span>
            <span>{{ currentComment.rating ? '⭐'.repeat(currentComment.rating) : '无评分' }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">👍 点赞</span>
            <span>{{ currentComment.like_count || 0 }}</span>
          </div>
          <div class="detail-item">
            <span class="detail-label">🕐 时间</span>
            <span>{{ fmtDate(currentComment.createdAt || currentComment.created_at) }}</span>
          </div>
        </div>
        <n-divider style="margin:12px 0" />
        <div style="display:flex;justify-content:flex-end">
          <n-popconfirm positive-text="确认删除" negative-text="取消" @positive-click="handleDeleteComment">
            <template #trigger>
              <n-button type="error" size="small" ghost>🗑️ 删除此评论</n-button>
            </template>
            确认删除此评论？此操作不可恢复
          </n-popconfirm>
        </div>
      </template>
    </n-modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, h } from 'vue'
import {
  NCard, NDataTable, NPagination, NInput, NTag, NButton, NSpace, NPopconfirm, NTabs, NTabPane,
  NModal, NForm, NFormItem, NSelect, NSlider, NInputNumber, NDivider,
  useMessage
} from 'naive-ui'
import {
  getAdminStats, getAdminUsers, updateUserRole, adminUpdateUser, adminDeleteUser,
  getAdminRoutes, adminUpdateRoute, adminDeleteRoute,
  getAdminComments, adminDeleteComment
} from '@/api/admin'
import dayjs from 'dayjs'
import { useRouter } from 'vue-router'

const router = useRouter()
const msg = useMessage()
const activeTab = ref('users')
const stats = ref({})

const fmtDate = (d) => d ? dayjs(d).format('YYYY-MM-DD HH:mm') : '-'

const statCards = computed(() => {
  const t = stats.value.total || {}
  const td = stats.value.today || {}
  return [
    { icon: '👥', label: '用户总数', value: t.userCount || 0, today: td.todayUsers, color: '#2d8cf0', tab: 'users' },
    { icon: '🗺️', label: '线路总数', value: t.routeCount || 0, today: td.todayRoutes, color: '#19be6b', tab: 'routes' },
    { icon: '🎯', label: '活动总数', value: t.activityCount || 0, today: td.todayActivities, color: '#ff9900', link: '/activities' },
    { icon: '💬', label: '评论总数', value: t.commentCount || 0, color: '#ed4014', tab: 'comments' },
    { icon: '📍', label: '打卡总数', value: t.checkinCount || 0, color: '#722ed1' }
  ]
})

function handleStatClick(s) {
  if (s.tab) activeTab.value = s.tab
  else if (s.link) router.push(s.link)
}

// ---- 用户管理 ----
const users = ref([])
const userKeyword = ref('')
const userPage = ref(1)
const userTotal = ref(0)
const userLoading = ref(false)
const pageSize = 15
const userPageCount = computed(() => Math.ceil(userTotal.value / pageSize))

const roleMap = { 0: '普通用户', 1: '管理员' }
const roleColor = { 0: 'default', 1: 'error' }
const roleOptions = [{ label: '普通用户', value: 0 }, { label: '管理员', value: 1 }]

// 编辑用户
const showUserModal = ref(false)
const userForm = ref({ id: null, nickname: '', email: '', level: 1, bio: '', role: 0 })

function openEditUser(row) {
  userForm.value = { id: row.id, nickname: row.nickname, email: row.email, level: row.level || 1, bio: row.bio || '', role: row.role }
  showUserModal.value = true
}
async function saveUser() {
  await adminUpdateUser(userForm.value.id, userForm.value)
  msg.success('用户信息已更新')
  showUserModal.value = false
  loadUsers()
}

const userColumns = [
  { title: 'ID', key: 'id', width: 60 },
  { title: '用户名', key: 'username', width: 110 },
  { title: '昵称', key: 'nickname', width: 110 },
  { title: '邮箱', key: 'email', width: 170, ellipsis: { tooltip: true } },
  { title: '等级', key: 'level', width: 60, render: r => '⭐'.repeat(r.level || 1) },
  {
    title: '角色', key: 'role', width: 90,
    render: r => h(NTag, { type: roleColor[r.role], size: 'small' }, () => roleMap[r.role])
  },
  {
    title: '注册时间', key: 'createdAt', width: 140,
    render: r => fmtDate(r.createdAt)
  },
  {
    title: '操作', key: 'actions', width: 140,
    render: r => h(NSpace, { size: 'small' }, () => [
      h(NButton, { size: 'tiny', type: 'info', onClick: () => openEditUser(r) }, () => '编辑'),
      h(NPopconfirm, { positiveText: '确认删除', negativeText: '取消', onPositiveClick: () => deleteUser(r.id) },
        { trigger: () => h(NButton, { size: 'tiny', type: 'error', ghost: true, disabled: r.role === 1 }, () => '删除'),
          default: () => `确认删除用户「${r.nickname || r.username}」？此操作不可恢复` })
    ])
  }
]

async function loadUsers() {
  userLoading.value = true
  try {
    const res = await getAdminUsers({ page: userPage.value, size: pageSize, keyword: userKeyword.value })
    users.value = res.data.list
    userTotal.value = res.data.total
  } finally { userLoading.value = false }
}

async function setRole(id, role) {
  await updateUserRole(id, role)
  msg.success('角色已更新')
  loadUsers()
}

async function deleteUser(id) {
  await adminDeleteUser(id)
  msg.success('用户已删除')
  loadUsers()
}

// ---- 线路管理 ----
const adminRoutes = ref([])
const routeKeyword = ref('')
const routePage = ref(1)
const routeTotal = ref(0)
const routeLoading = ref(false)
const routePageCount = computed(() => Math.ceil(routeTotal.value / pageSize))

const difficultyLabel = d => ['', '简单', '中等', '困难', '专家', '极限'][d] || '中等'
const difficultyType = d => ['', 'success', 'info', 'warning', 'error', 'error'][d] || 'info'
const difficultyOptions = [
  { label: '简单', value: 1 }, { label: '中等', value: 2 },
  { label: '困难', value: 3 }, { label: '专家', value: 4 }, { label: '极限', value: 5 }
]

// 编辑线路
const showRouteModal = ref(false)
const routeForm = ref({ id: null, title: '', difficulty: 1, region: '', distance_km: 0, elevation_m: 0, status: 1 })

function openEditRoute(row) {
  routeForm.value = { id: row.id, title: row.title, difficulty: row.difficulty, region: row.region, distance_km: row.distance_km, elevation_m: row.elevation_m, status: row.status }
  showRouteModal.value = true
}
async function saveRoute() {
  await adminUpdateRoute(routeForm.value.id, routeForm.value)
  msg.success('线路信息已更新')
  showRouteModal.value = false
  loadRoutes()
}

const routeColumns = [
  { title: 'ID', key: 'id', width: 60 },
  { title: '线路名称', key: 'title', width: 180, ellipsis: { tooltip: true } },
  { title: '创建者', key: 'creator', width: 90, render: r => r.creator?.nickname || '-' },
  {
    title: '难度', key: 'difficulty', width: 80,
    render: r => h(NTag, { type: difficultyType(r.difficulty), size: 'small' }, () => difficultyLabel(r.difficulty))
  },
  { title: '距离', key: 'distance_km', width: 80, render: r => `${r.distance_km || 0} km` },
  { title: '收藏', key: 'like_count', width: 60 },
  {
    title: '状态', key: 'status', width: 70,
    render: r => h(NTag, { type: r.status === 1 ? 'success' : 'error', size: 'small' }, () => r.status === 1 ? '正常' : '已下架')
  },
  {
    title: '创建时间', key: 'createdAt', width: 130,
    render: r => fmtDate(r.createdAt)
  },
  {
    title: '操作', key: 'actions', width: 130,
    render: r => h(NSpace, { size: 'small' }, () => [
      h(NButton, { size: 'tiny', type: 'info', onClick: () => openEditRoute(r) }, () => '编辑'),
      h(NPopconfirm, { positiveText: '确认删除', negativeText: '取消', onPositiveClick: () => deleteRoute(r.id) },
        { trigger: () => h(NButton, { size: 'tiny', type: 'error', ghost: true }, () => '删除'),
          default: () => `确认删除「${r.title}」？` })
    ])
  }
]

async function loadRoutes() {
  routeLoading.value = true
  try {
    const res = await getAdminRoutes({ page: routePage.value, size: pageSize, keyword: routeKeyword.value })
    adminRoutes.value = res.data.list
    routeTotal.value = res.data.total
  } finally { routeLoading.value = false }
}

async function deleteRoute(id) {
  await adminDeleteRoute(id)
  msg.success('线路已删除')
  loadRoutes()
}

// ---- 评论管理 ----
const adminComments = ref([])
const commentKeyword = ref('')
const commentPage = ref(1)
const commentTotal = ref(0)
const commentLoading = ref(false)
const commentPageCount = computed(() => Math.ceil(commentTotal.value / pageSize))

const targetTypeLabel = t => t === 1 ? '线路' : '活动'

// 评论详情
const showCommentDetail = ref(false)
const currentComment = ref(null)

function openCommentDetail(row) {
  currentComment.value = row
  showCommentDetail.value = true
}

const commentRowProps = (row) => ({
  style: 'cursor: pointer',
  onClick: () => openCommentDetail(row)
})

const commentColumns = [
  { title: 'ID', key: 'id', width: 60 },
  { title: '评论内容', key: 'content', width: 280, ellipsis: { tooltip: true } },
  { title: '用户', key: 'user', width: 90, render: r => r.user?.nickname || '-' },
  {
    title: '类型', key: 'target_type', width: 70,
    render: r => h(NTag, { size: 'small' }, () => targetTypeLabel(r.target_type))
  },
  { title: '评分', key: 'rating', width: 70, render: r => r.rating ? '⭐'.repeat(r.rating) : '-' },
  {
    title: '时间', key: 'createdAt', width: 130,
    render: r => fmtDate(r.createdAt || r.created_at)
  },
  {
    title: '操作', key: 'actions', width: 80,
    render: r => h(NButton, {
      size: 'tiny', type: 'info',
      onClick: (e) => { e.stopPropagation(); openCommentDetail(r) }
    }, () => '查看')
  }
]

async function handleDeleteComment() {
  if (!currentComment.value) return
  await adminDeleteComment(currentComment.value.id)
  msg.success('评论已删除')
  showCommentDetail.value = false
  loadComments()
}

async function loadComments() {
  commentLoading.value = true
  try {
    const res = await getAdminComments({ page: commentPage.value, size: pageSize, keyword: commentKeyword.value })
    adminComments.value = res.data.list
    commentTotal.value = res.data.total
  } finally { commentLoading.value = false }
}

async function deleteComment(id) {
  await adminDeleteComment(id)
  msg.success('评论已删除')
  loadComments()
}

// ---- 初始化 ----
onMounted(async () => {
  const res = await getAdminStats()
  stats.value = res.data
  loadUsers()
  loadRoutes()
  loadComments()
})
</script>

<style scoped>
.admin-page { max-width: 1200px; margin: 0 auto; padding: 20px; }
.admin-banner {
  background: linear-gradient(135deg, #1e293b, #334155);
  color: #fff;
  padding: 24px;
  border-radius: 12px;
  margin-bottom: 20px;
}
.stats-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(180px, 1fr)); gap: 16px; }
.stat-card {
  position: relative;
  border-radius: 10px;
  border: 1px solid #eee;
  background: #fff;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px;
  cursor: pointer;
  transition: all .3s ease;
}
.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0,0,0,.08);
  border-color: #d0e3ff;
}
.stat-card:hover .stat-arrow { opacity: 1; transform: translateX(0); }
.stat-icon {
  width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center;
  justify-content: center; font-size: 20px; color: #fff; flex-shrink: 0;
}
.stat-value { font-size: 22px; font-weight: 700; color: #333; }
.stat-label { font-size: 13px; color: #999; }
.stat-today { position: absolute; top: 8px; right: 12px; font-size: 11px; color: #19be6b; }
.stat-arrow {
  position: absolute;
  right: 12px;
  bottom: 14px;
  font-size: 18px;
  color: #ccc;
  opacity: 0;
  transform: translateX(-4px);
  transition: all .3s ease;
}

.tab-card { border-radius: 10px !important; margin-top: 4px; }
.tab-card :deep(.n-card__content) { padding: 16px !important; }
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
  padding-bottom: 14px;
  border-bottom: 1px solid #f0f0f0;
}
.toolbar-left {
  display: flex;
  align-items: center;
  gap: 8px;
}
.result-count {
  font-size: 13px;
  color: #999;
}
.table-footer {
  display: flex;
  justify-content: flex-end;
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px solid #f0f0f0;
}

.detail-section { margin-bottom: 4px; }
.detail-content {
  background: #f9fafb;
  padding: 14px 16px;
  border-radius: 8px;
  font-size: 14px;
  line-height: 1.8;
  color: #333;
  margin-top: 6px;
  white-space: pre-wrap;
  word-break: break-word;
}
.detail-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
}
.detail-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #555;
}
.detail-label {
  font-size: 13px;
  color: #999;
  font-weight: 500;
}
</style>
