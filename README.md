# 🏔️ TrekHub — 基于Vue.js的徒步旅行线路规划与同伴组队平台

> 毕业设计项目 · 前后端分离架构 · B/S模式

一款面向户外徒步爱好者的 Web 应用平台，提供**线路浏览与分享**、**组队活动管理**、**实时聊天**、**AI智能助手**、**打卡记录**等核心功能。系统采用前后端分离的 B/S 架构，前端使用 Vue.js 3 构建单页应用（SPA），后端基于 Node.js + Express 提供 RESTful API 服务。

---

## 📁 项目结构

```
TrekHub/
├── frontend/               # 前端项目 (Vue 3 + Vite)
│   ├── src/
│   │   ├── api/            # Axios 请求封装（按模块拆分）
│   │   ├── components/     # 可复用组件（ActivityCard、CommentList等）
│   │   ├── pages/          # 页面组件（按功能模块分目录）
│   │   ├── router/         # Vue Router 路由配置
│   │   ├── stores/         # Pinia 状态管理（user、chat）
│   │   ├── App.vue         # 根组件（导航栏 + 路由视图）
│   │   └── main.js         # 应用入口
│   └── package.json
├── backend/                # 后端项目 (Node.js + Express)
│   ├── src/
│   │   ├── config/         # 数据库配置
│   │   ├── controllers/    # 控制器层（业务逻辑）
│   │   ├── middleware/     # 中间件（JWT认证、管理员权限）
│   │   ├── models/         # Sequelize ORM 数据模型
│   │   ├── routes/         # 路由层（RESTful API 定义）
│   │   ├── services/       # 服务层（AI对话、随机匹配）
│   │   ├── socket/         # WebSocket 事件处理
│   │   └── utils/          # 工具函数（统一响应格式）
│   ├── uploads/            # 文件上传存储目录
│   ├── server.js           # 服务启动入口
│   └── package.json
├── database/               # 数据库脚本
│   ├── init.sql            # 表结构初始化
│   └── seed.sql            # 测试数据
└── start.bat               # 一键启动脚本
```

---

## 🛠️ 技术栈

### 前端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Vue.js 3** | v3.5 | 前端框架，使用 Composition API + `<script setup>` 语法 |
| **Vite** | v8.0 | 构建工具，支持 HMR 热更新，快速开发体验 |
| **Vue Router** | v4.2 | 前端路由管理，SPA 页面跳转与导航守卫 |
| **Pinia** | v2.1 | 状态管理，管理用户登录状态与聊天数据 |
| **Naive UI** | v2.38 | 企业级 UI 组件库，提供表单、表格、弹窗等组件 |
| **Axios** | v1.6 | HTTP 客户端，封装请求拦截器（Token自动注入） |
| **Socket.IO Client** | v4.6 | WebSocket 客户端，实现实时聊天功能 |
| **Leaflet** | v1.9 | 开源地图库，展示徒步线路的 GPS 轨迹 |
| **Day.js** | v1.11 | 轻量级日期处理库 |

### 后端技术

| 技术 | 版本 | 用途 |
|------|------|------|
| **Node.js** | v18+ | JavaScript 服务端运行环境 |
| **Express.js** | v4.18 | Web 框架，构建 RESTful API |
| **Sequelize** | v6.35 | ORM 框架，对象关系映射操作 MySQL |
| **MySQL** | v8.0 | 关系型数据库，存储核心业务数据 |
| **Socket.IO** | v4.6 | WebSocket 服务端，实现双向实时通信 |
| **JSON Web Token** | v9.0 | JWT 身份认证，无状态 Token 验证 |
| **bcryptjs** | v2.4 | 密码哈希加密，安全存储用户密码 |
| **Multer** | v1.4 | 文件上传中间件，处理头像/图片上传 |
| **node-cron** | v3.0 | 定时任务调度，支撑随机匹配等周期任务 |
| **DeepSeek API** | - | 大语言模型 API，驱动系统内 AI 助手 |
| **dotenv** | v16.3 | 环境变量管理 |

### 开发工具

| 工具 | 用途 |
|------|------|
| **Git** | 版本控制 |
| **VS Code** | 代码编辑器 |
| **Postman / API 文档** | 接口测试（`http://localhost:3000/api/docs`） |
| **Chrome DevTools** | 前端调试 |
| **MySQL Workbench** | 数据库管理 |

---

## 🏗️ 系统架构

