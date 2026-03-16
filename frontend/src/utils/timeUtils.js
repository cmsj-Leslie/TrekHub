/**
 * 时间格式化工具模块
 * 功能：提供统一的时间格式化方法，避免各组件重复导入和配置 dayjs
 */
import dayjs from 'dayjs'
import relativeTime from 'dayjs/plugin/relativeTime'
import 'dayjs/locale/zh-cn'

// 统一配置 dayjs 插件和中文语言
dayjs.extend(relativeTime)
dayjs.locale('zh-cn')

/**
 * 智能时间显示
 * - < 1 分钟 → "刚刚"
 * - < 1 小时 → "X 分钟前"
 * - < 24 小时 → "X 小时前"
 * - 今年内 → "MM-DD HH:mm"
 * - 跨年 → "YYYY-MM-DD HH:mm"
 * @param {string|Date} dateStr - 时间字符串或 Date 对象
 * @returns {string} 格式化后的时间文本
 */
export function smartTime(dateStr) {
  if (!dateStr) return ''
  const now = dayjs()
  const d = dayjs(dateStr)
  const diffSec = now.diff(d, 'second')

  if (diffSec < 60) return '刚刚'
  if (diffSec < 3600) return `${Math.floor(diffSec / 60)} 分钟前`
  if (diffSec < 86400) return `${Math.floor(diffSec / 3600)} 小时前`
  if (d.isSame(now, 'year')) return d.format('MM-DD HH:mm')
  return d.format('YYYY-MM-DD HH:mm')
}

/**
 * 标准日期格式化
 * @param {string|Date} dateStr - 时间字符串或 Date 对象
 * @returns {string} "YYYY-MM-DD HH:mm"
 */
export function formatDate(dateStr) {
  return dateStr ? dayjs(dateStr).format('YYYY-MM-DD HH:mm') : '-'
}

/**
 * 短日期格式化（不含年份）
 * @param {string|Date} dateStr - 时间字符串或 Date 对象
 * @returns {string} "MM-DD HH:mm"
 */
export function formatShortDate(dateStr) {
  return dateStr ? dayjs(dateStr).format('MM-DD HH:mm') : '-'
}

export { dayjs }
