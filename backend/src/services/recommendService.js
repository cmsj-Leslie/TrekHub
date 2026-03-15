/**
 * 推荐服务
 * 功能：混合推荐算法（内容相关 40% + 协同过滤 40% + 热度 20%）
 * 为用户推荐最适合的徒步线路
 */
const { Route, Favorite, User, sequelize } = require('../models')
const { Op } = require('sequelize')

/**
 * 获取推荐线路（混合推荐算法）
 * 1. 内容相关：根据用户等级推荐难度匹配的线路
 * 2. 协同过滤：找行为相似的用户，推荐他们收藏的线路
 * 3. 热度加权：浏览量和收藏数作为补充评分
 */
async function getRecommendedRoutes(userId, limit = 10) {
  const user = await User.findByPk(userId)
  if (!user) return []

  // 获取用户已收藏的线路（排除掉避免重复推荐）
  const myFavs = await Favorite.findAll({
    where: { user_id: userId, target_type: 1 }, attributes: ['target_id']
  })
  const myFavIds = myFavs.map(f => f.target_id)
  const excludeIds = myFavIds.length ? myFavIds : [0]

  // ① 内容相关推荐：等级 ±1 范围内的线路，按收藏数排序
  const contentRoutes = await Route.findAll({
    where: {
      status: 1, is_public: 1,
      id: { [Op.notIn]: excludeIds },
      difficulty: { [Op.between]: [Math.max(1, user.level - 1), Math.min(5, user.level + 1)] }
    },
    order: [['like_count', 'DESC']], limit: 20,
    include: [{ model: User, as: 'creator', attributes: ['id', 'nickname', 'avatar'] }]
  })

  // ② 协同过滤推荐
  const collaborativeRoutes = await getCollaborativeRoutes(userId, myFavIds, excludeIds, 10)

  // ③ 合并打分
  const routeMap = new Map()
  contentRoutes.forEach(r => {
    routeMap.set(r.id, { route: r, score: calcScore(r, 0.4, 0) })
  })
  collaborativeRoutes.forEach(item => {
    if (routeMap.has(item.route.id)) {
      routeMap.get(item.route.id).score += 0.4 * item.similarity
    } else {
      routeMap.set(item.route.id, { route: item.route, score: calcScore(item.route, 0, 0.4 * item.similarity) })
    }
  })

  // 按综合得分排序，取前 N 条
  return [...routeMap.values()]
    .sort((a, b) => b.score - a.score)
    .slice(0, limit)
    .map(item => item.route)
}

// 计算综合得分：内容权重 + 协同权重 + 热度权重(20%)
function calcScore(route, contentWeight, collab) {
  const hotness = (route.view_count * 0.3 + route.like_count * 0.5) / 1000
  return contentWeight + collab + 0.2 * Math.min(hotness, 1)
}

/**
 * 协同过滤：找与当前用户行为相似的用户，推荐他们收藏但当前用户未收藏的线路
 */
async function getCollaborativeRoutes(userId, myFavIds, excludeIds, limit) {
  if (!myFavIds.length) return []

  // 找行为相似的用户（收藏了相同线路的人）
  const similarUsers = await Favorite.findAll({
    where: { target_type: 1, target_id: { [Op.in]: myFavIds }, user_id: { [Op.ne]: userId } },
    attributes: ['user_id', [sequelize.fn('COUNT', sequelize.col('target_id')), 'overlap']],
    group: ['user_id'],
    order: [[sequelize.literal('overlap'), 'DESC']],
    limit: 10
  })
  if (!similarUsers.length) return []

  const simUserIds = similarUsers.map(u => u.user_id)
  const overlapMap = Object.fromEntries(
    similarUsers.map(u => [u.user_id, parseInt(u.dataValues.overlap)])
  )

  // 找相似用户收藏但当前用户未收藏的线路
  const favs = await Favorite.findAll({
    where: {
      user_id: { [Op.in]: simUserIds }, target_type: 1,
      target_id: { [Op.notIn]: excludeIds }
    },
    attributes: ['user_id', 'target_id']
  })

  // 计算每条线路的相似度得分
  const routeScores = new Map()
  for (const fav of favs) {
    const sim = overlapMap[fav.user_id] / myFavIds.length // 越多共同收藏，相似度越高
    if (!routeScores.has(fav.target_id)) {
      const route = await Route.findByPk(fav.target_id, {
        include: [{ model: User, as: 'creator', attributes: ['id', 'nickname', 'avatar'] }]
      })
      if (route && route.status === 1) {
        routeScores.set(fav.target_id, { route, similarity: sim })
      }
    } else {
      routeScores.get(fav.target_id).similarity += sim
    }
  }

  return [...routeScores.values()]
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, limit)
}

module.exports = { getRecommendedRoutes }
