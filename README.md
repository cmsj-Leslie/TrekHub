# 🏔️ TrekHub — 基于Vue.js的徒步旅行线路规划与同伴组队平台

> 毕业设计项目 · 前后端分离架构 · B/S模式

一款面向户外徒步爱好者的 Web 应用平台，提供**线路浏览与分享**、**组队活动管理**、**实时聊天**、**AI智能助手**、**个性化推荐**、**打卡记录**等核心功能。系统采用前后端分离的 B/S 架构，前端使用 Vue.js 3 构建单页应用（SPA），后端基于 Node.js + Express 提供 RESTful API 服务，集成 DeepSeek 大语言模型实现 AI 智能对话与推荐，使用高德地图 JS API 2.0 展示徒步线路 GPS 轨迹。

---

## 📁 项目结构

```
TrekHub/
├── frontend/                    # 前端项目 (Vue 3 + Vite)
│   ├── src/
│   │   ├── api/                 # Axios 请求封装（按模块拆分）
│   │   ├── components/          # 可复用组件（RouteCard、CommentList等）
│   │   ├── composables/         # Vue 3 组合式函数（useMap、useFavorite、usePagination）
│   │   ├── pages/               # 页面组件（按功能模块分目录）
│   │   │   ├── Login.vue        # 登录页
│   │   │   ├── Register.vue     # 注册页
│   │   │   ├── Home.vue         # 首页（推荐 + 热门 + 动态）
│   │   │   ├── Routes/          # 线路模块（列表、详情、创建）
│   │   │   ├── Activities/      # 活动模块（列表、详情、创建）
│   │   │   ├── Chat/            # 实时聊天（会话列表、聊天室）
│   │   │   ├── AI/              # AI 智能助手
│   │   │   ├── Match.vue        # 随机组队
│   │   │   ├── Checkin.vue      # 打卡记录
│   │   │   ├── Profile/         # 个人中心
│   │   │   └── Admin/           # 后台管理
│   │   ├── router/              # Vue Router 路由配置
│   │   ├── stores/              # Pinia 状态管理（user、chat）
│   │   ├── utils/               # 工具函数
│   │   ├── App.vue              # 根组件（导航栏 + 路由视图）
│   │   └── main.js              # 应用入口
│   ├── index.html               # HTML 入口（加载高德地图 SDK）
│   ├── vite.config.js           # Vite 构建配置（含 HTML 环境变量替换插件）
│   └── package.json
├── backend/                     # 后端项目 (Node.js + Express)
│   ├── src/
│   │   ├── config/              # 配置（数据库连接 db.js、AI参数 ai.js）
│   │   ├── controllers/         # 控制器层（12个控制器，处理请求逻辑）
│   │   ├── middleware/          # 中间件（JWT认证 auth.js、管理员权限 admin.js）
│   │   ├── models/              # Sequelize ORM 数据模型（16张表）
│   │   ├── routes/              # 路由层（RESTful API 定义，13个模块）
│   │   ├── services/            # 服务层
│   │   │   ├── aiService.js     # AI 对话与推荐（DeepSeek 大模型调用）
│   │   │   ├── recommendService.js  # 混合推荐算法（协同过滤+内容+热度）
│   │   │   └── matchService.js  # 随机组队匹配（即时匹配+定时兜底）
│   │   ├── socket/              # WebSocket 事件处理（实时聊天）
│   │   └── utils/               # 工具函数（统一响应格式）
│   ├── uploads/                 # 文件上传存储目录
│   ├── server.js                # 服务启动入口
│   └── package.json
├── database/                    # 数据库脚本
│   ├── init.sql                 # 表结构初始化
│   └── seed.sql                 # 测试数据
├── trekhub.sql                  # 完整数据库导出（含结构和数据）
└── start.bat                    # Windows 一键启动脚本
```

---

## 🛠️ 技术栈

