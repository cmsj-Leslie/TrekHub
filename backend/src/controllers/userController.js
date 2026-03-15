/**
 * 用户控制器
 * 功能：个人资料查看/编辑、密码修改、技能标签、关注/粉丝系统
 */
const bcrypt = require('bcryptjs')
const { User, Route, Checkin, Favorite, sequelize } = require('../models')
const { success, fail, notFound } = require('../utils/response')

// 获取用户资料（可看自己或他人），附带该用户发布的线路
exports.getProfile = async (req, res) => {
  const id = req.params.id || req.user.id
  const user = await User.findByPk(id, {
    attributes: { exclude: ['password'] }, // 排除密码字段
    include: [{ model: Route, as: 'routes', attributes: ['id', 'title', 'cover_image', 'difficulty', 'distance_km', 'elevation_m', 'like_count', 'region'], limit: 6 }]
  })
  if (!user) return notFound(res, '用户不存在')
  success(res, user)
}

// 更新个人资料（昵称、简介、性别、等级、头像）
exports.updateProfile = async (req, res) => {
  const { nickname, bio, gender, level } = req.body
  const update = {}
  if (nickname !== undefined) update.nickname = nickname
  if (bio !== undefined) update.bio = bio
  if (gender !== undefined) update.gender = gender
  if (level !== undefined) update.level = level
  if (req.file) update.avatar = `/uploads/images/${req.file.filename}` // 头像文件路径
  await User.update(update, { where: { id: req.user.id } })
  const user = await User.findByPk(req.user.id, { attributes: { exclude: ['password'] } })
  success(res, user)
}

// 修改密码：先验证旧密码，再设置新密码
exports.updatePassword = async (req, res) => {
  const { oldPassword, newPassword } = req.body
  const bcrypt = require('bcryptjs')
  const user = await User.findByPk(req.user.id)
  if (!(await bcrypt.compare(oldPassword, user.password))) return fail(res, '原密码错误')
  await user.update({ password: await bcrypt.hash(newPassword, 10) })
  success(res, null, '密码修改成功')
}

// 更新用户技能标签（先清空再批量插入）
exports.updateSkills = async (req, res) => {
  const { tagIds } = req.body
  await sequelize.query('DELETE FROM user_skills WHERE user_id = ?', { replacements: [req.user.id] })
  if (tagIds?.length) {
    const values = tagIds.map(tid => `(${req.user.id}, ${tid})`).join(',')
    await sequelize.query(`INSERT INTO user_skills (user_id, tag_id) VALUES ${values}`)
  }
  success(res, null, '技能标签已更新')
}

// 获取用户已选的技能标签
exports.getUserSkills = async (req, res) => {
  const rows = await sequelize.query(
    'SELECT st.* FROM skill_tags st JOIN user_skills us ON st.id = us.tag_id WHERE us.user_id = ?',
    { replacements: [req.params.id || req.user.id], type: sequelize.QueryTypes.SELECT }
  )
  success(res, rows)
}

// 获取所有可选技能标签（下拉选项用）
exports.getAllSkillTags = async (req, res) => {
  const rows = await sequelize.query('SELECT * FROM skill_tags', { type: sequelize.QueryTypes.SELECT })
  success(res, rows)
}

// 关注/取消关注（toggle 切换）
exports.toggleFollow = async (req, res) => {
  const followingId = +req.params.id
  if (followingId === req.user.id) return fail(res, '不能关注自己')
  const target = await User.findByPk(followingId)
  if (!target) return notFound(res, '用户不存在')

  const [existing] = await sequelize.query(
    'SELECT 1 FROM user_follows WHERE follower_id = ? AND following_id = ?',
    { replacements: [req.user.id, followingId], type: sequelize.QueryTypes.SELECT }
  )
  if (existing) {
    await sequelize.query('DELETE FROM user_follows WHERE follower_id = ? AND following_id = ?',
      { replacements: [req.user.id, followingId] })
    success(res, { followed: false }, '已取消关注')
  } else {
    await sequelize.query('INSERT INTO user_follows (follower_id, following_id) VALUES (?, ?)',
      { replacements: [req.user.id, followingId] })
    success(res, { followed: true }, '已关注')
  }
}

// 获取关注状态 + 粉丝数 + 关注数
exports.getFollowInfo = async (req, res) => {
  const targetId = +req.params.id
  const [[{ followerCount }]] = await sequelize.query(
    'SELECT COUNT(*) AS followerCount FROM user_follows WHERE following_id = ?',
    { replacements: [targetId] }
  )
  const [[{ followingCount }]] = await sequelize.query(
    'SELECT COUNT(*) AS followingCount FROM user_follows WHERE follower_id = ?',
    { replacements: [targetId] }
  )
  let isFollowed = false
  if (req.user) {
    const [row] = await sequelize.query(
      'SELECT 1 FROM user_follows WHERE follower_id = ? AND following_id = ?',
      { replacements: [req.user.id, targetId], type: sequelize.QueryTypes.SELECT }
    )
    isFollowed = !!row
  }
  success(res, { followerCount: +followerCount, followingCount: +followingCount, isFollowed })
}

// 获取粉丝列表
exports.getFollowers = async (req, res) => {
  const targetId = +req.params.id
  const [rows] = await sequelize.query(
    `SELECT u.id, u.nickname, u.avatar, u.level, u.bio
     FROM user_follows f JOIN users u ON f.follower_id = u.id
     WHERE f.following_id = ? ORDER BY f.created_at DESC`,
    { replacements: [targetId] }
  )
  success(res, rows)
}

// 获取关注列表
exports.getFollowing = async (req, res) => {
  const targetId = +req.params.id
  const [rows] = await sequelize.query(
    `SELECT u.id, u.nickname, u.avatar, u.level, u.bio
     FROM user_follows f JOIN users u ON f.following_id = u.id
     WHERE f.follower_id = ? ORDER BY f.created_at DESC`,
    { replacements: [targetId] }
  )
  success(res, rows)
}
