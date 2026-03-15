/** 消息模型 - 聊天消息，类型(1文字/2图片)，含已读标记 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const Message = sequelize.define('Message', {
  id:        { type: DataTypes.BIGINT.UNSIGNED, primaryKey: true, autoIncrement: true },
  room_id:   { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  sender_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  type:      { type: DataTypes.TINYINT, defaultValue: 1 },
  content:   { type: DataTypes.TEXT, allowNull: false },
  is_read:   { type: DataTypes.TINYINT(1), defaultValue: 0 }
}, { tableName: 'messages', underscored: true, updatedAt: false })

module.exports = Message
