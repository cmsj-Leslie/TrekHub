/**
 * 数据模型关联关系定义
 * 功能：导入所有 Sequelize 模型，定义表之间的外键关联
 */
const sequelize = require('../config/db')
const User = require('./User')
const Route = require('./Route')
const RoutePoint = require('./RoutePoint')
const Activity = require('./Activity')
const ActivityMember = require('./ActivityMember')
const ChatRoom = require('./ChatRoom')
const Message = require('./Message')
const Comment = require('./Comment')
const Favorite = require('./Favorite')
const Checkin = require('./Checkin')
const AiSession = require('./AiSession')
const MatchPool = require('./MatchPool')

// ===== 关联关系定义 =====

// 用户 → 线路（一对多：用户可以创建多条线路）
User.hasMany(Route, { foreignKey: 'creator_id', as: 'routes' })
Route.belongsTo(User, { foreignKey: 'creator_id', as: 'creator' })

// 线路 → 坐标点（一对多：每条线路包含多个 GPS 坐标点）
Route.hasMany(RoutePoint, { foreignKey: 'route_id', as: 'points' })
RoutePoint.belongsTo(Route, { foreignKey: 'route_id' })

// 线路 → 活动（一对多：一条线路可以关联多个活动）
Route.hasMany(Activity, { foreignKey: 'route_id', as: 'activities' })
Activity.belongsTo(Route, { foreignKey: 'route_id', as: 'route' })

// 用户 → 活动（一对多：用户作为组织者可以创建多个活动）
User.hasMany(Activity, { foreignKey: 'organizer_id', as: 'organized' })
Activity.belongsTo(User, { foreignKey: 'organizer_id', as: 'organizer' })

// 活动 ↔ 成员（多对多：通过 activity_members 中间表）
Activity.hasMany(ActivityMember, { foreignKey: 'activity_id', as: 'members' })
ActivityMember.belongsTo(User, { foreignKey: 'user_id', as: 'user' })
ActivityMember.belongsTo(Activity, { foreignKey: 'activity_id' })

// 活动 → 聊天室（一对一：每个活动自动创建一个群聊）
Activity.hasOne(ChatRoom, { foreignKey: 'activity_id', as: 'chatRoom' })
ChatRoom.belongsTo(Activity, { foreignKey: 'activity_id' })

// 聊天室 → 消息（一对多：一个聊天室包含多条消息）
ChatRoom.hasMany(Message, { foreignKey: 'room_id', as: 'messages' })
Message.belongsTo(ChatRoom, { foreignKey: 'room_id' })
Message.belongsTo(User, { foreignKey: 'sender_id', as: 'sender' })

// 评论 → 子评论（自关联：支持楼中楼回复）
Comment.hasMany(Comment, { foreignKey: 'parent_id', as: 'replies' })
Comment.belongsTo(User, { foreignKey: 'user_id', as: 'user' })

// 用户 → 打卡记录（一对多）
User.hasMany(Checkin, { foreignKey: 'user_id', as: 'checkins' })
Checkin.belongsTo(User, { foreignKey: 'user_id', as: 'user' })

// 用户 → AI 对话会话（一对多）
User.hasMany(AiSession, { foreignKey: 'user_id', as: 'aiSessions' })

// 用户 → 匹配池（一对一：每个用户最多在一个匹配池中）
User.hasOne(MatchPool, { foreignKey: 'user_id' })
MatchPool.belongsTo(User, { foreignKey: 'user_id', as: 'user' })

// 统一导出所有模型
module.exports = {
  sequelize, User, Route, RoutePoint, Activity, ActivityMember,
  ChatRoom, Message, Comment, Favorite, Checkin, AiSession, MatchPool
}
