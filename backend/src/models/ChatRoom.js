/** 聊天室模型 - 类型(1私聊/2群聊)、关联活动ID、房间名称 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const ChatRoom = sequelize.define('ChatRoom', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  type:        { type: DataTypes.TINYINT, allowNull: false },
  activity_id: { type: DataTypes.INTEGER.UNSIGNED },
  name:        { type: DataTypes.STRING(50) }
}, { tableName: 'chat_rooms', underscored: true, updatedAt: false })

module.exports = ChatRoom
