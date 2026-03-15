/**
 * 后台管理 API
 * 功能：统计面板、用户管理、线路管理、评论管理（需管理员权限）
 */
import request from './request'

// ===== 公开接口 =====
// 获取首页展示的公开统计数据（用户数、线路数等）
export const getPublicStats  = ()       => request.get('/admin/public-stats')

// ===== 管理员接口 =====
// 获取管理后台统计面板数据
export const getAdminStats  = ()       => request.get('/admin/stats')
// 获取用户列表（支持分页和搜索）
export const getAdminUsers  = (params) => request.get('/admin/users', { params })
// 修改用户角色（0普通用户/1管理员）
export const updateUserRole = (id, role) => request.put(`/admin/users/${id}/role`, { role })
// 编辑用户信息（昵称、简介、等级等）
export const adminUpdateUser = (id, data) => request.put(`/admin/users/${id}`, data)
// 获取线路管理列表
export const getAdminRoutes  = (params) => request.get('/admin/routes', { params })
// 编辑线路信息
export const adminUpdateRoute = (id, data) => request.put(`/admin/routes/${id}`, data)
// 删除线路
export const adminDeleteRoute  = (id) => request.delete(`/admin/routes/${id}`)
// 获取评论管理列表
export const getAdminComments = (params) => request.get('/admin/comments', { params })
// 删除评论
export const adminDeleteComment = (id) => request.delete(`/admin/comments/${id}`)
