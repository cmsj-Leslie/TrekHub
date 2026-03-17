/** 活动评价模型 - 活动结束后参与者互评，字段：活动ID、评价者、被评价者、评分、评语 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const ActivityReview = sequelize.define('ActivityReview', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  activity_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  reviewer_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  reviewee_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  rating:      { type: DataTypes.TINYINT, allowNull: false, validate: { min: 1, max: 5 } },
  content:     { type: DataTypes.STRING(500) }
}, {
  tableName: 'activity_reviews',
  underscored: true,
  updatedAt: false,
  indexes: [
    { unique: true, fields: ['activity_id', 'reviewer_id', 'reviewee_id'] } // 同一活动中对同一人只能评一次
  ]
})

module.exports = ActivityReview
