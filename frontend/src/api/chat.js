/**
 * 聊天相关 API（HTTP 部分）
 * 功能：聊天室列表、创建私聊、获取历史消息、房间成员
 * 注意：实时消息收发由 Socket.IO 处理，见 stores/chat.js
 */
import request from './request'

// 获取我的聊天室列表（含最后一条消息和未读数）
export const getMyRooms         = ()            => request.get('/chat/rooms')
// 创建或获取与某用户的私聊房间
export const createPrivateRoom  = (targetUserId) => request.post('/chat/rooms/private', { targetUserId })
// 获取聊天室历史消息（支持 before 分页）
export const getMessages        = (roomId, params) => request.get(`/chat/rooms/${roomId}/messages`, { params })
// 获取聊天室成员列表
export const getRoomMembers     = (roomId)      => request.get(`/chat/rooms/${roomId}/members`)
// 删除/退出会话
export const leaveRoom          = (roomId)      => request.delete(`/chat/rooms/${roomId}`)
