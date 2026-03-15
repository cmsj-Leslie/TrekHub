/** 用户路由 - 个人资料、密码修改、技能标签、关注/粉丝 */
const express = require('express')
const router = express.Router()
const auth = require('../middleware/auth')
const optionalAuth = require('../middleware/optionalAuth')
const upload = require('../middleware/upload')
const ctrl = require('../controllers/userController')
const wrap = require('../middleware/asyncHandler')

// ⚠️ /me/* 必须在 /:id/* 之前注册，否则 /me 会被当成 id
router.get('/skill-tags',                                wrap(ctrl.getAllSkillTags))
router.get('/me/profile',             auth,             wrap(ctrl.getProfile))
router.put('/me/profile', auth, upload.single('avatar'), wrap(ctrl.updateProfile))
router.put('/me/password',            auth,             wrap(ctrl.updatePassword))
router.put('/me/skills',              auth,             wrap(ctrl.updateSkills))

// 公开的 /:id 路由放后面
router.get('/:id/profile',                              wrap(ctrl.getProfile))
router.get('/:id/skills',                               wrap(ctrl.getUserSkills))

// 关注功能
router.post('/:id/follow',           auth,              wrap(ctrl.toggleFollow))
router.get('/:id/follow-info',       optionalAuth,      wrap(ctrl.getFollowInfo))
router.get('/:id/followers',                            wrap(ctrl.getFollowers))
router.get('/:id/following',                            wrap(ctrl.getFollowing))

module.exports = router

