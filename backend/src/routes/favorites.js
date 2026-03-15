/** 收藏路由 - 收藏切换、收藏列表、检查是否已收藏 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/favoriteController')
const wrap = require('../middleware/asyncHandler')

router.use(auth)
router.post('/toggle', wrap(ctrl.toggle))
router.get('/list',    wrap(ctrl.list))
router.get('/check',   wrap(ctrl.check))

module.exports = router
