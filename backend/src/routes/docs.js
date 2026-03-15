/** API文档路由 - 自动生成可视化的RESTful API文档页面 */
const express = require('express')
const router = express.Router()

const API_MODULES = [
  {
    name: '认证模块', prefix: '/api/auth', icon: '🔐',
    desc: '用户注册与登录，返回 JWT Token 用于后续请求认证',
    endpoints: [
      {
        m: 'POST', p: '/register', auth: '无', desc: '用户注册',
        body: [
          { field: 'username', type: 'String', required: true, desc: '用户名，唯一' },
          { field: 'password', type: 'String', required: true, desc: '密码，至少6位' },
          { field: 'nickname', type: 'String', required: true, desc: '昵称' }
        ],
        res: [
          { field: 'token', type: 'String', desc: 'JWT认证令牌' },
          { field: 'user', type: 'Object', desc: '{ id, username, nickname, role }' }
        ]
      },
      {
        m: 'POST', p: '/login', auth: '无', desc: '用户登录',
        body: [
          { field: 'username', type: 'String', required: true, desc: '用户名' },
          { field: 'password', type: 'String', required: true, desc: '密码' }
        ],
        res: [
          { field: 'token', type: 'String', desc: 'JWT认证令牌' },
          { field: 'user', type: 'Object', desc: '{ id, username, nickname, avatar, role }' }
        ]
      }
    ]
  },
  {
    name: '用户模块', prefix: '/api/users', icon: '👤',
    desc: '用户信息管理、技能标签系统与社交关注功能',
    endpoints: [
      { m: 'GET', p: '/skill-tags', auth: '无', desc: '获取所有技能标签',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, name }] 标签列表' }] },
      { m: 'GET', p: '/me/profile', auth: 'Token', desc: '获取当前登录用户信息',
        res: [
          { field: 'id', type: 'Number', desc: '用户ID' },
          { field: 'nickname', type: 'String', desc: '昵称' },
          { field: 'avatar', type: 'String', desc: '头像URL' },
          { field: 'bio', type: 'String', desc: '个人简介' },
          { field: 'gender', type: 'Number', desc: '0未知 1男 2女' },
          { field: 'level', type: 'Number', desc: '徒步等级 1-5' },
          { field: 'role', type: 'Number', desc: '0普通用户 1管理员' }
        ] },
      { m: 'PUT', p: '/me/profile', auth: 'Token', desc: '更新个人信息（支持头像上传）',
        body: [
          { field: 'nickname', type: 'String', required: false, desc: '昵称' },
          { field: 'bio', type: 'String', required: false, desc: '个人简介' },
          { field: 'gender', type: 'Number', required: false, desc: '性别' },
          { field: 'avatar', type: 'File', required: false, desc: '头像图片文件' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '更新后的用户对象' }] },
      { m: 'PUT', p: '/me/password', auth: 'Token', desc: '修改密码',
        body: [
          { field: 'oldPassword', type: 'String', required: true, desc: '原密码' },
          { field: 'newPassword', type: 'String', required: true, desc: '新密码' }
        ],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'PUT', p: '/me/skills', auth: 'Token', desc: '更新技能标签',
        body: [{ field: 'skills', type: 'Array<Number>', required: true, desc: '技能标签ID数组' }],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'GET', p: '/:id/profile', auth: '无', desc: '获取指定用户公开信息',
        res: [{ field: 'data', type: 'Object', desc: '{ id, nickname, avatar, bio, level, gender }' }] },
      { m: 'GET', p: '/:id/skills', auth: '无', desc: '获取用户技能标签',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, name }]' }] },
      { m: 'POST', p: '/:id/follow', auth: 'Token', desc: '关注或取消关注用户',
        res: [{ field: 'followed', type: 'Boolean', desc: 'true=已关注 false=已取消' }] },
      { m: 'GET', p: '/:id/follow-info', auth: '可选', desc: '获取关注统计',
        res: [
          { field: 'followerCount', type: 'Number', desc: '粉丝数' },
          { field: 'followingCount', type: 'Number', desc: '关注数' },
          { field: 'isFollowed', type: 'Boolean', desc: '当前用户是否关注了ta' }
        ] },
      { m: 'GET', p: '/:id/followers', auth: '无', desc: '获取粉丝列表',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, nickname, avatar, level }]' }] },
      { m: 'GET', p: '/:id/following', auth: '无', desc: '获取关注列表',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, nickname, avatar, level }]' }] }
    ]
  },
  {
    name: '线路模块', prefix: '/api/routes', icon: '🗺️',
    desc: '徒步线路的浏览、创建、GPX上传与AI智能推荐',
    endpoints: [
      { m: 'GET', p: '/', auth: '无', desc: '线路列表（分页+筛选）',
        query: [
          { field: 'page', type: 'Number', desc: '页码，默认1' },
          { field: 'pageSize', type: 'Number', desc: '每页条数，默认10' },
          { field: 'difficulty', type: 'Number', desc: '难度筛选 1-5' },
          { field: 'region', type: 'String', desc: '地区筛选' },
          { field: 'keyword', type: 'String', desc: '关键字搜索' }
        ],
        res: [
          { field: 'list', type: 'Array', desc: '线路列表 [{ id, title, difficulty, distance_km, cover_image, creator }]' },
          { field: 'total', type: 'Number', desc: '总数' },
          { field: 'page', type: 'Number', desc: '当前页' }
        ] },
      { m: 'GET', p: '/:id', auth: '无', desc: '线路详情（含坐标点和创建者）',
        res: [
          { field: 'id', type: 'Number', desc: '线路ID' },
          { field: 'title', type: 'String', desc: '标题' },
          { field: 'difficulty', type: 'Number', desc: '难度 1-5' },
          { field: 'distance_km', type: 'Number', desc: '距离(km)' },
          { field: 'duration_h', type: 'Number', desc: '预计时长(h)' },
          { field: 'region', type: 'String', desc: '地区' },
          { field: 'elevation_gain', type: 'Number', desc: '累计爬升(m)' },
          { field: 'points', type: 'Array', desc: '[{ lat, lng, elevation, seq }] 坐标序列' },
          { field: 'creator', type: 'Object', desc: '{ id, nickname, avatar }' }
        ] },
      { m: 'POST', p: '/', auth: 'Token', desc: '创建线路',
        body: [
          { field: 'title', type: 'String', required: true, desc: '线路标题' },
          { field: 'difficulty', type: 'Number', required: true, desc: '难度 1-5' },
          { field: 'region', type: 'String', required: false, desc: '地区' },
          { field: 'distance_km', type: 'Number', required: false, desc: '距离' },
          { field: 'duration_h', type: 'Number', required: false, desc: '时长' },
          { field: 'cover_image', type: 'File', required: false, desc: '封面图片' },
          { field: 'points', type: 'JSON', required: false, desc: '坐标点数组' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '创建的线路对象' }] },
      { m: 'PUT', p: '/:id', auth: 'Token', desc: '更新线路信息',
        body: [
          { field: 'title', type: 'String', required: false, desc: '标题' },
          { field: 'difficulty', type: 'Number', required: false, desc: '难度' },
          { field: 'region', type: 'String', required: false, desc: '地区' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '更新后的线路对象' }] },
      { m: 'DELETE', p: '/:id', auth: 'Token', desc: '删除线路',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'POST', p: '/gpx/upload', auth: 'Token', desc: '上传GPX文件并解析坐标',
        body: [{ field: 'gpx', type: 'File', required: true, desc: 'GPX轨迹文件' }],
        res: [
          { field: 'gpxPath', type: 'String', desc: '文件存储路径' },
          { field: 'points', type: 'Array', desc: '解析出的坐标点' }
        ] },
      { m: 'GET', p: '/me/recommended', auth: 'Token', desc: 'AI智能线路推荐（基于用户画像）',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, reason }] 推荐线路及理由' }] }
    ]
  },
  {
    name: '活动模块', prefix: '/api/activities', icon: '🏕️',
    desc: '基于线路发布徒步活动，支持报名申请与组织者审批',
    endpoints: [
      { m: 'GET', p: '/', auth: '无', desc: '活动列表',
        query: [
          { field: 'page', type: 'Number', desc: '页码' },
          { field: 'pageSize', type: 'Number', desc: '每页条数' }
        ],
        res: [
          { field: 'list', type: 'Array', desc: '活动列表 [{ id, title, start_time, current_members, max_members }]' },
          { field: 'total', type: 'Number', desc: '总数' }
        ] },
      { m: 'GET', p: '/:id', auth: '无', desc: '活动详情（含成员列表和关联线路）',
        res: [
          { field: 'id', type: 'Number', desc: '活动ID' },
          { field: 'title', type: 'String', desc: '活动标题' },
          { field: 'start_time', type: 'Date', desc: '开始时间' },
          { field: 'end_time', type: 'Date', desc: '结束时间' },
          { field: 'max_members', type: 'Number', desc: '最大人数' },
          { field: 'current_members', type: 'Number', desc: '当前人数' },
          { field: 'safety_info', type: 'String', desc: '安全提示' },
          { field: 'gear_require', type: 'String', desc: '必备装备' },
          { field: 'route', type: 'Object', desc: '关联线路 { id, title }' },
          { field: 'organizer', type: 'Object', desc: '组织者 { id, nickname, avatar }' },
          { field: 'members', type: 'Array', desc: '成员 [{ id, user, status, role }]' }
        ] },
      { m: 'POST', p: '/', auth: 'Token', desc: '发布活动',
        body: [
          { field: 'title', type: 'String', required: true, desc: '活动标题' },
          { field: 'route_id', type: 'Number', required: true, desc: '关联线路ID' },
          { field: 'start_time', type: 'Date', required: true, desc: '开始时间' },
          { field: 'end_time', type: 'Date', required: true, desc: '结束时间' },
          { field: 'max_members', type: 'Number', required: true, desc: '最大人数' },
          { field: 'min_level', type: 'Number', required: false, desc: '最低等级要求' },
          { field: 'safety_info', type: 'String', required: false, desc: '安全提示' },
          { field: 'gear_require', type: 'String', required: false, desc: '必备装备' },
          { field: 'description', type: 'String', required: false, desc: '活动描述' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '创建的活动对象' }] },
      { m: 'POST', p: '/:id/apply', auth: 'Token', desc: '申请加入活动',
        body: [{ field: 'apply_msg', type: 'String', required: false, desc: '申请留言' }],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'POST', p: '/review-member', auth: 'Token', desc: '审批成员申请（仅组织者）',
        body: [
          { field: 'memberId', type: 'Number', required: true, desc: '成员记录ID' },
          { field: 'action', type: 'String', required: true, desc: '"approve" 通过 | "reject" 拒绝' }
        ],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'GET', p: '/me/list', auth: 'Token', desc: '我参加的活动列表',
        res: [{ field: 'data', type: 'Array', desc: '活动列表' }] }
    ]
  },
  {
    name: '实时聊天模块', prefix: '/api/chat', icon: '💬',
    desc: '聊天室管理（HTTP）+ 消息收发（WebSocket / Socket.IO）',
    endpoints: [
      { m: 'GET', p: '/rooms', auth: 'Token', desc: '获取我的聊天室列表',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, name, type(1私信/2群聊), last_msg, unread }]' }] },
      { m: 'POST', p: '/rooms/private', auth: 'Token', desc: '创建或获取私信聊天室',
        body: [{ field: 'targetUserId', type: 'Number', required: true, desc: '对方用户ID' }],
        res: [{ field: 'roomId', type: 'Number', desc: '聊天室ID' }] },
      { m: 'GET', p: '/rooms/:id/messages', auth: 'Token', desc: '获取聊天记录（支持分页）',
        query: [{ field: 'before', type: 'Number', desc: '加载此ID之前的消息' }],
        res: [{ field: 'data', type: 'Array', desc: '[{ id, content, type(1文字/2图片), sender, createdAt }]' }] },
      { m: 'GET', p: '/rooms/:id/members', auth: 'Token', desc: '获取聊天室成员列表',
        res: [{ field: 'data', type: 'Array', desc: '[{ id, nickname, avatar }]' }] }
    ],
    websocket: [
      { event: 'chat:join', dir: '→ 发送', desc: '加入聊天室', payload: '{ roomId }' },
      { event: 'chat:send', dir: '→ 发送', desc: '发送消息', payload: '{ roomId, content, type(1文字/2图片) }' },
      { event: 'chat:message', dir: '← 接收', desc: '收到新消息', payload: '{ id, content, type, sender: { id, nickname, avatar }, roomId, createdAt }' },
      { event: 'chat:read', dir: '→ 发送', desc: '标记聊天室已读', payload: '{ roomId }' },
      { event: 'chat:leave', dir: '→ 发送', desc: '离开聊天室', payload: '{ roomId }' }
    ]
  },
  {
    name: '评论模块', prefix: '/api/comments', icon: '📝',
    desc: '线路和活动的评论系统，支持回复与点赞',
    endpoints: [
      { m: 'GET', p: '/', auth: '无', desc: '获取评论列表',
        query: [
          { field: 'target_type', type: 'Number', desc: '1=线路 2=活动' },
          { field: 'target_id', type: 'Number', desc: '目标ID' }
        ],
        res: [{ field: 'data', type: 'Array', desc: '[{ id, content, user, replies, likes, createdAt }]' }] },
      { m: 'POST', p: '/', auth: 'Token', desc: '发表评论或回复',
        body: [
          { field: 'target_type', type: 'Number', required: true, desc: '1=线路 2=活动' },
          { field: 'target_id', type: 'Number', required: true, desc: '目标ID' },
          { field: 'content', type: 'String', required: true, desc: '评论内容' },
          { field: 'parent_id', type: 'Number', required: false, desc: '父评论ID（回复时填）' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '创建的评论对象' }] },
      { m: 'DELETE', p: '/:id', auth: 'Token', desc: '删除评论（仅作者）',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'POST', p: '/:id/like', auth: 'Token', desc: '点赞或取消点赞',
        res: [{ field: 'liked', type: 'Boolean', desc: 'true=已点赞 false=已取消' }] }
    ]
  },
  {
    name: '收藏模块', prefix: '/api/favorites', icon: '❤️',
    desc: '线路收藏功能',
    endpoints: [
      { m: 'POST', p: '/toggle', auth: 'Token', desc: '收藏或取消收藏',
        body: [{ field: 'route_id', type: 'Number', required: true, desc: '线路ID' }],
        res: [{ field: 'favorited', type: 'Boolean', desc: 'true=已收藏 false=已取消' }] },
      { m: 'GET', p: '/list', auth: 'Token', desc: '我的收藏列表',
        res: [{ field: 'data', type: 'Array', desc: '收藏的线路列表' }] },
      { m: 'GET', p: '/check', auth: 'Token', desc: '检查是否已收藏',
        query: [{ field: 'route_id', type: 'Number', desc: '线路ID' }],
        res: [{ field: 'favorited', type: 'Boolean', desc: '是否已收藏' }] }
    ]
  },
  {
    name: '打卡模块', prefix: '/api/checkins', icon: '📍',
    desc: '徒步打卡记录，支持图片上传与日历统计',
    endpoints: [
      { m: 'GET', p: '/', auth: 'Token', desc: '打卡记录列表',
        query: [
          { field: 'page', type: 'Number', desc: '页码' },
          { field: 'pageSize', type: 'Number', desc: '每页条数' }
        ],
        res: [{ field: 'list', type: 'Array', desc: '[{ id, content, images, distance, createdAt }]' }, { field: 'total', type: 'Number', desc: '总数' }] },
      { m: 'GET', p: '/calendar', auth: 'Token', desc: '日历打卡统计',
        query: [{ field: 'month', type: 'String', desc: '月份，如 2026-03' }],
        res: [{ field: 'data', type: 'Array', desc: '[{ date, count }]' }] },
      { m: 'GET', p: '/:id', auth: '无', desc: '打卡详情',
        res: [{ field: 'data', type: 'Object', desc: '{ id, content, images, distance, user, createdAt }' }] },
      { m: 'POST', p: '/', auth: 'Token', desc: '创建打卡（支持多图上传）',
        body: [
          { field: 'content', type: 'String', required: true, desc: '打卡内容' },
          { field: 'route_id', type: 'Number', required: false, desc: '关联线路ID' },
          { field: 'distance', type: 'Number', required: false, desc: '距离(km)' },
          { field: 'images', type: 'File[]', required: false, desc: '图片，最多9张' }
        ],
        res: [{ field: 'data', type: 'Object', desc: '创建的打卡对象' }] }
    ]
  },
  {
    name: 'AI助手模块', prefix: '/api/ai', icon: '🤖',
    desc: '基于 DeepSeek 大模型的多场景 AI 对话助手',
    endpoints: [
      { m: 'POST', p: '/chat', auth: 'Token', desc: 'AI对话（带上下文记忆）',
        body: [
          { field: 'message', type: 'String', required: true, desc: '用户消息' },
          { field: 'sessionType', type: 'String', required: false, desc: '"route_plan" | "team_match" | "general"' }
        ],
        res: [{ field: 'reply', type: 'String', desc: 'AI回复内容' }] },
      { m: 'DELETE', p: '/session/:type', auth: 'Token', desc: '清除指定类型对话历史',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] }
    ]
  },
  {
    name: '随机组队模块', prefix: '/api/match', icon: '🎲',
    desc: '随机匹配组队池，系统每5分钟自动匹配兼容用户',
    endpoints: [
      { m: 'POST', p: '/join', auth: 'Token', desc: '加入匹配池',
        body: [
          { field: 'route_id', type: 'Number', required: false, desc: '意向线路ID' },
          { field: 'prefer_date', type: 'String', required: false, desc: '偏好日期 YYYY-MM-DD' },
          { field: 'min_level', type: 'Number', required: false, desc: '最低等级 1-5' },
          { field: 'max_level', type: 'Number', required: false, desc: '最高等级 1-5' },
          { field: 'skill_tags', type: 'Array', required: false, desc: '技能偏好标签' }
        ],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'DELETE', p: '/leave', auth: 'Token', desc: '退出匹配池',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'GET', p: '/status', auth: 'Token', desc: '查询匹配状态',
        res: [
          { field: 'inPool', type: 'Boolean', desc: '是否在匹配池中' },
          { field: 'poolCount', type: 'Number', desc: '当前匹配池人数' }
        ] }
    ]
  },
  {
    name: '管理员模块', prefix: '/api/admin', icon: '🛡️',
    desc: '后台管理接口（需要管理员角色 role=1）',
    endpoints: [
      { m: 'GET', p: '/public-stats', auth: '无', desc: '公开统计数据（首页展示）',
        res: [
          { field: 'userCount', type: 'Number', desc: '注册用户数' },
          { field: 'routeCount', type: 'Number', desc: '线路数' },
          { field: 'activityCount', type: 'Number', desc: '活动数' },
          { field: 'checkinCount', type: 'Number', desc: '打卡数' }
        ] },
      { m: 'GET', p: '/stats', auth: 'Admin', desc: '管理员统计面板',
        res: [{ field: 'data', type: 'Object', desc: '{ users, routes, comments, activities } 各项统计' }] },
      { m: 'GET', p: '/users', auth: 'Admin', desc: '用户管理列表',
        query: [{ field: 'page', type: 'Number', desc: '页码' }, { field: 'keyword', type: 'String', desc: '搜索关键字' }],
        res: [{ field: 'list', type: 'Array', desc: '用户列表' }, { field: 'total', type: 'Number', desc: '总数' }] },
      { m: 'PUT', p: '/users/:id/role', auth: 'Admin', desc: '修改用户角色',
        body: [{ field: 'role', type: 'Number', required: true, desc: '0=普通用户 1=管理员' }],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'PUT', p: '/users/:id', auth: 'Admin', desc: '编辑用户信息',
        body: [
          { field: 'nickname', type: 'String', required: false, desc: '昵称' },
          { field: 'bio', type: 'String', required: false, desc: '简介' },
          { field: 'level', type: 'Number', required: false, desc: '等级' }
        ],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'GET', p: '/routes', auth: 'Admin', desc: '线路管理列表',
        query: [{ field: 'page', type: 'Number', desc: '页码' }, { field: 'keyword', type: 'String', desc: '搜索' }],
        res: [{ field: 'list', type: 'Array', desc: '线路列表' }, { field: 'total', type: 'Number', desc: '总数' }] },
      { m: 'PUT', p: '/routes/:id', auth: 'Admin', desc: '编辑线路',
        body: [{ field: 'title', type: 'String', required: false, desc: '标题' }, { field: 'difficulty', type: 'Number', required: false, desc: '难度' }],
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'DELETE', p: '/routes/:id', auth: 'Admin', desc: '删除线路',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] },
      { m: 'GET', p: '/comments', auth: 'Admin', desc: '评论管理列表',
        res: [{ field: 'list', type: 'Array', desc: '评论列表' }, { field: 'total', type: 'Number', desc: '总数' }] },
      { m: 'DELETE', p: '/comments/:id', auth: 'Admin', desc: '删除评论',
        res: [{ field: 'data', type: 'null', desc: '无返回数据' }] }
    ]
  }
]

