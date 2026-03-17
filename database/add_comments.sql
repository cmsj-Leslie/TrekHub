SET NAMES utf8mb4;
SET CHARACTER_SET_CLIENT=utf8mb4;
SET CHARACTER_SET_RESULTS=utf8mb4;

-- ============================================
-- TrekHub 数据库表注释 & 字段注释
-- ============================================

-- 1. users 用户表
ALTER TABLE users COMMENT '用户表 - 存储注册用户基本信息';
ALTER TABLE users MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '用户ID（主键）',
  MODIFY username VARCHAR(30) NOT NULL COMMENT '用户名（唯一）',
  MODIFY email VARCHAR(100) NOT NULL COMMENT '邮箱（唯一）',
  MODIFY password VARCHAR(255) NOT NULL COMMENT '密码（bcrypt加密）',
  MODIFY avatar VARCHAR(500) COMMENT '头像URL',
  MODIFY nickname VARCHAR(30) COMMENT '昵称',
  MODIFY bio VARCHAR(300) COMMENT '个人简介',
  MODIFY level TINYINT DEFAULT 1 COMMENT '用户等级（1-5）',
  MODIFY gender TINYINT DEFAULT 0 COMMENT '性别（0未设置/1男/2女）',
  MODIFY role TINYINT DEFAULT 0 COMMENT '角色（0普通用户/1管理员）',
  MODIFY total_km DECIMAL(10,2) DEFAULT 0 COMMENT '累计徒步里程(km)',
  MODIFY total_checkin INT DEFAULT 0 COMMENT '累计打卡次数',
  MODIFY created_at DATETIME COMMENT '注册时间',
  MODIFY updated_at DATETIME COMMENT '更新时间';

-- 2. routes 线路表
ALTER TABLE routes COMMENT '徒步线路表 - 存储用户创建的线路信息';
ALTER TABLE routes MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '线路ID（主键）',
  MODIFY creator_id INT UNSIGNED NOT NULL COMMENT '创建者用户ID',
  MODIFY title VARCHAR(100) NOT NULL COMMENT '线路标题',
  MODIFY description TEXT COMMENT '线路描述',
  MODIFY difficulty TINYINT DEFAULT 2 COMMENT '难度等级（1简单/2中等/3困难/4专家/5极限）',
  MODIFY distance_km DECIMAL(8,2) DEFAULT 0 COMMENT '总距离(km)',
  MODIFY elevation_m INT DEFAULT 0 COMMENT '累计爬升海拔(m)',
  MODIFY duration_h DECIMAL(5,1) DEFAULT 0 COMMENT '预计时长(小时)',
  MODIFY start_lng DECIMAL(11,8) NOT NULL COMMENT '起点经度',
  MODIFY start_lat DECIMAL(10,8) NOT NULL COMMENT '起点纬度',
  MODIFY cover_image VARCHAR(500) COMMENT '封面图片URL',
  MODIFY gpx_path VARCHAR(500) COMMENT 'GPX文件路径',
  MODIFY region VARCHAR(50) COMMENT '所属地区',
  MODIFY tags JSON COMMENT '标签(JSON数组)',
  MODIFY safety_note TEXT COMMENT '安全提示信息',
  MODIFY gear_list VARCHAR(500) COMMENT '建议装备清单',
  MODIFY view_count INT UNSIGNED DEFAULT 0 COMMENT '浏览次数',
  MODIFY like_count INT UNSIGNED DEFAULT 0 COMMENT '收藏次数',
  MODIFY is_public TINYINT(1) DEFAULT 1 COMMENT '是否公开（0私密/1公开）',
  MODIFY status TINYINT DEFAULT 1 COMMENT '状态（0已删除/1正常）',
  MODIFY created_at DATETIME COMMENT '创建时间',
  MODIFY updated_at DATETIME COMMENT '更新时间';

-- 3. route_points 线路坐标点表
ALTER TABLE route_points COMMENT '线路GPS坐标点表 - 存储线路轨迹点序列';
ALTER TABLE route_points MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '坐标点ID（主键）',
  MODIFY route_id INT UNSIGNED NOT NULL COMMENT '所属线路ID',
  MODIFY seq SMALLINT NOT NULL COMMENT '坐标点序号',
  MODIFY lng DECIMAL(11,8) NOT NULL COMMENT '经度',
  MODIFY lat DECIMAL(10,8) NOT NULL COMMENT '纬度',
  MODIFY elevation DECIMAL(7,2) COMMENT '海拔高度(m)';

