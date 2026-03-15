/**
 * 文件上传中间件（基于 Multer）
 * 功能：处理图片和 GPX 文件上传，自动生成唯一文件名
 */
const multer = require('multer')
const path = require('path')
const fs = require('fs')

// 确保上传目录存在
const uploadDir = path.join(__dirname, '../../uploads')
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir, { recursive: true })

// 配置存储方式：按文件类型分目录（gpx 或 images）
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(uploadDir, file.fieldname === 'gpx' ? 'gpx' : 'images')
    if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true })
    cb(null, dir)
  },
  // 文件名：时间戳 + 随机字符串 + 原扩展名（避免重名）
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname)
    cb(null, `${Date.now()}_${Math.random().toString(36).slice(2)}${ext}`)
  }
})

// 文件类型过滤：只允许图片和 GPX 文件
const fileFilter = (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.webp', '.gif', '.gpx']
  cb(null, allowed.includes(path.extname(file.originalname).toLowerCase()))
}

// 导出 multer 实例，限制文件大小 10MB
module.exports = multer({ storage, fileFilter, limits: { fileSize: 10 * 1024 * 1024 } })
