/** 活动模型 - 字段：标题、线路、时间、人数限制、装备要求、安全提示、状态(1招募/2满员/3结束) */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Activity = sequelize.define('Activity', {
  id:              { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  route_id:        { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  organizer_id:    { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  title:           { type: DataTypes.STRING(100), allowNull: false },
  description:     { type: DataTypes.TEXT },
  start_time:      { type: DataTypes.DATE, allowNull: false },
  end_time:        { type: DataTypes.DATE, allowNull: false },
  max_members:     { type: DataTypes.TINYINT, defaultValue: 10 },
  current_members: { type: DataTypes.TINYINT, defaultValue: 1 },
  min_level:       { type: DataTypes.TINYINT, defaultValue: 1 },
  gear_require:    { type: DataTypes.STRING(500) },
  safety_info:     { type: DataTypes.TEXT },
  status:          { type: DataTypes.TINYINT, defaultValue: 1 },
  is_random:       { type: DataTypes.TINYINT(1), defaultValue: 0 }
}, { tableName: 'activities', underscored: true })

module.exports = Activity
