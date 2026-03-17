/**
 * 活动评价控制器
 * 功能：提交互评、按活动查看评价、按用户查看收到的评价
 */
const { ActivityReview, Activity, ActivityMember, User } = require('../models')
const { success, created, fail, notFound, forbidden } = require('../utils/response')

// 提交评价（校验：活动已结束、双方都是成员、不能评自己、不能重复评）
exports.create = async (req, res) => {
  const { activity_id, reviewee_id, rating, content } = req.body
  if (!activity_id || !reviewee_id || !rating) return fail(res, '缺少必填字段')
  if (rating < 1 || rating > 5) return fail(res, '评分范围 1~5')
  if (reviewee_id === req.user.id) return fail(res, '不能评价自己')

  // 检查活动是否已结束
  const activity = await Activity.findByPk(activity_id)
  if (!activity) return notFound(res, '活动不存在')
  if (activity.status !== 3) return fail(res, '活动尚未结束，暂不能评价')

  // 检查评价者是否是该活动的已通过成员
  const reviewerMember = await ActivityMember.findOne({
    where: { activity_id, user_id: req.user.id, status: 1 }
  })
  if (!reviewerMember) return forbidden(res, '你不是该活动的成员')

  // 检查被评价者是否是该活动的已通过成员
  const revieweeMember = await ActivityMember.findOne({
    where: { activity_id, user_id: reviewee_id, status: 1 }
  })
  if (!revieweeMember) return fail(res, '被评价者不是该活动的成员')

  // 检查是否已评价过
  const existing = await ActivityReview.findOne({
    where: { activity_id, reviewer_id: req.user.id, reviewee_id }
  })
  if (existing) return fail(res, '已评价过该成员')

  const review = await ActivityReview.create({
    activity_id, reviewer_id: req.user.id, reviewee_id, rating, content
  })
  created(res, review)
}

// 获取某活动的所有评价
exports.getByActivity = async (req, res) => {
  const reviews = await ActivityReview.findAll({
    where: { activity_id: req.params.activityId },
    include: [
      { model: User, as: 'reviewer', attributes: ['id', 'nickname', 'avatar'] },
      { model: User, as: 'reviewee', attributes: ['id', 'nickname', 'avatar'] }
    ],
    order: [['created_at', 'DESC']]
  })
  success(res, reviews)
}

// 获取某用户收到的所有评价（含平均分统计）
exports.getByUser = async (req, res) => {
  const userId = +req.params.userId
  const reviews = await ActivityReview.findAll({
    where: { reviewee_id: userId },
    include: [
      { model: User, as: 'reviewer', attributes: ['id', 'nickname', 'avatar'] },
      { model: Activity, as: 'activity', attributes: ['id', 'title'] }
    ],
    order: [['created_at', 'DESC']]
  })
  // 计算平均评分
  const avgRating = reviews.length
    ? (reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length).toFixed(1)
    : null
  success(res, { avgRating, total: reviews.length, list: reviews })
}
