/**
 * 可选认证中间件
 * 有 token 就解析用户信息，没有也放行（用于"登录可选"的接口）
 */
const jwt = require('jsonwebtoken')
const { User } = require('../models')

module.exports = async (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (!token) return next() // 未登录直接放行
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    const user = await User.findByPk(decoded.id, { attributes: { exclude: ['password'] } })
    if (user) req.user = user.toJSON()
  } catch { /* token 无效，静默放行 */ }
  next()
}