-- 4. activities 活动表
ALTER TABLE activities COMMENT '徒步活动表 - 存储组队活动信息';
ALTER TABLE activities MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '活动ID（主键）',
  MODIFY route_id INT UNSIGNED NOT NULL COMMENT '关联线路ID',
  MODIFY organizer_id INT UNSIGNED NOT NULL COMMENT '组织者用户ID',
  MODIFY title VARCHAR(100) NOT NULL COMMENT '活动标题',
  MODIFY description TEXT COMMENT '活动描述',
  MODIFY start_time DATETIME NOT NULL COMMENT '活动开始时间',
  MODIFY end_time DATETIME NOT NULL COMMENT '活动结束时间',
  MODIFY max_members TINYINT DEFAULT 10 COMMENT '最大成员数',
  MODIFY current_members TINYINT DEFAULT 1 COMMENT '当前成员数',
  MODIFY min_level TINYINT DEFAULT 1 COMMENT '最低等级要求',
  MODIFY gear_require VARCHAR(500) COMMENT '必备装备要求',
  MODIFY safety_info TEXT COMMENT '安全提示信息',
  MODIFY status TINYINT DEFAULT 1 COMMENT '活动状态（0已取消/1招募中/2已满员/3已结束）',
  MODIFY is_random TINYINT(1) DEFAULT 0 COMMENT '是否随机组队创建（0否/1是）',
  MODIFY created_at DATETIME COMMENT '创建时间',
  MODIFY updated_at DATETIME COMMENT '更新时间';

-- 5. activity_members 活动成员表
ALTER TABLE activity_members COMMENT '活动成员表 - 记录活动参与者及审核状态';
ALTER TABLE activity_members MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '记录ID（主键）',
  MODIFY activity_id INT UNSIGNED NOT NULL COMMENT '所属活动ID',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY role TINYINT DEFAULT 0 COMMENT '角色（0普通成员/1组织者）',
  MODIFY status TINYINT DEFAULT 0 COMMENT '审核状态（0待审核/1已通过/2已拒绝）',
  MODIFY apply_msg VARCHAR(300) COMMENT '申请留言',
  MODIFY joined_at DATETIME COMMENT '加入时间';

-- 6. activity_reviews 活动互评表
ALTER TABLE activity_reviews COMMENT '活动互评表 - 活动结束后参与者互相评价';
ALTER TABLE activity_reviews MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '评价ID（主键）',
  MODIFY activity_id INT UNSIGNED NOT NULL COMMENT '所属活动ID',
  MODIFY reviewer_id INT UNSIGNED NOT NULL COMMENT '评价者用户ID',
  MODIFY reviewee_id INT UNSIGNED NOT NULL COMMENT '被评价者用户ID',
  MODIFY rating TINYINT NOT NULL COMMENT '评分（1-5星）',
  MODIFY content VARCHAR(500) COMMENT '评价内容',
  MODIFY created_at DATETIME COMMENT '评价时间';

-- 7. chat_rooms 聊天室表
ALTER TABLE chat_rooms COMMENT '聊天室表 - 私聊和群聊房间';
ALTER TABLE chat_rooms MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '聊天室ID（主键）',
  MODIFY type TINYINT NOT NULL COMMENT '类型（1私聊/2活动群聊）',
  MODIFY activity_id INT UNSIGNED COMMENT '关联活动ID（群聊时有值）',
  MODIFY name VARCHAR(50) COMMENT '聊天室名称（群聊时有值）',
  MODIFY created_at DATETIME COMMENT '创建时间';

-- 8. room_members 聊天室成员表
ALTER TABLE room_members COMMENT '聊天室成员表 - 记录聊天室的参与用户';
ALTER TABLE room_members MODIFY room_id INT UNSIGNED NOT NULL COMMENT '聊天室ID',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY joined_at DATETIME COMMENT '加入时间';

-- 9. messages 消息表
ALTER TABLE messages COMMENT '聊天消息表 - 存储所有聊天消息记录';
ALTER TABLE messages MODIFY id BIGINT UNSIGNED AUTO_INCREMENT COMMENT '消息ID（主键）',
  MODIFY room_id INT UNSIGNED NOT NULL COMMENT '所属聊天室ID',
  MODIFY sender_id INT UNSIGNED NOT NULL COMMENT '发送者用户ID',
  MODIFY type TINYINT DEFAULT 1 COMMENT '消息类型（1文字/2图片）',
  MODIFY content TEXT NOT NULL COMMENT '消息内容',
  MODIFY is_read TINYINT(1) DEFAULT 0 COMMENT '是否已读（0未读/1已读）',
  MODIFY created_at DATETIME COMMENT '发送时间';

-- 10. comments 评论表
ALTER TABLE comments COMMENT '评论表 - 支持线路和活动的多目标评论，含回复和评分';
ALTER TABLE comments MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '评论ID（主键）',
  MODIFY target_type TINYINT NOT NULL COMMENT '目标类型（1线路/2活动）',
  MODIFY target_id INT UNSIGNED NOT NULL COMMENT '目标ID（线路或活动的ID）',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '评论者用户ID',
  MODIFY parent_id INT UNSIGNED COMMENT '父评论ID（回复时有值）',
  MODIFY content VARCHAR(1000) NOT NULL COMMENT '评论内容',
  MODIFY images JSON COMMENT '评论图片URL数组(JSON)',
  MODIFY rating TINYINT COMMENT '评分（1-5星，线路评价时使用）',
  MODIFY like_count INT UNSIGNED DEFAULT 0 COMMENT '点赞数',
  MODIFY created_at DATETIME COMMENT '评论时间';

