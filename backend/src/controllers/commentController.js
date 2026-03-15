/**
 * 评论控制器
 * 功能：评论列表（含子回复）、发表评论、删除评论、点赞
 */
const { Comment, User } = require('../models')
const { success, created, fail, notFound, forbidden } = require('../utils/response')

// 获取评论列表（支持按目标类型和ID查询，含子评论）
exports.list = async (req, res) => {
  const { target_type, target_id, page = 1, pageSize = 20 } = req.query
  if (!target_type || !target_id) return fail(res, '缺少参数')
  const { count, rows } = await Comment.findAndCountAll({
    where: { target_type, target_id, parent_id: null }, // 只查顶级评论
    order: [['created_at', 'DESC']],
    limit: +pageSize, offset: (page - 1) * pageSize,
    include: [
      { model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] },
      { model: Comment, as: 'replies', limit: 3, // 每条评论最多展示3条回复
        include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] }] }
    ]
  })
  success(res, { total: count, list: rows })
}

// 发表评论（支持回复、评分、图片）
exports.create = async (req, res) => {
  const { target_type, target_id, content, parent_id, rating, images } = req.body
  if (!content?.trim()) return fail(res, '评论内容不能为空')
  const comment = await Comment.create({ target_type, target_id, user_id: req.user.id, content, parent_id, rating, images })
  const full = await Comment.findByPk(comment.id, {
    include: [{ model: User, as: 'user', attributes: ['id', 'nickname', 'avatar'] }]
  })
  created(res, full)
}

// 删除评论（仅评论作者可删除）
exports.remove = async (req, res) => {
  const comment = await Comment.findByPk(req.params.id)
  if (!comment) return notFound(res)
  if (comment.user_id !== req.user.id) return forbidden(res)
  await comment.destroy()
  success(res, null, '删除成功')
}

// 点赞评论
exports.like = async (req, res) => {
  const comment = await Comment.findByPk(req.params.id)
  if (!comment) return notFound(res)
  await comment.increment('like_count')
  success(res, { like_count: comment.like_count + 1 })
}