### 前端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Vue.js 3** | v3.5 | 前端框架，Composition API + `<script setup>` 语法 |
| **Vite** | v8.0 | 构建工具，HMR 热更新，毫秒级启动 |
| **Vue Router** | v4.2 | 前端路由，SPA 页面跳转与导航守卫 |
| **Pinia** | v2.1 | 状态管理，管理用户登录状态与聊天数据 |
| **Naive UI** | v2.38 | 企业级 UI 组件库 |
| **Axios** | v1.6 | HTTP 客户端，封装请求/响应拦截器 |
| **Socket.IO Client** | v4.6 | WebSocket 客户端，实现实时聊天 |
| **高德地图 JS API 2.0** | v2.0 | 地图展示、GPS 轨迹绘制、地理编码 |
| **Day.js** | v1.11 | 轻量级日期处理 |

### 后端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Node.js** | v18+ | JavaScript 服务端运行环境 |
| **Express.js** | v4.18 | Web 框架，构建 RESTful API |
| **Sequelize** | v6.35 | ORM 框架，对象关系映射操作 MySQL |
| **MySQL** | v8.0 | 关系型数据库，16张核心表 |
| **Socket.IO** | v4.6 | WebSocket 服务端，双向实时通信 |
| **JSON Web Token** | v9.0 | JWT 无状态身份认证 |
| **bcryptjs** | v2.4 | 密码哈希加密 |
| **Multer** | v1.4 | 文件上传中间件 |
| **node-cron** | v3.0 | 定时任务调度（组队匹配兜底） |
| **DeepSeek API** | - | 大语言模型，驱动 AI 助手与智能推荐 |
| **dotenv** | v16.3 | 环境变量管理 |

---

## 🏗️ 系统架构

```
┌───────────────────────────────────────────────────────────┐
│                      浏览器 (Client)                       │
│   Vue 3 SPA + Vue Router + Pinia + Naive UI + 高德地图     │
├──────────────┬────────────────────────────┬────────────────┤
│  Axios HTTP  │    Socket.IO WebSocket     │   高德地图SDK  │
├──────────────┴────────────────────────────┴────────────────┤
│                     Vite 开发服务器                         │
│              http://localhost:5173 (代理API)                │
└────────────────────────────┬──────────────────────────────┘
                             │ JSON / WebSocket
┌────────────────────────────▼──────────────────────────────┐
│                   Express.js 后端服务                      │
│             http://localhost:3000/api/*                     │
├───────────────────────────────────────────────────────────┤
│  JWT认证中间件  │  路由层(13模块)  │  控制器层(12个)        │
├───────────────────────────────────────────────────────────┤
│         服务层                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐   │
│  │ AI 对话服务  │  │ 推荐算法服务  │  │ 随机匹配服务    │   │
│  │ (DeepSeek)  │  │ (混合推荐)   │  │ (即时+定时)    │   │
│  └─────────────┘  └──────────────┘  └────────────────┘   │
├───────────────────────────────────────────────────────────┤
│  Sequelize ORM  │  Socket.IO Server  │  node-cron 定时    │
├─────────────────┴────────────────────┴────────────────────┤
│                       MySQL 数据库                         │
│               16 张核心表 + 关联关系                        │
└───────────────────────────────────────────────────────────┘
```

### 前后端数据交互流程

1. **HTTP 请求**：前端 Axios 发送 RESTful API 请求 → 后端返回统一格式 `{ code, msg, data }`
2. **身份认证**：登录获取 JWT Token → localStorage 存储 → Axios 拦截器自动注入 `Authorization: Bearer <token>`
3. **实时通信**：Socket.IO 建立 WebSocket 长连接，支持消息实时推送和组队匹配通知
4. **文件上传**：Multer 中间件处理 FormData，存储至 uploads/ 目录

---

## 🚀 功能模块

### 1. 用户系统
- 注册/登录（JWT Token 认证）
- 个人信息管理（头像上传、个人简介）
- 技能标签设置（攀岩、露营、导航等）
- 用户等级系统（1-5级）与累计里程统计
- 关注/粉丝社交关系
- 角色权限（普通用户/管理员）

### 2. 线路模块
- 线路浏览（分页、难度筛选、关键字搜索）
- 线路详情 — 高德地图展示 GPS 轨迹（矢量/卫星双模式切换）
- 创建线路 — 地图点击绘制路线 + 支持 GPX 文件上传解析
- 海拔剖面图展示、难度分级（简单/中等/困难/专家）
- 线路收藏、评论评分、分享功能
- AI 智能线路推荐（基于混合推荐算法）

