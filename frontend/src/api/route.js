/**
 * 线路相关 API
 * 功能：线路增删改查、GPX轨迹上传、AI智能推荐
 */
import request from './request'

// 获取线路列表（支持分页、难度筛选、关键字搜索）
export const getRoutes      = (params) => request.get('/routes', { params })
// 获取线路详情（含坐标点、创建者信息）
export const getRoute       = (id)     => request.get(`/routes/${id}`)
// 获取AI推荐线路（基于用户画像）
export const getRecommended = ()       => request.get('/routes/me/recommended')
// 创建新线路
export const createRoute    = (data)   => request.post('/routes', data)
// 更新线路信息
export const updateRoute    = (id, data) => request.put(`/routes/${id}`, data)
// 删除线路（软删除）
export const removeRoute    = (id)     => request.delete(`/routes/${id}`)
// 上传GPX轨迹文件并解析坐标
export const uploadGpx      = (data)   => request.post('/routes/gpx/upload', data)
