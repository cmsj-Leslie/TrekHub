/**
 * JWT 认证中间件（必须登录）
 * 从请求头提取 Bearer Token → 验证 → 将用户信息挂载到 req.user
 */
const jwt = require('jsonwebtoken')
const { User } = require('../models')
const { unauthorized } = require('../utils/response')

module.exports = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token) return unauthorized(res)
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET) // 验证 token
    const user = await User.findByPk(decoded.id, { attributes: { exclude: ['password'] } })
    if (!user) return unauthorized(res, '用户不存在')
    req.user = user.toJSON() // 挂载到请求对象上，后续控制器可直接使用
    next()
  } catch {
    unauthorized(res, 'token已过期，请重新登录')
  }
}
