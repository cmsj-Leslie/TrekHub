/** 活动评价路由 - 提交评价(需登录)、按活动查、按用户查(公开) */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/reviewController')
const wrap = require('../middleware/asyncHandler')

router.get('/activity/:activityId', wrap(ctrl.getByActivity))
router.get('/user/:userId',         wrap(ctrl.getByUser))
router.use(auth)
router.post('/',                     wrap(ctrl.create))

module.exports = router
