/** 随机组队匹配池模型 - 存储匹配偏好：线路、日期、等级范围、技能标签 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const MatchPool = sequelize.define('MatchPool', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false, unique: true },
  route_id:    { type: DataTypes.INTEGER.UNSIGNED },
  prefer_date: { type: DataTypes.DATEONLY },
  min_level:   { type: DataTypes.TINYINT, defaultValue: 1 },
  max_level:   { type: DataTypes.TINYINT, defaultValue: 5 },
  skill_tags:  { type: DataTypes.JSON },
  status:      { type: DataTypes.TINYINT, defaultValue: 1 },
  joined_at:   { type: DataTypes.DATE, defaultValue: DataTypes.NOW }
}, { tableName: 'match_pool', underscored: true, createdAt: 'joined_at', updatedAt: false })

module.exports = MatchPool
