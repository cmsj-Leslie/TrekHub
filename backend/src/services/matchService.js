/**
 * 随机组队服务
 * 功能：定时从匹配池中筛选兼容用户，自动创建活动和群聊
 * 由 node-cron 每5分钟触发一次
 */
const { MatchPool, Activity, ActivityMember, ChatRoom, User, sequelize } = require('../models')
const { Op } = require('sequelize')

/**
 * 执行匹配（核心逻辑）
 * 遍历匹配池，按兼容性分组，至少2人即可组队
 */
async function runMatching(io) {
  const pool = await MatchPool.findAll({ where: { status: 1 } })
  if (pool.length < 2) return // 池中不足2人，跳过

  const matched = new Set()

  for (let i = 0; i < pool.length; i++) {
    if (matched.has(pool[i].user_id)) continue
    const group = [pool[i]]

    // 从剩余用户中寻找兼容的队友（最多6人一组）
    for (let j = i + 1; j < pool.length; j++) {
      if (matched.has(pool[j].user_id)) continue
      if (isCompatible(pool[i], pool[j]) && group.length < 6) {
        group.push(pool[j])
      }
    }

    // 至少2人才创建活动
    if (group.length >= 2) {
      await createMatchedActivity(group, io)
      group.forEach(p => matched.add(p.user_id))
    }
  }
}

/**
 * 判断两个用户是否兼容
 * 条件：日期相同（或不限）、技能标签有交集
 */
function isCompatible(a, b) {
  // 日期必须相容
  if (a.prefer_date && b.prefer_date && a.prefer_date !== b.prefer_date) return false
  // 技能标签有交集（如果双方都填了）
  const aTags = a.skill_tags || []
  const bTags = b.skill_tags || []
  if (aTags.length && bTags.length) {
    const hasCommon = aTags.some(t => bTags.includes(t))
    if (!hasCommon) return false
  }
  return true
}

/**
 * 创建匹配成功的活动（事务操作）
 * 包括：创建活动 → 创建群聊 → 添加成员 → 退出匹配池 → 推送通知
 */
async function createMatchedActivity(group, io) {
  const t = await sequelize.transaction()
  try {
    const first = group[0]
    const routeId = first.route_id || null
    const startDate = first.prefer_date || new Date()

    // 创建活动
    const activity = await Activity.create({
      route_id: routeId || 1,
      organizer_id: first.user_id,
      title: `随机组队活动 ${new Date().toLocaleDateString()}`,
      start_time: startDate,
      end_time: new Date(new Date(startDate).getTime() + 8 * 3600000), // 默认8小时
      max_members: group.length + 2,
      current_members: group.length,
      is_random: 1,
      safety_info: '随机组队活动，请注意安全'
    }, { transaction: t })

    // 创建活动群聊
    const room = await ChatRoom.create({
      type: 2, activity_id: activity.id, name: `组队群 #${activity.id}`
    }, { transaction: t })

    // 添加所有成员并加入群聊
    for (const p of group) {
      await ActivityMember.create({
        activity_id: activity.id, user_id: p.user_id,
        role: p.user_id === first.user_id ? 1 : 0, // 第一个用户为组织者
        status: 1
      }, { transaction: t })
      await sequelize.query(
        'INSERT INTO room_members (room_id, user_id) VALUES (?, ?)',
        { replacements: [room.id, p.user_id], transaction: t }
      )
      // 将用户从匹配池中移除
      await MatchPool.update({ status: 0 }, { where: { user_id: p.user_id }, transaction: t })
    }

    await t.commit()

    // 通过 WebSocket 向所有匹配成功的用户推送通知
    if (io) {
      group.forEach(p => {
        io.to(`user_${p.user_id}`).emit('match:success', {
          activityId: activity.id, roomId: room.id, memberCount: group.length
        })
      })
    }
  } catch (err) {
    await t.rollback()
    console.error('组队创建失败:', err.message)
  }
}

module.exports = { runMatching }
