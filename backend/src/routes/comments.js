/** 评论路由 - 列表(公开)、发表/删除/点赞(需登录) */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/commentController')
const wrap = require('../middleware/asyncHandler')

router.get('/', wrap(ctrl.list))
router.use(auth)
router.post('/',           wrap(ctrl.create))
router.delete('/:id',      wrap(ctrl.remove))
router.post('/:id/like',   wrap(ctrl.like))
router.get('/check-likes',  wrap(ctrl.checkLikes))

module.exports = router
