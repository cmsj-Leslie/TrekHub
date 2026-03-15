/**
 * 管理员权限中间件
 * 必须在 auth 中间件之后使用
 */
const { fail } = require('../utils/response')

module.exports = (req, res, next) => {
  if (!req.user || req.user.role !== 1) {
    return fail(res, '需要管理员权限', 403)
  }
  next()
}
