/**
 * 前端路由配置（Vue Router）
 * 功能：定义所有页面路由、懒加载组件、导航守卫（登录/权限校验）
 */
import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'

// 路由表（使用懒加载，按需加载页面组件）
const routes = [
  // 公开页面
  { path: '/',             component: () => import('@/pages/Home.vue'), meta: { title: '首页' } },
  { path: '/login',        component: () => import('@/pages/Login.vue'), meta: { title: '登录' } },
  { path: '/register',     component: () => import('@/pages/Register.vue'), meta: { title: '注册' } },

  // 线路模块
  { path: '/routes',       component: () => import('@/pages/Routes/RouteList.vue'), meta: { title: '探索线路' } },
  { path: '/routes/create',component: () => import('@/pages/Routes/RouteCreate.vue'), meta: { title: '创建线路', auth: true } },
  { path: '/routes/:id',   component: () => import('@/pages/Routes/RouteDetail.vue'), meta: { title: '线路详情' } },

  // 活动模块
  { path: '/activities',   component: () => import('@/pages/Activities/ActivityList.vue'), meta: { title: '找活动' } },
  { path: '/activities/create', component: () => import('@/pages/Activities/ActivityCreate.vue'), meta: { title: '发起活动', auth: true } },
  { path: '/activities/:id',    component: () => import('@/pages/Activities/ActivityDetail.vue'), meta: { title: '活动详情' } },

  // 聊天模块
  { path: '/chat',         component: () => import('@/pages/Chat/ChatList.vue'), meta: { title: '消息', auth: true } },
  { path: '/chat/:roomId', component: () => import('@/pages/Chat/ChatRoom.vue'), meta: { title: '聊天', auth: true } },

  // 功能模块
  { path: '/match',        component: () => import('@/pages/Match.vue'), meta: { title: '随机组队', auth: true } },
  { path: '/checkin',      component: () => import('@/pages/Checkin.vue'), meta: { title: '打卡', auth: true } },
  { path: '/ai',           component: () => import('@/pages/AI/AIChat.vue'), meta: { title: 'AI助手', auth: true } },

  // 用户模块
  { path: '/profile/:id',  component: () => import('@/pages/Profile/UserProfile.vue'), meta: { title: '个人主页' } },
  { path: '/settings',     component: () => import('@/pages/Profile/Settings.vue'), meta: { title: '设置', auth: true } },

  // 后台管理（仅管理员）
  { path: '/admin',        component: () => import('@/pages/Admin/AdminDashboard.vue'), meta: { title: '后台管理', auth: true, admin: true } },

  // 兜底：未匹配路由重定向到首页
  { path: '/:pathMatch(.*)*', redirect: '/' }
]

const router = createRouter({
  history: createWebHistory(),      // HTML5 History 模式
  routes,
  scrollBehavior: () => ({ top: 0 }) // 切换页面时自动滚到顶部
})

// 全局导航守卫：检查登录状态和管理员权限
router.beforeEach((to) => {
  if (to.meta.title) document.title = `${to.meta.title} - TrekHub`
  const userStore = useUserStore()
  if (to.meta.auth && !userStore.isLoggedIn) return '/login'  // 需要登录但未登录 → 跳转登录
  if (to.meta.admin && !userStore.isAdmin) return '/'          // 需要管理员但不是 → 跳转首页
})

export default router
