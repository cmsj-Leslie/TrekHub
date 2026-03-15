/**
 * 线路控制器
 * 功能：线路CRUD、GPX文件上传解析、AI智能推荐
 */
const { Route, RoutePoint, User, Favorite } = require('../models')
const { Op } = require('sequelize')
const { success, created, fail, notFound, forbidden } = require('../utils/response')
const recommendService = require('../services/recommendService')

// 线路列表（支持难度、地区、关键字筛选，支持排序）
exports.list = async (req, res) => {
  const { page = 1, pageSize = 12, difficulty, region, keyword, sort = 'created_at' } = req.query
  const where = { status: 1, is_public: 1 }
  if (difficulty) where.difficulty = difficulty
  if (region) where.region = { [Op.like]: `%${region}%` }
  if (keyword) where.title = { [Op.like]: `%${keyword}%` }
  // 排序方式：最新(默认) / 最热 / 难度
  let order
  if (sort === 'hot') order = [['like_count', 'DESC']]
  else if (sort === 'difficulty') order = [['difficulty', 'DESC']]
  else order = [['created_at', 'DESC']]
  const { count, rows } = await Route.findAndCountAll({
    where, order, limit: +pageSize, offset: (page - 1) * pageSize,
    include: [{ model: User, as: 'creator', attributes: ['id', 'nickname', 'avatar'] }]
  })
  success(res, { total: count, list: rows, page: +page, pageSize: +pageSize })
}

// AI 智能推荐线路（基于用户画像和协同过滤算法）
exports.recommended = async (req, res) => {
  const routes = await recommendService.getRecommendedRoutes(req.user.id, 10)
  success(res, routes)
}

// 线路详情（含 GPS 坐标点，用于地图展示）
exports.detail = async (req, res) => {
  const route = await Route.findByPk(req.params.id, {
    include: [
      { model: User, as: 'creator', attributes: ['id', 'nickname', 'avatar'] },
      { model: RoutePoint, as: 'points', order: [['seq', 'ASC']] } // 按顺序返回轨迹点
    ]
  })
  if (!route) return notFound(res)
  await route.increment('view_count') // 浏览量+1
  // 检查当前用户是否已收藏此线路
  let isFavorited = false
  if (req.user) {
    const fav = await Favorite.findOne({ where: { user_id: req.user.id, target_type: 1, target_id: route.id } })
    isFavorited = !!fav
  }
  success(res, { ...route.toJSON(), isFavorited })
}

// 创建线路（含坐标点批量插入）
exports.create = async (req, res) => {
  const { title, description, difficulty, distance_km, elevation_m, duration_h, start_lng, start_lat, region, tags, points } = req.body
  if (!title || !start_lng || !start_lat) return fail(res, '缺少必填字段')
  const route = await Route.create({
    creator_id: req.user.id, title, description, difficulty, distance_km, elevation_m,
    duration_h, start_lng, start_lat, region, tags,
    cover_image: req.file ? `/uploads/images/${req.file.filename}` : null
  })
  // 批量插入 GPS 坐标点
  if (points?.length) {
    const pointData = points.map((p, i) => ({ route_id: route.id, seq: i, lng: p.lng, lat: p.lat, elevation: p.elevation }))
    await RoutePoint.bulkCreate(pointData)
  }
  created(res, route)
}

// 更新线路（仅创建者可操作）
exports.update = async (req, res) => {
  const route = await Route.findByPk(req.params.id)
  if (!route) return notFound(res)
  if (route.creator_id !== req.user.id) return forbidden(res)
  const allowed = ['title', 'description', 'difficulty', 'distance_km', 'elevation_m', 'duration_h', 'region', 'tags', 'is_public']
  const update = {}
  allowed.forEach(k => { if (req.body[k] !== undefined) update[k] = req.body[k] })
  if (req.file) update.cover_image = `/uploads/images/${req.file.filename}`
  await route.update(update)
  success(res, route)
}

// 删除线路（软删除，设置 status=0）
exports.remove = async (req, res) => {
  const route = await Route.findByPk(req.params.id)
  if (!route) return notFound(res)
  if (route.creator_id !== req.user.id) return forbidden(res)
  await route.update({ status: 0 })
  success(res, null, '删除成功')
}

// 上传 GPX 文件，解析提取坐标点
exports.uploadGpx = async (req, res) => {
  if (!req.file) return fail(res, '请上传GPX文件')
  const fs = require('fs')
  const content = fs.readFileSync(req.file.path, 'utf8')
  const points = []
  // 用正则提取 GPX 文件中的经纬度和海拔
  const trkptReg = /<trkpt lat="([\d.]+)" lon="([\d.]+)"[\s\S]*?(?:<ele>([\d.]+)<\/ele>)?[\s\S]*?<\/trkpt>/g
  let m
  while ((m = trkptReg.exec(content)) !== null) {
    points.push({ lat: parseFloat(m[1]), lng: parseFloat(m[2]), elevation: m[3] ? parseFloat(m[3]) : null })
  }
  success(res, { gpxPath: `/uploads/gpx/${req.file.filename}`, points })
}
