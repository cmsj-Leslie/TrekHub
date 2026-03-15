/** 用户模型 - 字段：用户名、邮箱、密码、头像、等级、角色(0普通/1管理员)、累计数据 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const User = sequelize.define('User', {
  id:            { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  username:      { type: DataTypes.STRING(30), allowNull: false, unique: true },
  email:         { type: DataTypes.STRING(100), allowNull: false, unique: true },
  password:      { type: DataTypes.STRING(255), allowNull: false },
  avatar:        { type: DataTypes.STRING(500) },
  nickname:      { type: DataTypes.STRING(30) },
  bio:           { type: DataTypes.STRING(300) },
  level:         { type: DataTypes.TINYINT, defaultValue: 1 },
  gender:        { type: DataTypes.TINYINT, defaultValue: 0 },
  role:          { type: DataTypes.TINYINT, defaultValue: 0 }, // 0普通用户 1管理员
  total_km:      { type: DataTypes.DECIMAL(10, 2), defaultValue: 0 },
  total_checkin: { type: DataTypes.INTEGER, defaultValue: 0 }
}, { tableName: 'users', underscored: true })

module.exports = User
