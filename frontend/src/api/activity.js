/**
 * 活动相关 API
 * 功能：活动列表、详情、创建、申请参加、组织者审批、我的活动
 */
import request from './request'

// 获取活动列表（支持分页、状态筛选、关键字搜索）
export const getActivities   = (params) => request.get('/activities', { params })
// 获取活动详情（含成员列表、关联线路、群聊ID）
export const getActivity     = (id)     => request.get(`/activities/${id}`)
// 发布新活动
export const createActivity  = (data)   => request.post('/activities', data)
// 申请参加活动（可附带申请留言）
export const applyActivity   = (id, data) => request.post(`/activities/${id}/apply`, data)
// 组织者审批成员（通过/拒绝）
export const reviewMember    = (data)   => request.post('/activities/review-member', data)
// 获取我参加的所有活动
export const myActivities    = ()       => request.get('/activities/me/list')
