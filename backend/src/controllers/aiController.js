/**
 * AI 控制器
 * 功能：AI 对话（调用 DeepSeek 大模型）、清除对话历史
 */
const aiService = require('../services/aiService')
const { success, fail } = require('../utils/response')

// AI 对话：接收用户消息，调用 DeepSeek 模型返回回复
exports.chat = async (req, res) => {
  const { message, sessionType = 'general' } = req.body
  if (!message?.trim()) return fail(res, '消息不能为空')
  const reply = await aiService.chat(req.user.id, sessionType, message)
  success(res, { reply })
}

// 清除指定类型的对话历史（重新开始对话）
exports.clearSession = async (req, res) => {
  await aiService.clearSession(req.user.id, req.params.type)
  success(res, null, '会话已清除')
}