```
┌───────────────────────────────────────────────────────────┐
│                      浏览器 (Client)                       │
│  Vue 3 SPA + Vue Router + Pinia + Naive UI + Leaflet      │
├──────────────┬────────────────────────────┬────────────────┤
│  Axios HTTP  │    Socket.IO WebSocket     │   Leaflet Map  │
├──────────────┴────────────────────────────┴────────────────┤
│                      Vite 开发服务器                       │
│                http://localhost:5173 (代理API)              │
└────────────────────────────┬──────────────────────────────┘
                             │ JSON
┌────────────────────────────▼──────────────────────────────┐
│                   Express.js 后端服务                      │
│              http://localhost:3000/api/*                    │
├───────────────────────────────────────────────────────────┤
│  认证中间件 (JWT)  │  路由层  │  控制器层  │  服务层       │
├───────────────────────────────────────────────────────────┤
│  Sequelize ORM  │  Socket.IO Server  │  node-cron 定时任务 │
├─────────────────┴────────────────────┴────────────────────┤
│                       MySQL 数据库                         │
│             18 张核心表 + 关联关系                          │
└───────────────────────────────────────────────────────────┘
```

### 前后端数据交互流程

1. **HTTP 请求**：前端通过 Axios 发送 RESTful API 请求，后端返回统一 JSON 格式 `{ code, msg, data }`
2. **身份认证**：登录后获取 JWT Token，存储在 localStorage，Axios 拦截器自动注入 `Authorization: Bearer <token>`
3. **实时通信**：聊天模块通过 Socket.IO 建立 WebSocket 长连接，支持消息实时推送
4. **文件上传**：头像、图片通过 Multer 中间件处理，以 FormData 格式提交

---

## 🗄️ 数据库设计

系统使用 MySQL 关系型数据库，核心数据表包括：

| 表名 | 说明 | 核心字段 |
|------|------|---------|
| `users` | 用户表 | id, username, password, nickname, avatar, role, level |
| `routes` | 线路表 | id, title, difficulty, distance_km, region, creator_id |
| `route_points` | 线路坐标点 | route_id, lat, lng, elevation, seq |
| `activities` | 活动表 | id, title, route_id, organizer_id, status, max_members |
| `activity_members` | 活动成员 | activity_id, user_id, status, role |
| `chat_rooms` | 聊天室 | id, name, type(1私信/2群聊), activity_id |
| `chat_messages` | 聊天消息 | id, room_id, sender_id, content, type(1文字/2图片) |
| `comments` | 评论表 | id, target_type, target_id, user_id, content, images, rating |
| `comment_likes` | 评论点赞 | user_id, comment_id |
| `favorites` | 收藏表 | user_id, target_type, target_id |
| `checkins` | 打卡记录 | id, user_id, content, images, distance |
| `user_follows` | 关注关系 | follower_id, following_id |
| `user_skills` | 用户技能关联 | user_id, tag_id |
| `skill_tags` | 技能标签 | id, name |
| `ai_sessions` | AI对话会话 | id, user_id, session_type, messages |
| `match_pool` | 随机组队匹配池 | id, user_id, route_id, prefer_date, status |
| `activity_reviews` | 活动互评 | id, activity_id, reviewer_id, reviewee_id, rating, content |

---

## 🚀 功能模块

### 1. 用户系统
- 注册/登录（JWT 认证）
- 个人信息管理（头像上传、个人简介）
- 技能标签设置
- 关注/粉丝社交关系
- 角色权限（普通用户/管理员）

### 2. 线路模块
- 线路浏览（分页、难度筛选、关键字搜索）
- 线路详情（Leaflet 地图展示 GPS 轨迹）
- 创建/编辑线路（支持 GPX 文件上传解析）
- AI 智能线路推荐（基于用户画像）
- 线路收藏与评论
- 线路分享（Web Share API / 链接复制）
- 安全提示与装备信息醒目警告展示

### 3. 活动模块
- 发布徒步活动（关联线路、安全信息必填）
- 报名申请 + 组织者审批
- 活动状态自动更新（招募中→已满→已结束）
- 审批通过自动进入活动群聊
- 活动结束后参与者互评（评分 + 评语）
- 我的活动列表

### 4. 实时聊天
- 私信聊天 + 活动群聊
- 基于 Socket.IO 的 WebSocket 双向实时通信
- 支持文字和图片消息
- 未读消息计数
- 会话删除管理
- 智能显示会话名称（私聊显示对方昵称、群聊显示活动标题）
- 聊天记录分页加载