### 3. 活动模块
- 发布徒步活动（关联线路、安全信息必填）
- 报名申请 + 组织者审批流程
- 活动状态自动更新（招募中→已满→已结束）
- 审批通过自动加入活动群聊
- 活动结束后参与者互评（评分 + 评语）

### 4. 实时聊天
- 私信聊天 + 活动群聊
- 基于 Socket.IO 的 WebSocket 实时双向通信
- 支持文字和图片消息
- 未读消息计数、已读状态标记
- 智能会话名称（私聊显示对方昵称、群聊显示活动标题）

### 5. AI 智能助手
- 基于 DeepSeek 大语言模型（deepseek-chat）
- 三种独立对话场景：线路规划、组队匹配、通用问答
- 上下文多轮对话记忆（保留最近6条消息）
- AI 智能线路推荐（结合用户画像生成推荐理由）
- Token 节省策略（上下文截断 + 输出限制 + 结果缓存30分钟）

### 6. 个性化推荐系统
- **混合推荐算法**：内容相关 40% + 协同过滤 40% + 热度 20%
- 内容相关：根据用户等级推荐难度匹配的线路
- 协同过滤：分析行为相似用户的收藏偏好
- 热度加权：浏览量和收藏数作为补充评分

### 7. 随机组队
- 加入匹配池（设置线路偏好、日期、等级范围、技能标签）
- **即时匹配**：加入后立即触发一次匹配 + 每1分钟定时兜底
- 匹配成功自动创建活动和群聊，WebSocket 实时推送通知

### 8. 打卡系统
- 创建打卡记录（标题、内容、多图上传、里程记录）
- 日历视图统计
- 首页展示最近打卡动态

### 9. 评论系统
- 支持线路和活动的多目标评论
- 评论图片上传（最多3张）
- 评分星级（线路评价）
- 评论点赞/取消点赞、评论回复

### 10. 用户互评
- 活动结束后成员互评
- 用户主页「收到的评价」展示
- 平均评分统计

### 11. 后台管理
- 管理员统计面板（用户数、线路数、活动数、打卡数）
- 用户管理（角色分配、封禁/解封）
- 线路内容审核
- 评论管理

### 12. API 文档
- 后端自渲染 HTML 文档页，覆盖 13 个模块 50+ 个接口
- 访问地址：`http://localhost:3000/api/docs`

---

## 🗄️ 数据库设计

系统使用 MySQL 8.0 关系型数据库，共 **16 张核心表**：

| 表名 | 说明 | 核心字段 |
|------|------|---------| 
| `users` | 用户表 | id, username, password, nickname, avatar, role, level |
| `routes` | 线路表 | id, title, difficulty, distance_km, region, creator_id |
| `route_points` | 线路坐标点 | route_id, lat, lng, elevation, seq |
| `activities` | 活动表 | id, title, route_id, organizer_id, status, max_members |
| `activity_members` | 活动成员 | activity_id, user_id, status, role |
| `activity_reviews` | 活动互评 | reviewer_id, reviewee_id, rating, content |
| `chat_rooms` | 聊天室 | id, name, type(1私信/2群聊), activity_id |
| `room_members` | 聊天室成员 | room_id, user_id |
| `messages` | 聊天消息 | room_id, sender_id, content, type(1文字/2图片), is_read |
| `comments` | 评论表 | target_type, target_id, user_id, content, images, rating |
| `comment_likes` | 评论点赞 | user_id, comment_id |
| `favorites` | 收藏表 | user_id, target_type, target_id |
| `checkins` | 打卡记录 | user_id, title, content, images, distance_km |
| `ai_sessions` | AI对话会话 | user_id, session_type, messages, tokens_used |
| `match_pool` | 随机组队池 | user_id, route_id, prefer_date, skill_tags, status |
| `user_follows` | 关注关系 | follower_id, following_id |
| `user_skills` | 用户技能关联 | user_id, tag_id |
| `skill_tags` | 技能标签 | id, name |

---

## 📦 新服务器部署指南

### 环境要求

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| **Node.js** | >= 18.x | JavaScript 运行环境 |
| **npm** | >= 9.x | 包管理工具（随 Node.js 安装） |
| **MySQL** | >= 8.0 | 关系型数据库 |

### 第一步：获取项目代码

