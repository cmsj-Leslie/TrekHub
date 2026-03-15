/** 统一响应工具函数 - success/fail/unauthorized/forbidden/notFound/serverError */
// 统一响应格式，全局复用，避免每处重复写
exports.success = (res, data = null, msg = 'ok') =>
  res.json({ code: 200, msg, data })

exports.created = (res, data = null) =>
  res.status(201).json({ code: 201, msg: 'created', data })

exports.fail = (res, msg = '操作失败', code = 400) =>
  res.status(code).json({ code, msg, data: null })

exports.unauthorized = (res, msg = '请先登录') =>
  res.status(401).json({ code: 401, msg, data: null })

exports.forbidden = (res, msg = '无权限') =>
  res.status(403).json({ code: 403, msg, data: null })

exports.notFound = (res, msg = '资源不存在') =>
  res.status(404).json({ code: 404, msg, data: null })

exports.serverError = (res, msg = '服务器内部错误') =>
  res.status(500).json({ code: 500, msg, data: null })
