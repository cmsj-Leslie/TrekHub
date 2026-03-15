/**
 * 用户相关 API
 * 功能：登录注册、个人资料管理、密码修改、技能标签、关注/粉丝系统
 */
import request from './request'

// 登录（支持用户名或邮箱）
export const login          = (data)   => request.post('/auth/login', data)
// 注册新用户
export const register       = (data)   => request.post('/auth/register', data)
// 获取用户资料（传 id 查他人，不传查自己）
export const getProfile     = (id)     => request.get(id ? `/users/${id}/profile` : '/users/me/profile')
// 更新个人资料（昵称、简介、头像等）
export const updateProfile  = (data)   => request.put('/users/me/profile', data)
// 修改密码
export const updatePassword = (data)   => request.put('/users/me/password', data)
// 更新技能标签
export const updateSkills   = (data)   => request.put('/users/me/skills', data)
// 获取某用户的技能标签
export const getUserSkills  = (id)     => request.get(`/users/${id}/skills`)
// 获取所有可选技能标签（下拉列表用）
export const getAllSkillTags = ()       => request.get('/users/skill-tags')

// ===== 关注系统 =====
// 关注/取消关注
export const toggleFollow   = (id)     => request.post(`/users/${id}/follow`)
// 获取关注信息（粉丝数、关注数、是否已关注）
export const getFollowInfo  = (id)     => request.get(`/users/${id}/follow-info`)
// 获取粉丝列表
export const getFollowers   = (id)     => request.get(`/users/${id}/followers`)
// 获取关注列表
export const getFollowing   = (id)     => request.get(`/users/${id}/following`)

