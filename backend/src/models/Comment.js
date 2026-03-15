/** 评论模型 - 支持线路和活动的多目标评论，含子回复(parent_id)、评分、点赞 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Comment = sequelize.define('Comment', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  target_type: { type: DataTypes.TINYINT, allowNull: false },
  target_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  parent_id:   { type: DataTypes.INTEGER.UNSIGNED },
  content:     { type: DataTypes.STRING(1000), allowNull: false },
  images:      { type: DataTypes.JSON },
  rating:      { type: DataTypes.TINYINT },
  like_count:  { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 }
}, { tableName: 'comments', underscored: true, updatedAt: false })

module.exports = Comment
