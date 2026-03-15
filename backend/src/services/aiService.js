/**
 * AI 服务层
 * 功能：封装 DeepSeek 大模型 API 调用，管理对话上下文，智能推荐
 */
const axios = require('axios')
const { AiSession } = require('../models')
const aiConfig = require('../config/ai')

// 三种对话场景的系统提示词
const SYSTEM_PROMPTS = {
  route_plan: '你是TrekHub平台专业的徒步路线规划助手。根据用户体能等级(1-5)、偏好地区和技能标签，给出具体的路线规划建议。回答控制在200字内，语言简洁实用。',
  team_match: '你是TrekHub平台的组队助手。根据用户描述帮助分析适合的队友条件或活动。回答控制在150字内。',
  general: '你是TrekHub徒步旅行平台的助手，解答徒步相关问题。回答简洁，不超过200字。'
}

// AI 推荐结果缓存（避免重复调用）
const recommendCache = new Map()

/**
 * 对话式 AI（带上下文记忆）
 * 1. 从数据库拉取历史对话
 * 2. 拼接 system prompt + 历史 + 新消息
 * 3. 调用 DeepSeek API
 * 4. 将新消息和回复存入数据库
 */
async function chat(userId, sessionType, userMessage) {
  if (!SYSTEM_PROMPTS[sessionType]) sessionType = 'general'

  // 拉取已有对话上下文（限制最近 N 条，节省 token）
  let session = await AiSession.findOne({ where: { user_id: userId, session_type: sessionType } })
  const history = session ? (session.messages || []).slice(-aiConfig.maxContextMessages) : []

  // 构造发送给 DeepSeek 的消息数组
  const messages = [
    { role: 'system', content: SYSTEM_PROMPTS[sessionType] },
    ...history,
    { role: 'user', content: userMessage }
  ]

  // 调用 DeepSeek 大模型
  const result = await callDeepSeek(messages)

  // 更新对话上下文（只保留最新 N 条）
  const updated = [...history,
    { role: 'user', content: userMessage },
    { role: 'assistant', content: result.content }
  ].slice(-aiConfig.maxContextMessages)

  // 存入数据库
  if (session) {
    await session.update({ messages: updated, tokens_used: session.tokens_used + result.tokens })
  } else {
    await AiSession.create({ user_id: userId, session_type: sessionType, messages: updated, tokens_used: result.tokens })
  }

  return result.content
}

// 清除用户某类型的对话历史
async function clearSession(userId, sessionType) {
  await AiSession.destroy({ where: { user_id: userId, session_type: sessionType } })
}

/**
 * AI 批量推荐（根据用户画像从候选线路中选出最适合的）
 * 结果缓存30分钟，避免频繁调用
 */
async function generateRecommendations(userProfile, candidateRoutes) {
  const cacheKey = `rec_${userProfile.id}`
  const cached = recommendCache.get(cacheKey)
  if (cached && cached.expireAt > Date.now()) return cached.data

  const prompt = `用户画像：等级${userProfile.level}，地区偏好${userProfile.region || '不限'}，技能${(userProfile.skills || []).join('、')}。
候选线路（JSON）：${JSON.stringify(candidateRoutes.slice(0, 10).map(r => ({ id: r.id, title: r.title, difficulty: r.difficulty, region: r.region, distance_km: r.distance_km })))}
从候选线路中选3条最适合的，返回纯JSON数组：[{"id":1,"reason":"推荐原因，15字内"}]`

  const result = await callDeepSeek([
    { role: 'system', content: '你是徒步路线推荐引擎，只返回JSON，不说多余的话。' },
    { role: 'user', content: prompt }
  ])

  let data = []
  try {
    const jsonStr = result.content.match(/\[[\s\S]*\]/)?.[0]
    data = jsonStr ? JSON.parse(jsonStr) : []
  } catch { data = [] }

  recommendCache.set(cacheKey, { data, expireAt: Date.now() + aiConfig.cacheTTL })
  return data
}

/**
 * 底层 DeepSeek API 调用
 * 使用 OpenAI 兼容的 Chat Completions 接口
 */
async function callDeepSeek(messages) {
  const res = await axios.post(`${aiConfig.baseURL}/v1/chat/completions`, {
    model: aiConfig.model,        // deepseek-chat 模型
    messages,
    max_tokens: aiConfig.maxTokens,
    temperature: 0.7              // 控制回答的随机性
  }, {
    headers: {
      Authorization: `Bearer ${aiConfig.apiKey}`,
      'Content-Type': 'application/json'
    },
    timeout: 15000
  })
  return {
    content: res.data.choices[0].message.content,
    tokens: res.data.usage?.total_tokens || 0
  }
}

module.exports = { chat, clearSession, generateRecommendations }
