/**
 * 活动控制器
 * 功能：活动CRUD、报名申请、组织者审批成员、我的活动列表
 */
const { Activity, ActivityMember, ChatRoom, User, Route, sequelize } = require('../models')
const { Op } = require('sequelize')
const { success, created, fail, notFound, forbidden } = require('../utils/response')

// 活动列表（支持状态筛选和关键字搜索）
exports.list = async (req, res) => {
  // 每次查询时自动将超过结束时间的活动标记为"已结束"
  await Activity.update(
    { status: 3 },
    { where: { status: [1, 2], end_time: { [Op.lt]: new Date() } } }
  )
  const { page = 1, pageSize = 10, status, keyword } = req.query
  const where = {}
  if (status) where.status = status
  if (keyword) where.title = { [Op.like]: `%${keyword}%` }
  const { count, rows } = await Activity.findAndCountAll({
    where, limit: +pageSize, offset: (page - 1) * pageSize,
    order: [['start_time', 'ASC']],
    include: [
      { model: User, as: 'organizer', attributes: ['id', 'nickname', 'avatar'] },
      { model: Route, as: 'route', attributes: ['id', 'title', 'difficulty', 'cover_image'] }
    ]
  })
  success(res, { total: count, list: rows, page: +page, pageSize: +pageSize })
}

// 活动详情（含全部成员，组织者可看待审核的）
exports.detail = async (req, res) => {
  const activity = await Activity.findByPk(req.params.id, {
    include: [
      { model: User, as: 'organizer', attributes: ['id', 'nickname', 'avatar', 'level'] },
      { model: Route, as: 'route' },
      { model: ActivityMember, as: 'members', required: false,
        include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar', 'level'] }] },
      { model: ChatRoom, as: 'chatRoom', attributes: ['id'] }  // 获取群聊室 ID
    ]
  })
  if (!activity) return notFound(res)
  // 查询当前用户的申请状态（null=未申请, 0=待审核, 1=已通过, 2=已拒绝）
  let myStatus = null
  if (req.user) {
    const m = await ActivityMember.findOne({ where: { activity_id: activity.id, user_id: req.user.id } })
    myStatus = m ? m.status : null
  }
  const json = activity.toJSON()
  success(res, { ...json, myStatus, chatRoomId: json.chatRoom?.id || null })
}

// 创建活动：同时创建活动群聊，组织者自动加入
exports.create = async (req, res) => {
  const { route_id, title, description, start_time, end_time, max_members, min_level, gear_require, safety_info } = req.body
  if (!route_id || !title || !start_time || !end_time || !safety_info) return fail(res, '缺少必填字段（安全信息必填）')
  const t = await sequelize.transaction()
  try {
    // 创建活动记录
    const activity = await Activity.create({
      route_id, organizer_id: req.user.id, title, description, start_time, end_time,
      max_members: max_members || 10, min_level: min_level || 1, gear_require, safety_info
    }, { transaction: t })
    // 组织者自动成为成员（role=1表示组织者）
    await ActivityMember.create({ activity_id: activity.id, user_id: req.user.id, role: 1, status: 1 }, { transaction: t })
    // 创建活动群聊室
    const room = await ChatRoom.create({ type: 2, activity_id: activity.id, name: title }, { transaction: t })
    // 组织者加入群聊
    await sequelize.query('INSERT INTO room_members (room_id, user_id) VALUES (?,?)',
      { replacements: [room.id, req.user.id], transaction: t })
    await t.commit()
    created(res, { activity, roomId: room.id })
  } catch (e) {
    await t.rollback()
    fail(res, e.message)
  }
}

// 申请参加活动
exports.apply = async (req, res) => {
  const activity = await Activity.findByPk(req.params.id)
  if (!activity) return notFound(res)
  if (activity.status !== 1) return fail(res, '该活动已不在招募中')
  if (activity.current_members >= activity.max_members) return fail(res, '活动名额已满')
  const exists = await ActivityMember.findOne({ where: { activity_id: activity.id, user_id: req.user.id } })
  if (exists) return fail(res, '已申请过该活动')
  await ActivityMember.create({ activity_id: activity.id, user_id: req.user.id, apply_msg: req.body.apply_msg })
  success(res, null, '申请已提交，等待组织者审核')
}

// 组织者审批成员（通过/拒绝）
exports.reviewMember = async (req, res) => {
  const { memberId, action } = req.body
  const member = await ActivityMember.findByPk(memberId)
  if (!member) return notFound(res)
  const activity = await Activity.findByPk(member.activity_id)
  if (!activity) return notFound(res)
  if (activity.organizer_id !== req.user.id) return forbidden(res) // 只有组织者能审批
  if (action === 'approve') {
    await member.update({ status: 1 })           // 标记为已通过
    await activity.increment('current_members')   // 增加成员数
    // 将通过的成员加入活动群聊
    const room = await ChatRoom.findOne({ where: { activity_id: activity.id, type: 2 } })
    if (room) {
      await sequelize.query('INSERT IGNORE INTO room_members (room_id, user_id) VALUES (?,?)',
        { replacements: [room.id, member.user_id] })
    }
    // 如果人满了，自动更新状态为"已满员"
    if (activity.current_members + 1 >= activity.max_members) await activity.update({ status: 2 })
  } else {
    await member.update({ status: 2 }) // 标记为已拒绝
  }
  success(res, null, action === 'approve' ? '已通过' : '已拒绝')
}

// 获取当前用户参加的所有活动
exports.myActivities = async (req, res) => {
  const members = await ActivityMember.findAll({
    where: { user_id: req.user.id, status: 1 },
    include: [{
      model: Activity,
      include: [{ model: Route, as: 'route', attributes: ['id', 'title', 'cover_image', 'difficulty'] }]
    }]
  })
  success(res, members)
}
