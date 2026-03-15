/** 打卡记录模型 - 字段：标题、内容、图片(JSON)、GPS坐标、距离 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Checkin = sequelize.define('Checkin', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  activity_id: { type: DataTypes.INTEGER.UNSIGNED },
  route_id:    { type: DataTypes.INTEGER.UNSIGNED },
  title:       { type: DataTypes.STRING(100) },
  content:     { type: DataTypes.STRING(500) },
  images:      { type: DataTypes.JSON },
  lng:         { type: DataTypes.DECIMAL(11, 8) },
  lat:         { type: DataTypes.DECIMAL(10, 8) },
  distance_km: { type: DataTypes.DECIMAL(8, 2) }
  // 修复：移除 checkin_at 字段定义，由 createdAt:'checkin_at' 统一管理，避免冲突
}, { tableName: 'checkins', underscored: true, createdAt: 'checkin_at', updatedAt: false })

module.exports = Checkin
