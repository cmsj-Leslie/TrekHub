/** 认证路由 - 注册(POST /register)、登录(POST /login) */
const express = require('express')
const router = express.Router()
const ctrl = require('../controllers/authController')
const wrap = require('../middleware/asyncHandler')

router.post('/register', wrap(ctrl.register))
router.post('/login',    wrap(ctrl.login))

module.exports = router
