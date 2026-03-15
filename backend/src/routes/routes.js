/** 线路路由 - 列表、详情、创建、更新、删除、GPX上传、AI推荐 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const upload = require('../middleware/upload')
const ctrl = require('../controllers/routeController')
const wrap = require('../middleware/asyncHandler')

const optionalAuth = (req, res, next) => {
  const token = req.headers.authorization?.replace('Bearer ', '')
  if (token) {
    try { req.user = require('jsonwebtoken').verify(token, process.env.JWT_SECRET) } catch {}
  }
  next()
}

router.get('/', wrap(ctrl.list))

// ⚠️ 具体路径必须在 /:id 之前注册，否则 /me/recommended 会被 /:id 吞掉
router.get('/me/recommended',              auth, wrap(ctrl.recommended))
router.post('/gpx/upload', auth, upload.single('gpx'), wrap(ctrl.uploadGpx))

// 动态路由放后面
router.get('/:id', optionalAuth, wrap(ctrl.detail))

router.use(auth)
router.post('/', upload.single('cover_image'), wrap(ctrl.create))
router.put('/:id', upload.single('cover_image'), wrap(ctrl.update))
router.delete('/:id', wrap(ctrl.remove))

module.exports = router
