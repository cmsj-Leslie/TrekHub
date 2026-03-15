/**
 * 打卡控制器
 * 功能：创建打卡记录、打卡列表、日历视图、打卡详情
 */
const { Checkin, User, sequelize } = require('../models')
const { Op } = require('sequelize')
const { success, created, fail, notFound } = require('../utils/response')

// 创建打卡记录（支持多图上传，自动更新用户累计数据）
exports.create = async (req, res) => {
  const { activity_id, route_id, title, content, lng, lat, distance_km } = req.body
  const images = req.files?.map(f => `/uploads/images/${f.filename}`) || []
  const checkin = await Checkin.create({
    user_id: req.user.id, activity_id, route_id, title, content,
    images, lng, lat, distance_km
  })
  // 更新用户统计：打卡次数+1，累计公里数增加
  const update = { total_checkin: sequelize.literal('total_checkin + 1') }
  if (distance_km) update.total_km = sequelize.literal(`total_km + ${parseFloat(distance_km)}`)
  await User.update(update, { where: { id: req.user.id } })
  created(res, checkin)
}

// 打卡记录列表（按时间倒序）
exports.list = async (req, res) => {
  const { user_id, page = 1, pageSize = 10 } = req.query
  const uid = user_id || req.user?.id
  if (!uid) return fail(res, '请传入 user_id 或先登录')
  const { count, rows } = await Checkin.findAndCountAll({
    where: { user_id: uid },
    order: [['checkin_at', 'DESC']],
    limit: +pageSize, offset: (page - 1) * pageSize,
    include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] }]
  })
  success(res, { total: count, list: rows })
}

// 日历视图：按月查询打卡，按天分组返回
exports.calendar = async (req, res) => {
  const { year, month } = req.query
  if (!year || !month) return fail(res, '缺少年月参数')
  const start = new Date(year, month - 1, 1)
  const end = new Date(year, month, 0, 23, 59, 59)
  const checkins = await Checkin.findAll({
    where: { user_id: req.user.id, checkin_at: { [Op.between]: [start, end] } },
    attributes: ['id', 'checkin_at', 'title', 'distance_km']
  })
  // 按日期分组
  const byDay = {}
  checkins.forEach(c => {
    const day = new Date(c.checkin_at).getDate()
    if (!byDay[day]) byDay[day] = []
    byDay[day].push(c)
  })
  success(res, byDay)
}

// 打卡详情
exports.detail = async (req, res) => {
  const checkin = await Checkin.findByPk(req.params.id, {
    include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] }]
  })
  if (!checkin) return notFound(res)
  success(res, checkin)
}
