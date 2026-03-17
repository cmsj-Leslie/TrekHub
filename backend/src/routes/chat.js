/** 聊天路由 - 房间列表、创建私聊、历史消息、房间成员、删除会话 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const ctrl = require('../controllers/chatController')
const wrap = require('../middleware/asyncHandler')

router.use(auth)
router.get('/rooms',                      wrap(ctrl.myRooms))
router.post('/rooms/private',             wrap(ctrl.getOrCreatePrivateRoom))
router.get('/rooms/:roomId/messages',     wrap(ctrl.getMessages))
router.get('/rooms/:roomId/members',      wrap(ctrl.getRoomMembers))
router.delete('/rooms/:roomId',           wrap(ctrl.leaveRoom))

module.exports = router
