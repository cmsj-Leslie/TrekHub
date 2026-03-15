/** 线路模型 - 字段：标题、难度、距离、海拔、时长、GPS起点、封面、浏览量、收藏量 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Route = sequelize.define('Route', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  creator_id:  { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  title:       { type: DataTypes.STRING(100), allowNull: false },
  description: { type: DataTypes.TEXT },
  difficulty:  { type: DataTypes.TINYINT, defaultValue: 2 },
  distance_km: { type: DataTypes.DECIMAL(8, 2), defaultValue: 0 },
  elevation_m: { type: DataTypes.INTEGER, defaultValue: 0 },
  duration_h:  { type: DataTypes.DECIMAL(5, 1), defaultValue: 0 },
  start_lng:   { type: DataTypes.DECIMAL(11, 8), allowNull: false },
  start_lat:   { type: DataTypes.DECIMAL(10, 8), allowNull: false },
  cover_image: { type: DataTypes.STRING(500) },
  gpx_path:    { type: DataTypes.STRING(500) },
  region:      { type: DataTypes.STRING(50) },
  tags:        { type: DataTypes.JSON },
  view_count:  { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
  like_count:  { type: DataTypes.INTEGER.UNSIGNED, defaultValue: 0 },
  is_public:   { type: DataTypes.TINYINT(1), defaultValue: 1 },
  status:      { type: DataTypes.TINYINT, defaultValue: 1 }
}, { tableName: 'routes', underscored: true })

module.exports = Route
