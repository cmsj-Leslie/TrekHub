/**
 * 数据库配置（Sequelize ORM）
 * 功能：创建 MySQL 数据库连接实例，所有参数从 .env 读取
 */
const { Sequelize } = require('sequelize')
require('dotenv').config()

const sequelize = new Sequelize(
  process.env.DB_NAME,   // 数据库名
  process.env.DB_USER,   // 用户名
  process.env.DB_PASS,   // 密码
  {
    host: process.env.DB_HOST,     // 主机地址
    port: process.env.DB_PORT,     // 端口号
    dialect: 'mysql',              // 数据库类型
    logging: false,                // 关闭 SQL 日志输出
    timezone: '+08:00',            // 东八区时区
    define: { charset: 'utf8mb4', collate: 'utf8mb4_unicode_ci' },  // 支持 emoji
    dialectOptions: { charset: 'utf8mb4' },
    pool: { max: 10, min: 0, acquire: 30000, idle: 10000 }  // 连接池配置
  }
)

module.exports = sequelize
