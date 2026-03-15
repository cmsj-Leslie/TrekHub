/**
 * 聊天控制器
 * 功能：获取聊天室列表、创建私聊房间、获取历史消息、获取房间成员
 */
const { ChatRoom, Message, User, sequelize } = require('../models')
const { Op } = require('sequelize')
const { success, created, fail, notFound, forbidden } = require('../utils/response')

// 获取当前用户所有聊天室（含最新一条消息和未读数）
exports.myRooms = async (req, res) => {
  const rooms = await sequelize.query(`
    SELECT cr.*, m.content as last_msg, m.created_at as last_msg_time,
           (SELECT COUNT(*) FROM messages WHERE room_id = cr.id AND is_read = 0 AND sender_id != :uid) as unread
    FROM chat_rooms cr
    JOIN room_members rm ON rm.room_id = cr.id AND rm.user_id = :uid
    LEFT JOIN messages m ON m.id = (SELECT MAX(id) FROM messages WHERE room_id = cr.id)
    ORDER BY last_msg_time DESC
  `, { replacements: { uid: req.user.id }, type: sequelize.QueryTypes.SELECT })
  success(res, rooms)
}

// 获取或创建私聊房间（如果已存在就复用，不存在就新建）
exports.getOrCreatePrivateRoom = async (req, res) => {
  const { targetUserId } = req.body
  if (!targetUserId || targetUserId === req.user.id) return fail(res, '参数错误')
  // 查找双方是否已有私聊房间
  const existing = await sequelize.query(`
    SELECT cr.id FROM chat_rooms cr
    JOIN room_members r1 ON r1.room_id = cr.id AND r1.user_id = :uid
    JOIN room_members r2 ON r2.room_id = cr.id AND r2.user_id = :tid
    WHERE cr.type = 1 LIMIT 1
  `, { replacements: { uid: req.user.id, tid: targetUserId }, type: sequelize.QueryTypes.SELECT })

  if (existing.length) return success(res, { roomId: existing[0].id })

  // 不存在则创建新房间，并将双方加入
  const room = await ChatRoom.create({ type: 1 })
  await sequelize.query('INSERT INTO room_members (room_id, user_id) VALUES (?,?),(?,?)',
    { replacements: [room.id, req.user.id, room.id, targetUserId] })
  success(res, { roomId: room.id })
}

// 获取历史消息（支持向上翻页加载更早消息）
exports.getMessages = async (req, res) => {
  const { roomId } = req.params
  const { before, limit = 30 } = req.query
  // 验证当前用户是否是房间成员
  const [member] = await sequelize.query(
    'SELECT 1 FROM room_members WHERE room_id = ? AND user_id = ?',
    { replacements: [roomId, req.user.id], type: sequelize.QueryTypes.SELECT }
  )
  if (!member) return forbidden(res, '不在该聊天室')
  const where = { room_id: roomId }
  if (before) where.id = { [Op.lt]: before } // 加载 before ID 之前的消息
  const messages = await Message.findAll({
    where, order: [['id', 'DESC']], limit: +limit,
    include: [{ model: User, as: 'sender', attributes: ['id', 'nickname', 'avatar'] }]
  })
  // 标记对方发的消息为已读
  await Message.update({ is_read: 1 }, { where: { room_id: roomId, sender_id: { [Op.ne]: req.user.id }, is_read: 0 } })
  success(res, messages.reverse()) // 翻转为正序返回
}

// 获取聊天室成员列表
exports.getRoomMembers = async (req, res) => {
  const members = await sequelize.query(`
    SELECT u.id, u.nickname, u.avatar, u.level, rm.joined_at
    FROM room_members rm JOIN users u ON u.id = rm.user_id
    WHERE rm.room_id = ?
  `, { replacements: [req.params.roomId], type: sequelize.QueryTypes.SELECT })
  success(res, members)
}
