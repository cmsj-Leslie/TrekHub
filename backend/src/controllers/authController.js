/**
 * 认证控制器
 * 功能：用户注册和登录，使用 bcrypt 加密密码，JWT 签发令牌
 */
const bcrypt = require('bcryptjs')
const jwt = require('jsonwebtoken')
const { User } = require('../models')
const { success, fail, created } = require('../utils/response')

// 生成 JWT Token（包含用户ID和用户名）
const signToken = (user) =>
  jwt.sign({ id: user.id, username: user.username }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRES })

// 用户注册：校验重复 → 加密密码 → 创建用户 → 返回 token
exports.register = async (req, res) => {
  const { username, email, password, nickname } = req.body
  if (!username || !email || !password) return fail(res, '请填写完整信息')
  if (await User.findOne({ where: { username } })) return fail(res, '用户名已存在')
  if (await User.findOne({ where: { email } })) return fail(res, '邮箱已注册')
  const hashed = await bcrypt.hash(password, 10) // 密码加密，盐值10轮
  const user = await User.create({ username, email, password: hashed, nickname: nickname || username })
  created(res, { token: signToken(user), user: { id: user.id, username: user.username, nickname: user.nickname } })
}

// 用户登录：支持用户名或邮箱登录 → 校验密码 → 返回 token 和用户信息
exports.login = async (req, res) => {
  const { account, password } = req.body
  const user = await User.findOne({ where: { [require('sequelize').Op.or]: [{ username: account }, { email: account }] } })
  if (!user || !(await bcrypt.compare(password, user.password))) return fail(res, '账号或密码错误')
  success(res, { token: signToken(user), user: { id: user.id, username: user.username, nickname: user.nickname, avatar: user.avatar, level: user.level, role: user.role } })
}
