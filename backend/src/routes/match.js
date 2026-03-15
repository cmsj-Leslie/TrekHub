/** 随机组队路由 - 加入/退出匹配池、查询状态 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/matchController')
const wrap = require('../middleware/asyncHandler')

router.use(auth)
router.post('/join',    wrap(ctrl.join))
router.delete('/leave', wrap(ctrl.leave))
router.get('/status',   wrap(ctrl.status))

module.exports = router
