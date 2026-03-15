/** AI对话会话模型 - 存储用户与DeepSeek的对话历史(JSON)和token用量 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const AiSession = sequelize.define('AiSession', {
  id:           { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  user_id:      { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  session_type: { type: DataTypes.STRING(20), allowNull: false },
  messages:     { type: DataTypes.JSON, allowNull: false, defaultValue: [] },
  tokens_used:  { type: DataTypes.INTEGER, defaultValue: 0 }
}, { tableName: 'ai_sessions', underscored: true, createdAt: false })

module.exports = AiSession
