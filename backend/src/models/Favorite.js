/** 收藏模型 - 多态收藏(target_type: 1线路/2活动) */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Favorite = sequelize.define('Favorite', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  target_type: { type: DataTypes.TINYINT, allowNull: false },
  target_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false }
}, { tableName: 'favorites', underscored: true, updatedAt: false })

module.exports = Favorite
