/**
 * DeepSeek AI 配置
 * 功能：AI 大模型 API 连接参数，从 .env 读取密钥
 */
require('dotenv').config()

module.exports = {
  apiKey: process.env.DEEPSEEK_API_KEY,    // API 密钥
  baseURL: process.env.DEEPSEEK_BASE_URL,  // API 地址（https://api.deepseek.com）
  model: 'deepseek-chat',                  // 使用的模型（DeepSeek-V3 对话模型）
  maxTokens: 300,                          // 单次回复最大 token 数
  maxContextMessages: 6,                   // 上下文保留最近6条消息（3轮对话）
  cacheTTL: 30 * 60 * 1000                 // 推荐结果缓存时间（30分钟）
}