### 5. AI 智能助手
- 基于 DeepSeek 大语言模型
- 三种对话场景：线路规划、组队匹配、通用问答
- 上下文多轮对话记忆
- 结合系统数据库实时数据回答

### 6. 随机组队
- 加入匹配池（可设置线路偏好、等级范围）
- node-cron 定时任务每5分钟自动匹配
- 匹配成功自动创建活动和群聊

### 7. 打卡系统
- 创建打卡记录（支持多图上传）
- 日历视图统计
- 打卡详情展示

### 8. 后台管理
- 管理员统计面板
- 用户管理（角色分配）
- 线路内容审核
- 评论管理

### 10. 评论系统
- 支持线路和活动的多目标评论
- 评论图片上传（最多3张）
- 评分星级（线路评价）
- 评论点赞/取消点赞
- 评论回复

### 11. 用户评价
- 活动结束后成员互评
- 用户主页「收到的评价」展示
- 平均评分统计

### 9. RESTful API 文档
- 后端自渲染 HTML 文档页
- 覆盖 11 个模块 50+ 个接口
- 访问地址：`http://localhost:3000/api/docs`

---

## 📦 新服务器部署指南

### 环境要求

| 软件 | 版本要求 | 说明 |
|------|---------|------|
| **Node.js** | >= 18.x | JavaScript 运行环境 |
| **npm** | >= 9.x | 包管理工具（随 Node.js 安装） |
| **MySQL** | >= 8.0 | 关系型数据库 |
| **Git** | 任意版本 | 用于拉取代码（可选） |

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

# 3. 导入表结构
mysql -u root -p trekhub < database/init.sql

# 4. 导入测试数据（可选，含示例用户和线路）
mysql -u root -p trekhub < database/seed.sql
```

### 第三步：配置后端环境变量

```bash
cd backend

# 1. 复制配置模板
cp .env.example .env

# 2. 编辑 .env 文件，修改以下配置为你的实际值：
```

`.env` 需要修改的关键配置：

| 变量 | 说明 | 示例值 |
|------|------|--------|
| `DB_HOST` | 数据库地址 | `localhost` |
| `DB_PORT` | 数据库端口 | `3306` |
| `DB_NAME` | 数据库名 | `trekhub` |
| `DB_USER` | 数据库用户名 | `root` |
| `DB_PASS` | 数据库密码 | `你的密码` |
| `JWT_SECRET` | JWT 签名密钥（随便写一串） | `my-secret-key-2026` |
| `DEEPSEEK_API_KEY` | DeepSeek AI 的 API Key | 从 [DeepSeek 官网](https://platform.deepseek.com/) 获取 |
| `AMAP_KEY` | 高德地图 Web 服务 Key | 从 [高德开放平台](https://console.amap.com/) 获取 |

### 第四步：安装依赖并启动后端

```bash
cd backend

# 安装后端依赖
npm install

# 启动后端服务
node server.js
# 看到 "✅ 数据库连接成功" 和 "🚀 TrekHub 后端启动 http://localhost:3000" 即为成功
```

### 第五步：配置并启动前端

```bash
cd frontend

# 1. 安装前端依赖
npm install

# 2. 如果后端不在 localhost:3000，编辑 .env 文件修改后端地址
#    VITE_API_BASE_URL=http://你的后端IP:3000

# 3. 启动前端开发服务器
npm run dev
# 前端运行在 http://localhost:5173
```

### 一键启动（Windows）

```bash
# 直接双击根目录下的批处理脚本，自动启动前后端
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
| 管理员 | `admin` | `admin123` |
| 普通用户 | `user1` | `123456` |

### 常见问题

| 问题 | 解决方案 |
|------|---------|
| `数据库连接失败` | 检查 `.env` 中的数据库配置是否正确，MySQL 服务是否启动 |
| `端口被占用` | 修改 `.env` 中的 `PORT`，或关闭占用端口的程序 |
| `npm install 失败` | 尝试删除 `node_modules` 后重新安装，或检查网络/换源 `npm config set registry https://registry.npmmirror.com` |
| `AI 功能无法使用` | 检查 `.env` 中的 `DEEPSEEK_API_KEY` 是否正确配置 |
| `地图不显示` | 检查前端 `.env` 中的 `VITE_AMAP_KEY` 和 `VITE_AMAP_SECURITY_CODE` 是否配置 |

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

## 📄 License

本项目为毕业设计作品，仅供学习和答辩展示使用。
