/**
 * 随机组队控制器
 * 功能：加入/退出匹配池、查询匹配状态
 */
const { MatchPool, User } = require('../models')
const { success, fail } = require('../utils/response')
const matchService = require('../services/matchService')

// 加入匹配池（设置偏好线路、日期、等级范围、技能标签）
exports.join = async (req, res) => {
  const { route_id, prefer_date, min_level, max_level, skill_tags } = req.body
  await MatchPool.upsert({
    user_id: req.user.id, route_id, prefer_date, min_level, max_level, skill_tags, status: 1
  })
  success(res, null, '已加入组队池，正在为你匹配队友')

  // 异步立即触发一次匹配（不阻塞响应）
  const io = req.app.get('io')
  matchService.runMatching(io).catch(err => {
    console.error('[即时匹配失败]', err.message)
  })
}

// 退出匹配池
exports.leave = async (req, res) => {
  await MatchPool.destroy({ where: { user_id: req.user.id } })
  success(res, null, '已退出组队池')
}

// 查询匹配状态（是否在池中、池中总人数）
exports.status = async (req, res) => {
  const entry = await MatchPool.findOne({ where: { user_id: req.user.id } })
  const poolCount = await MatchPool.count({ where: { status: 1 } })
  success(res, entry ? { inPool: true, status: entry.status, poolCount } : { inPool: false, poolCount })
}
