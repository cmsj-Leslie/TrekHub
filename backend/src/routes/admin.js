/** 后台管理路由 - 统计面板、用户/线路/评论管理(需管理员权限) */
const router = require('express').Router()
const auth = require('../middleware/auth')
const adminAuth = require('../middleware/adminAuth')
const c = require('../controllers/adminController')
const wrap = require('../middleware/asyncHandler')

// 公开统计（首页用，无需鉴权）
router.get('/public-stats', wrap(c.publicStats))

// 所有管理员路由都需要 auth + adminAuth
router.use(auth, adminAuth)

router.get('/stats', wrap(c.stats))
router.get('/users', wrap(c.userList))
router.put('/users/:id/role', wrap(c.updateRole))
router.put('/users/:id', wrap(c.updateUser))
router.get('/routes', wrap(c.routeList))
router.put('/routes/:id', wrap(c.updateRoute))
router.delete('/routes/:id', wrap(c.deleteRoute))
router.get('/comments', wrap(c.commentList))
router.delete('/comments/:id', wrap(c.deleteComment))

module.exports = router

