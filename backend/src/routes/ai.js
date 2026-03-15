/** AI助手路由 - AI对话(POST /chat)、清除对话历史(DELETE /session/:type) */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/aiController')
const wrap = require('../middleware/asyncHandler')

router.use(auth)
router.post('/chat',               wrap(ctrl.chat))
router.delete('/session/:type',    wrap(ctrl.clearSession))

module.exports = router