-- 11. comment_likes 评论点赞表
ALTER TABLE comment_likes COMMENT '评论点赞表 - 记录用户对评论的点赞';
ALTER TABLE comment_likes MODIFY user_id INT UNSIGNED NOT NULL COMMENT '点赞用户ID',
  MODIFY comment_id INT UNSIGNED NOT NULL COMMENT '评论ID',
  MODIFY created_at DATETIME COMMENT '点赞时间';

-- 12. favorites 收藏表
ALTER TABLE favorites COMMENT '收藏表 - 用户收藏线路或活动的记录';
ALTER TABLE favorites MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '收藏ID（主键）',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY target_type TINYINT NOT NULL COMMENT '目标类型（1线路/2活动）',
  MODIFY target_id INT UNSIGNED NOT NULL COMMENT '目标ID',
  MODIFY created_at DATETIME COMMENT '收藏时间';

-- 13. checkins 打卡表
ALTER TABLE checkins COMMENT '打卡记录表 - 用户徒步打卡签到数据';
ALTER TABLE checkins MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '打卡ID（主键）',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY activity_id INT UNSIGNED COMMENT '关联活动ID',
  MODIFY route_id INT UNSIGNED COMMENT '关联线路ID',
  MODIFY title VARCHAR(100) COMMENT '打卡标题',
  MODIFY content VARCHAR(500) COMMENT '打卡内容',
  MODIFY images JSON COMMENT '打卡图片URL数组(JSON)',
  MODIFY lng DECIMAL(11,8) COMMENT '打卡地点经度',
  MODIFY lat DECIMAL(10,8) COMMENT '打卡地点纬度',
  MODIFY distance_km DECIMAL(8,2) COMMENT '本次徒步距离(km)',
  MODIFY checkin_at DATETIME COMMENT '打卡时间';

-- 14. ai_sessions AI对话会话表
ALTER TABLE ai_sessions COMMENT 'AI对话会话表 - 存储用户与AI助手的对话历史';
ALTER TABLE ai_sessions MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '会话ID（主键）',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY session_type VARCHAR(20) NOT NULL COMMENT '会话类型',
  MODIFY messages JSON NOT NULL COMMENT '对话消息历史(JSON数组)',
  MODIFY tokens_used INT DEFAULT 0 COMMENT '已消耗token数量',
  MODIFY updated_at DATETIME COMMENT '最后更新时间';

-- 15. match_pool 随机组队匹配池表
ALTER TABLE match_pool COMMENT '随机组队匹配池表 - 用户等待匹配队友的偏好设置';
ALTER TABLE match_pool MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '记录ID（主键）',
  MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID（唯一）',
  MODIFY route_id INT UNSIGNED COMMENT '偏好线路ID',
  MODIFY prefer_date DATE COMMENT '偏好出行日期',
  MODIFY min_level TINYINT DEFAULT 1 COMMENT '队友最低等级',
  MODIFY max_level TINYINT DEFAULT 5 COMMENT '队友最高等级',
  MODIFY skill_tags JSON COMMENT '偏好技能标签(JSON数组)',
  MODIFY status TINYINT DEFAULT 1 COMMENT '状态（1等待中/2已匹配）',
  MODIFY joined_at DATETIME COMMENT '加入匹配池时间';

-- 16. skill_tags 技能标签表
ALTER TABLE skill_tags COMMENT '技能标签表 - 可选的徒步技能标签字典';
ALTER TABLE skill_tags MODIFY id INT UNSIGNED AUTO_INCREMENT COMMENT '标签ID（主键）',
  MODIFY name VARCHAR(30) NOT NULL COMMENT '标签名称';

-- 17. user_skills 用户技能关联表
ALTER TABLE user_skills COMMENT '用户技能关联表 - 用户与技能标签的多对多关系';
ALTER TABLE user_skills MODIFY user_id INT UNSIGNED NOT NULL COMMENT '用户ID',
  MODIFY tag_id INT UNSIGNED NOT NULL COMMENT '技能标签ID';

-- 18. user_follows 用户关注关系表
ALTER TABLE user_follows COMMENT '用户关注关系表 - 记录用户间的关注/粉丝关系';
ALTER TABLE user_follows MODIFY follower_id INT UNSIGNED NOT NULL COMMENT '关注者用户ID',
  MODIFY following_id INT UNSIGNED NOT NULL COMMENT '被关注者用户ID',
  MODIFY created_at DATETIME COMMENT '关注时间';
