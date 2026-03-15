/** 打卡路由 - 打卡列表、日历、详情、创建(支持多图上传) */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const upload = require('../middleware/upload')
const ctrl = require('../controllers/checkinController')
const wrap = require('../middleware/asyncHandler')

router.get('/',          auth, wrap(ctrl.list))
router.get('/calendar',  auth, wrap(ctrl.calendar))
router.get('/:id',       wrap(ctrl.detail))

router.use(auth)
router.post('/', upload.array('images', 9), wrap(ctrl.create))

module.exports = router
