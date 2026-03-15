/**
 * WebSocket 聊天处理器
 * 功能：基于 Socket.IO 实现实时聊天（加入房间、发消息、标记已读、离开房间）
 */
const { Message, User, sequelize } = require('../models')

// 维护 socketId → userId 映射关系
const socketUserMap = new Map()

module.exports = (io) => {
  // WebSocket 连接前先验证 JWT Token
  io.use((socket, next) => {
    const token = socket.handshake.auth.token
    if (!token) return next(new Error('未登录'))
    try {
      const jwt = require('jsonwebtoken')
      socket.user = jwt.verify(token, process.env.JWT_SECRET) // 解析用户信息
      next()
    } catch {
      next(new Error('token无效'))
    }
  })

  // 用户连接成功后的事件处理
  io.on('connection', (socket) => {
    const uid = socket.user.id
    socketUserMap.set(socket.id, uid)
    socket.join(`user_${uid}`) // 加入用户专属房间（用于接收推送通知）

    // 加入聊天室
    socket.on('chat:join', ({ roomId }) => {
      socket.join(`room_${roomId}`)
    })

    // 离开聊天室
    socket.on('chat:leave', ({ roomId }) => {
      socket.leave(`room_${roomId}`)
    })

    // 发送消息（支持文字和图片两种类型）
    socket.on('chat:send', async ({ roomId, content, type = 1 }) => {
      if (!content?.trim() && type === 1) return
      // 校验是否是房间成员（防止非法发送）
      const [member] = await sequelize.query(
        'SELECT 1 FROM room_members WHERE room_id = ? AND user_id = ?',
        { replacements: [roomId, uid], type: sequelize.QueryTypes.SELECT }
      )
      if (!member) return

      // 存入数据库
      const msg = await Message.create({ room_id: roomId, sender_id: uid, type, content })
      const sender = await User.findByPk(uid, { attributes: ['id', 'nickname', 'avatar'] })

      // 广播给房间内所有在线成员
      io.to(`room_${roomId}`).emit('chat:message', {
        id: msg.id, roomId, content, type,
        sender: sender.toJSON(),
        createdAt: msg.created_at
      })
    })

    // 标记消息为已读
    socket.on('chat:read', async ({ roomId }) => {
      await Message.update(
        { is_read: 1 },
        { where: { room_id: roomId, sender_id: { [require('sequelize').Op.ne]: uid }, is_read: 0 } }
      )
    })

    // 用户断开连接时清理映射
    socket.on('disconnect', () => {
      socketUserMap.delete(socket.id)
    })
  })
}
