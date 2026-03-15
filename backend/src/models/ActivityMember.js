/** 活动成员模型 - 字段：用户ID、角色(0普通/1组织者)、状态(0待审核/1通过/2拒绝)、申请留言 */
const { DataTypes } = require('sequelize')
const sequelize = require('../config/db')

const ActivityMember = sequelize.define('ActivityMember', {
  id:          { type: DataTypes.INTEGER.UNSIGNED, primaryKey: true, autoIncrement: true },
  activity_id: { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  user_id:     { type: DataTypes.INTEGER.UNSIGNED, allowNull: false },
  role:        { type: DataTypes.TINYINT, defaultValue: 0 },
  status:      { type: DataTypes.TINYINT, defaultValue: 0 },
  apply_msg:   { type: DataTypes.STRING(300) }
  // 修复：joined_at 是 DB 的实际列名，通过 createdAt 映射
}, { tableName: 'activity_members', underscored: true, createdAt: 'joined_at', updatedAt: false })

module.exports = ActivityMember
