/**
 * 收藏控制器
 * 功能：收藏/取消收藏（toggle切换）、收藏列表、检查是否已收藏
 */
const { Favorite, Route, Activity } = require('../models')
const { success, fail } = require('../utils/response')

// 收藏/取消收藏（同一接口 toggle 切换）
exports.toggle = async (req, res) => {
  const { target_type, target_id } = req.body
  if (!target_type || !target_id) return fail(res, '缺少参数')
  const exists = await Favorite.findOne({ where: { user_id: req.user.id, target_type, target_id } })
  if (exists) {
    await exists.destroy()
    if (target_type === 1) await Route.decrement('like_count', { where: { id: target_id } }) // 线路收藏数-1
    return success(res, { favorited: false })
  }
  await Favorite.create({ user_id: req.user.id, target_type, target_id })
  if (target_type === 1) await Route.increment('like_count', { where: { id: target_id } }) // 线路收藏数+1
  success(res, { favorited: true })
}

// 获取用户收藏列表
exports.list = async (req, res) => {
  const { type = 1, page = 1, pageSize = 12 } = req.query
  const { count, rows } = await Favorite.findAndCountAll({
    where: { user_id: req.user.id, target_type: type },
    order: [['created_at', 'DESC']],
    limit: +pageSize, offset: (page - 1) * pageSize
  })
  // 根据收藏类型批量查询对应实体（线路或活动）
  const ids = rows.map(f => f.target_id)
  const targets = type == 1
    ? await Route.findAll({ where: { id: ids } })
    : await Activity.findAll({ where: { id: ids } })
  success(res, { total: count, list: targets })
}

// 检查当前用户是否已收藏某个目标
exports.check = async (req, res) => {
  const { target_type, target_id } = req.query
  const exists = await Favorite.findOne({ where: { user_id: req.user.id, target_type, target_id } })
  success(res, { favorited: !!exists })
}
