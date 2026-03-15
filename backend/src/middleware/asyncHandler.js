/** 异步错误捕获中间件 - 包裹async控制器，自动catch返回500 */
const { serverError } = require('../utils/response')

// 包裹异步 controller，自动捕获错误返回 500，防止未捕获 Promise 崩溃进程
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(err => {
    console.error('[Controller Error]', err.message)
    serverError(res, err.message)
  })
}

module.exports = asyncHandler
