/**
 * TrekHub 后端入口文件
 * 功能：启动 Express 服务器、注册路由、配置中间件、初始化 WebSocket 和定时任务
 */
require('dotenv').config()
const express = require('express')
const http = require('http')
const { Server } = require('socket.io')       // WebSocket 服务端
const cors = require('cors')                   // 跨域支持
const path = require('path')
const cron = require('node-cron')              // 定时任务调度

const { sequelize } = require('./src/models')  // 数据库连接实例
const chatHandler = require('./src/socket/chatHandler')   // WebSocket 聊天处理
const matchService = require('./src/services/matchService') // 随机组队服务

const app = express()
const server = http.createServer(app)

// 创建 Socket.IO 实例，配置允许跨域的前端地址
const io = new Server(server, {
  cors: { origin: ['http://localhost:5173', 'http://127.0.0.1:5173'], credentials: true }
})

// ========== 中间件 ==========
app.use(cors({ origin: ['http://localhost:5173', 'http://127.0.0.1:5173'], credentials: true }))
app.use(express.json({ limit: '10mb' }))                          // 解析 JSON 请求体
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))) // 静态文件（上传的图片等）

// ========== 路由注册（RESTful API） ==========
app.use('/api/auth',       require('./src/routes/auth'))       // 登录注册
app.use('/api/users',      require('./src/routes/users'))      // 用户管理
app.use('/api/routes',     require('./src/routes/routes'))     // 徒步线路
app.use('/api/activities', require('./src/routes/activities')) // 组队活动
app.use('/api/chat',       require('./src/routes/chat'))       // 聊天
app.use('/api/comments',   require('./src/routes/comments'))   // 评论
app.use('/api/favorites',  require('./src/routes/favorites'))  // 收藏
app.use('/api/checkins',   require('./src/routes/checkins'))   // 打卡
app.use('/api/ai',         require('./src/routes/ai'))         // AI 助手
app.use('/api/match',      require('./src/routes/match'))      // 随机组队
app.use('/api/admin',      require('./src/routes/admin'))      // 后台管理
app.use('/api/docs',       require('./src/routes/docs'))       // API 文档

// ========== WebSocket 实时通信 ==========
chatHandler(io)

// ========== 定时任务：每5分钟执行一次随机组队匹配 ==========
cron.schedule('*/5 * * * *', () => {
  matchService.runMatching(io).catch(console.error)
})

// ========== 全局错误处理 ==========
app.use((err, req, res, next) => {
  console.error('[Express Error]', err.message)
  res.status(500).json({ code: 500, msg: err.message || '服务器错误', data: null })
})

// 捕获未处理的 Promise 异常，防止进程崩溃
process.on('unhandledRejection', (reason) => {
  console.error('[UnhandledRejection]', reason?.message || reason)
})

// ========== 启动服务 ==========
const PORT = process.env.PORT || 3000

sequelize.authenticate()
  .then(() => {
    console.log('✅ 数据库连接成功')
    return sequelize.sync({ alter: false })  // 同步模型（不自动修改表结构）
  })
  .then(() => {
    server.listen(PORT, () => console.log(`🚀 TrekHub 后端启动 http://localhost:${PORT}`))
  })
  .catch(err => {
    console.error('❌ 启动失败:', err.message)
    process.exit(1)
  })
