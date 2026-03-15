/** 活动路由 - 列表、详情、创建、申请、审批、我的活动 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/activityController')
const wrap = require('../middleware/asyncHandler')

const optionalAuth = (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (token) {
    try { req.user = require('jsonwebtoken').verify(token, process.env.JWT_SECRET) } catch {}
  }
  next()
}

router.get('/', wrap(ctrl.list))

// ⚠️ 具体路径必须在 /:id 之前注册
router.get('/me/list',          auth, wrap(ctrl.myActivities))
router.post('/review-member',   auth, wrap(ctrl.reviewMember))

// 动态路由放后面
router.get('/:id', optionalAuth, wrap(ctrl.detail))

router.use(auth)
router.post('/',              wrap(ctrl.create))
router.post('/:id/apply',     wrap(ctrl.apply))

module.exports = router
