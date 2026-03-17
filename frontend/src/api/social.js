/**
 * 社交功能 API
 * 功能：评论系统、收藏功能、打卡记录、AI对话、随机组队
 */
import request from './request'

// ===== 评论 =====
// 获取评论列表（按目标类型和ID筛选）
export const getComments    = (params) => request.get('/comments', { params })
// 发表评论或回复
export const createComment  = (data)   => request.post('/comments', data)
// 删除评论（仅作者）
export const removeComment  = (id)     => request.delete(`/comments/${id}`)
// 点赞/取消点赞评论
export const likeComment    = (id)     => request.post(`/comments/${id}/like`)
// 批量检查评论点赞状态
export const checkCommentLikes = (ids) => request.get('/comments/check-likes', { params: { ids: ids.join(',') } })
// 上传评论图片
export const uploadCommentImage = (file) => {
  const fd = new FormData()
  fd.append('image', file)
  return request.post('/comments/upload-image', fd)
}

// ===== 收藏 =====
// 收藏或取消收藏
export const toggleFavorite = (data)   => request.post('/favorites/toggle', data)
// 获取我的收藏列表
export const getFavorites   = (params) => request.get('/favorites/list', { params })
// 检查是否已收藏某线路
export const checkFavorite  = (params) => request.get('/favorites/check', { params })

// ===== 打卡 =====
// 创建打卡记录（支持多图上传）
export const createCheckin  = (data)   => request.post('/checkins', data)
// 获取打卡记录列表
export const getCheckins    = (params) => request.get('/checkins', { params })
// 获取月度打卡日历统计
export const getCheckinCalendar = (params) => request.get('/checkins/calendar', { params })
// 获取打卡详情
export const getCheckin     = (id)     => request.get(`/checkins/${id}`)

// ===== AI 助手 =====
// 发送消息给AI（带上下文记忆）
export const aiChat         = (data)   => request.post('/ai/chat', data)
// 清除AI对话历史
export const clearAiSession = (type)   => request.delete(`/ai/session/${type}`)

// ===== 随机组队 =====
// 加入匹配池
export const joinMatch      = (data)   => request.post('/match/join', data)
// 退出匹配池
export const leaveMatch     = ()       => request.delete('/match/leave')
// 查询匹配状态
export const matchStatus    = ()       => request.get('/match/status')