```bash
# 方式一：Git 拉取
git clone <你的仓库地址> TrekHub
cd TrekHub

# 方式二：直接拷贝项目文件夹到新服务器
```

### 第二步：初始化数据库

```bash
# 1. 登录 MySQL
mysql -u root -p

# 2. 创建数据库
CREATE DATABASE trekhub DEFAULT CHARACTER SET utf8mb4;
exit;

# 3. 导入完整数据（表结构+测试数据）
mysql -u root -p trekhub < trekhub.sql
```

### 第三步：配置后端环境变量

```bash
cd backend
cp .env.example .env
# 编辑 .env 文件，修改下列配置
```

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `DB_HOST` | 数据库地址 | `localhost` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_NAME` | 数据库名 | `trekhub` |
| `DB_USER` | 数据库用户名 | `root` |
| `DB_PASS` | 数据库密码 | `你的密码` |
| `JWT_SECRET` | JWT 签名密钥 | `my-secret-key-2026` |
| `DEEPSEEK_API_KEY` | DeepSeek AI Key | 从 [DeepSeek 官网](https://platform.deepseek.com/) 获取 |

### 第四步：配置前端环境变量

```bash
cd frontend
```

编辑 `frontend/.env`：

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `VITE_API_BASE_URL` | 后端地址 | `http://localhost:3000` |
| `VITE_AMAP_KEY` | 高德地图 Web JS Key | 从 [高德开放平台](https://console.amap.com/) 获取 |
| `VITE_AMAP_SECURITY_CODE` | 高德安全密钥 | 高德控制台获取 |

### 第五步：安装依赖并启动

```bash
# 后端
cd backend
npm install
npm run dev
# 看到 "✅ 数据库连接成功" 和 "🚀 TrekHub 后端启动" 即成功

# 前端（新开终端）
cd frontend
npm install
npm run dev
# 前端运行在 http://localhost:5173
```

### 一键启动（Windows）

```bash
# 双击根目录下的 start.bat，自动启动前后端
start.bat
```

### 验证部署

| 地址 | 说明 |
|------|------|
| `http://localhost:5173` | 前端页面 |
| `http://localhost:3000/api/docs` | API 接口文档 |

默认测试账号：

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | `admin` | `123456` |
| 普通用户 | `testuser` | `123456` |

### 常见问题

| 问题 | 解决方案 |
|------|---------| 
| `Access denied for user ''@'localhost'` | 后端 `.env` 文件缺失或数据库用户名密码未填写 |
| `数据库连接失败` | 检查 `.env` 中的数据库配置，确认 MySQL 服务已启动 |
| `端口被占用` | 修改 `.env` 中的 `PORT`，或关闭占用端口的程序 |
| `npm install 失败` | 删除 node_modules 重试，或换源 `npm config set registry https://registry.npmmirror.com` |
| `AI 功能无法使用` | 检查 `DEEPSEEK_API_KEY` 是否正确配置且有余额 |
| `高德地图不显示` | 检查前端 `.env` 中 `VITE_AMAP_KEY` 和 `VITE_AMAP_SECURITY_CODE` 是否配置 |

---

## 📐 RESTful API 设计规范

系统全部 API 遵循 RESTful 设计原则：

- **GET** — 获取资源（如 `GET /api/routes` 获取线路列表）
- **POST** — 创建资源（如 `POST /api/activities` 创建活动）
- **PUT** — 更新资源（如 `PUT /api/users/me/profile` 更新个人信息）
- **DELETE** — 删除资源（如 `DELETE /api/comments/:id` 删除评论）

### 统一响应格式

```json
{
  "code": 200,
  "msg": "ok",
  "data": { ... }
}
```

### 认证机制

```
请求头：Authorization: Bearer <JWT Token>
```

完整 API 文档请访问：`http://localhost:3000/api/docs`

---

## 🔒 安全特性

- ✅ 密码 bcrypt 哈希加密存储
- ✅ JWT Token 无状态身份认证
- ✅ Sequelize ORM 参数化查询防 SQL 注入
- ✅ CORS 跨域白名单配置
- ✅ WebSocket 连接前 JWT 验证
- ✅ 文件上传类型与大小限制
- ✅ 请求参数校验（express-validator）

---

## 📄 License

本项目为毕业设计作品，仅供学习和答辩展示使用。
