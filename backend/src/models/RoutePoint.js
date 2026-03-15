/** 线路坐标点模型 - 存储GPS轨迹点(经度、纬度、海拔)，按seq排序 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const RoutePoint = sequelize.define('RoutePoint', {
  id:        { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  route_id:  { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  seq:       { type: DataTypes.SMALLINT, allowNull: false },
  lng:       { type: DataTypes.DECIMAL(11, 8), allowNull: false },
  lat:       { type: DataTypes.DECIMAL(10, 8), allowNull: false },
  elevation: { type: DataTypes.DECIMAL(7, 2) }
}, { tableName: 'route_points', underscored: true, timestamps: false })

module.exports = RoutePoint
