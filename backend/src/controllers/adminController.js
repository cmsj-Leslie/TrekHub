/**
 * 后台管理控制器
 * 功能：系统统计面板、用户管理、线路管理、评论管理
 */
const { User, Route, Activity, Comment, Checkin } = require('../models')
const { success, fail } = require('../utils/response')
const { Op } = require('sequelize')
const sequelize = require('../config/db')

// 后台统计面板（总数据 + 今日新增 + 7天趋势）
exports.stats = async (req, res) => {
  // 各模块总数
  const [userCount, routeCount, activityCount, commentCount, checkinCount] = await Promise.all([
    User.count(), Route.count(), Activity.count(), Comment.count(), Checkin.count()
  ])
  // 今日新增
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  const [todayUsers, todayRoutes, todayActivities] = await Promise.all([
    User.count({ where: { created_at: { [Op.gte]: today } } }),
    Route.count({ where: { created_at: { [Op.gte]: today } } }),
    Activity.count({ where: { created_at: { [Op.gte]: today } } })
  ])
  // 最近7天用户注册趋势
  const [weeklyTrend] = await sequelize.query(`
    SELECT DATE(created_at) AS date, COUNT(*) AS count
    FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    GROUP BY DATE(created_at) ORDER BY date
  `)
  success(res, {
    total: { userCount, routeCount, activityCount, commentCount, checkinCount },
    today: { todayUsers, todayRoutes, todayActivities },
    weeklyTrend
  })
}

// 用户管理列表（支持关键字搜索）
exports.userList = async (req, res) => {
  const { page = 1, size = 20, keyword = '' } = req.query
  const where = keyword ? {
    [Op.or]: [
      { username: { [Op.like]: `%${keyword}%` } },
      { nickname: { [Op.like]: `%${keyword}%` } },
      { email: { [Op.like]: `%${keyword}%` } }
    ]
  } : {}
  const { count, rows } = await User.findAndCountAll({
    where, attributes: { exclude: ['password'] },
    order: [['id', 'ASC']], limit: +size, offset: (+page - 1) * +size
  })
  success(res, { total: count, list: rows })
}

// 修改用户角色（0=普通用户, 1=管理员）
exports.updateRole = async (req, res) => {
  const user = await User.findByPk(req.params.id)
  if (!user) return fail(res, '用户不存在')
  if (user.id === req.user.id) return fail(res, '不能修改自己的角色')
  await user.update({ role: req.body.role })
  success(res, null, `用户 ${user.nickname} 角色已更新`)
}

// 修改用户信息
exports.updateUser = async (req, res) => {
  const user = await User.findByPk(req.params.id)
  if (!user) return fail(res, '用户不存在')
  const { nickname, email, level, bio, role } = req.body
  await user.update({ nickname, email, level, bio, role })
  success(res, user, '用户信息已更新')
}

// 修改线路信息
exports.updateRoute = async (req, res) => {
  const route = await Route.findByPk(req.params.id)
  if (!route) return fail(res, '线路不存在')
  const { title, difficulty, region, distance_km, elevation_m, status } = req.body
  await route.update({ title, difficulty, region, distance_km, elevation_m, status })
  success(res, route, '线路信息已更新')
}

// 删除线路（硬删除）
exports.deleteRoute = async (req, res) => {
  const route = await Route.findByPk(req.params.id)
  if (!route) return fail(res, '线路不存在')
  await route.destroy()
  success(res, null, '线路已删除')
}

// 删除评论
exports.deleteComment = async (req, res) => {
  const comment = await Comment.findByPk(req.params.id)
  if (!comment) return fail(res, '评论不存在')
  await comment.destroy()
  success(res, null, '评论已删除')
}

// 公开统计数据（首页展示用，不需要登录）
exports.publicStats = async (req, res) => {
  const [userCount, routeCount, activityCount, checkinCount] = await Promise.all([
    User.count(), Route.count(), Activity.count(), Checkin.count()
  ])
  success(res, { userCount, routeCount, activityCount, checkinCount })
}

// 管理员 - 线路列表
exports.routeList = async (req, res) => {
  const { page = 1, size = 15, keyword = '' } = req.query
  const where = keyword ? { title: { [Op.like]: `%${keyword}%` } } : {}
  const { count, rows } = await Route.findAndCountAll({
    where,
    include: [{ model: User, as: 'creator', attributes: ['id', 'nickname'] }],
    order: [['created_at', 'DESC']], limit: +size, offset: (+page - 1) * +size
  })
  success(res, { total: count, list: rows })
}

// 管理员 - 评论列表
exports.commentList = async (req, res) => {
  const { page = 1, size = 15, keyword = '' } = req.query
  const where = keyword ? { content: { [Op.like]: `%${keyword}%` } } : {}
  const { count, rows } = await Comment.findAndCountAll({
    where,
    include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] }],
    order: [['created_at', 'DESC']], limit: +size, offset: (+page - 1) * +size
  })
  success(res, { total: count, list: rows })
}