const totalEndpoints = API_MODULES.reduce((s, m) => s + m.endpoints.length + (m.websocket?.length || 0), 0)

function mc(m) {
  const c = { GET: ['#2e7d32','#e8f5e9'], POST: ['#1565c0','#e3f2fd'], PUT: ['#e65100','#fff3e0'], DELETE: ['#c62828','#fce4ec'] }
  return c[m] || ['#333','#eee']
}
function ac(a) {
  if (a === '无' || a === '可选') return ['#2e7d32','#e8f5e9']
  if (a === 'Admin') return ['#c62828','#fce4ec']
  return ['#1565c0','#e3f2fd']
}

function renderFields(fields, title) {
  if (!fields || !fields.length) return `<span style="color:#ccc">—</span>`
  let html = `<div class="field-box"><div class="field-title">${title}</div>`
  for (const f of fields) {
    const req = f.required ? '<span style="color:#e53935;font-size:12px;margin-left:4px">必填</span>' : ''
    html += `<div class="field-row">
      <code class="field-name">${f.field || f.event}</code>
      <span class="field-type">${f.type || ''}</span>${req}
      <span class="field-desc">${f.desc}</span>
    </div>`
  }
  return html + '</div>'
}

router.get('/', (req, res) => {
  let modulesHtml = ''
  for (const mod of API_MODULES) {
    let rows = ''
    for (const ep of mod.endpoints) {
      const [mClr, mBg] = mc(ep.m)
      const [aClr, aBg] = ac(ep.auth)
      const paramsHtml = ep.query ? renderFields(ep.query, '📥 Query 参数') : ep.body ? renderFields(ep.body, '📥 请求参数') : '<span style="color:#ccc">—</span>'
      const resHtml = renderFields(ep.res, '📤 响应数据')
      rows += `<tr>
        <td><span style="color:${mClr};background:${mBg};padding:4px 12px;border-radius:4px;font-size:13px;font-weight:700;display:inline-block">${ep.m}</span></td>
        <td><code style="color:#1e3a5f;font-size:14px;font-weight:600">${mod.prefix}${ep.p}</code></td>
        <td style="font-weight:500">${ep.desc}</td>
        <td><span style="color:${aClr};background:${aBg};padding:3px 10px;border-radius:4px;font-size:13px;display:inline-block">${ep.auth}</span></td>
      </tr>
      <tr class="detail-row">
        <td colspan="2">${paramsHtml}</td>
        <td colspan="2">${resHtml}</td>
      </tr>`
    }

    let wsHtml = ''
    if (mod.websocket?.length) {
      let wsRows = ''
      for (const ws of mod.websocket) {
        const dirClr = ws.dir.includes('→') ? '#1565c0' : '#2e7d32'
        wsRows += `<tr>
          <td><code style="color:#7c3aed;font-size:14px;font-weight:600">${ws.event}</code></td>
          <td><span style="color:${dirClr};font-size:13px;font-weight:600;white-space:nowrap">${ws.dir}</span></td>
          <td>${ws.desc}</td>
          <td><code style="font-size:13px;color:#555;background:#f5f5f5;padding:3px 8px;border-radius:3px">${ws.payload}</code></td>
        </tr>`
      }
      wsHtml = `<div style="padding:12px 20px 16px">
        <h4 style="font-size:15px;color:#7c3aed;margin:0 0 8px;font-weight:700">🔌 WebSocket 事件 (Socket.IO)</h4>
        <table class="api-table"><thead><tr><th style="width:160px">事件名</th><th style="width:90px">方向</th><th>描述</th><th>数据格式</th></tr></thead><tbody>${wsRows}</tbody></table>
      </div>`
    }

    modulesHtml += `<div class="module-card">
      <div class="module-header">
        <div><h3>${mod.icon} ${mod.name}</h3><span class="module-desc">${mod.desc}</span></div>
        <code class="module-prefix">${mod.prefix}</code>
      </div>
      <table class="api-table"><thead><tr>
        <th style="width:80px">方法</th><th style="width:240px">路径</th><th>描述</th><th style="width:80px">认证</th>
      </tr></thead><tbody>${rows}</tbody></table>
      ${wsHtml}
    </div>`
  }

  res.type('html').send(`<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>TrekHub RESTful API 文档</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;background:#f0f2f5;color:#333;line-height:1.7;font-size:15px}
.container{max-width:1200px;margin:0 auto;padding:28px 20px}
.banner{background:linear-gradient(135deg,#1e3a5f 0%,#2d8cf0 100%);color:#fff;padding:40px 36px;border-radius:16px;margin-bottom:24px;display:flex;justify-content:space-between;align-items:center}
.banner h1{font-size:32px;font-weight:800}
.banner p{margin:8px 0 0;opacity:.85;font-size:16px}
.banner-stats{display:flex;gap:16px}
.stat-pill{background:rgba(255,255,255,.15);backdrop-filter:blur(4px);border-radius:12px;padding:14px 22px;text-align:center}
.stat-pill .num{font-size:28px;font-weight:800;display:block;line-height:1.1}
.stat-pill .lbl{font-size:13px;opacity:.8}
.info-card{background:#fff;border:1px solid #e8e8e8;border-radius:12px;padding:18px 24px;margin-bottom:24px;display:flex;flex-wrap:wrap;gap:24px}
.info-item{font-size:15px;display:flex;align-items:center;gap:8px}
.info-label{font-weight:700;color:#555}
.info-item code{background:#eef4ff;padding:4px 12px;border-radius:6px;font-size:14px;color:#1e3a5f}
.module-card{background:#fff;border:1px solid #e8e8e8;border-radius:12px;margin-bottom:24px;overflow:hidden}
.module-header{padding:18px 24px;background:linear-gradient(to right,#f8f9fb,#fff);border-bottom:1px solid #eee;display:flex;align-items:center;justify-content:space-between}
.module-header h3{font-size:18px;font-weight:700;margin:0}
.module-desc{font-size:14px;color:#888;display:block;margin-top:3px}
.module-prefix{font-size:14px;color:#2d8cf0;background:#eef4ff;padding:5px 14px;border-radius:6px;font-weight:600}
.api-table{width:100%;border-collapse:collapse;font-size:15px}
.api-table th{background:#fafbfc;text-align:left;padding:12px 16px;font-weight:700;color:#555;border-bottom:2px solid #eee;font-size:13px;text-transform:uppercase;letter-spacing:.3px}
.api-table td{padding:12px 16px;border-bottom:1px solid #f0f0f0;vertical-align:top}
.api-table tr:hover>td{background:#fafbfc}
.detail-row>td{padding:10px 16px 16px;border-bottom:2px solid #eee;background:#fafbfc}
.field-box{border:1px solid #e8ecf0;border-radius:8px;padding:12px 14px;background:#fff}
.field-title{font-size:12px;font-weight:700;color:#888;margin-bottom:8px;text-transform:uppercase;letter-spacing:.3px}
.field-row{display:flex;align-items:baseline;gap:10px;padding:5px 0;border-bottom:1px dashed #f0f0f0;font-size:14px}
.field-row:last-child{border-bottom:none}
.field-name{color:#1e3a5f;font-weight:600;min-width:120px;font-size:14px}
.field-type{color:#7c3aed;font-size:13px;font-weight:600;min-width:70px}
.field-desc{color:#555;flex:1}
.footer{text-align:center;color:#bbb;font-size:14px;padding:28px 0}
</style>
</head>
<body>
<div class="container">
  <div class="banner">
    <div>
      <h1>📡 TrekHub RESTful API 文档</h1>
      <p>基于 Express.js 的前后端分离架构 · JWT 认证 · JSON 数据交互 · Socket.IO 实时通信</p>
    </div>
    <div class="banner-stats">
      <div class="stat-pill"><span class="num">${totalEndpoints}</span><span class="lbl">接口总数</span></div>
      <div class="stat-pill"><span class="num">${API_MODULES.length}</span><span class="lbl">功能模块</span></div>
    </div>
  </div>
  <div class="info-card">
    <div class="info-item"><span class="info-label">Base URL</span><code>http://localhost:3000/api</code></div>
    <div class="info-item"><span class="info-label">认证方式</span><code>Bearer Token (JWT)</code></div>
    <div class="info-item"><span class="info-label">请求头</span><code>Authorization: Bearer &lt;token&gt;</code></div>
    <div class="info-item"><span class="info-label">统一响应</span><code>{ code: 200, msg: "ok", data: ... }</code></div>
    <div class="info-item"><span class="info-label">错误响应</span><code>{ code: 400/401/500, msg: "错误描述", data: null }</code></div>
  </div>
  ${modulesHtml}
  <div class="footer">TrekHub — 基于Vue.js的徒步旅行线路规划与同伴组队平台 · RESTful API v1.0.0</div>
</div>
</body>
</html>`)
})

module.exports = router
