-- TrekHub 数据库初始化脚本
-- 执行方式: mysql -u root -p123456 < init.sql

CREATE DATABASE IF NOT EXISTS trekhub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE trekhub;

-- 用户表
CREATE TABLE IF NOT EXISTS users (
  id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(30)   NOT NULL UNIQUE,
  email         VARCHAR(100)  NOT NULL UNIQUE,
  password      VARCHAR(255)  NOT NULL,
  avatar        VARCHAR(500)  DEFAULT NULL,
  nickname      VARCHAR(30)   DEFAULT NULL,
  bio           VARCHAR(300)  DEFAULT NULL,
  level         TINYINT       DEFAULT 1,
  gender        TINYINT       DEFAULT 0,
  total_km      DECIMAL(10,2) DEFAULT 0,
  total_checkin INT           DEFAULT 0,
  created_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 技能标签表
CREATE TABLE IF NOT EXISTS skill_tags (
  id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30)  NOT NULL UNIQUE,
  icon VARCHAR(100) DEFAULT NULL
);

-- 预置技能标签
INSERT IGNORE INTO skill_tags (name, icon) VALUES
  ('高山穿越', 'mountain'), ('溯溪', 'water'), ('攀岩', 'climbing'),
  ('野营', 'tent'), ('定向越野', 'compass'), ('雪地行走', 'snow'),
  ('丛林穿越', 'forest'), ('长距徒步', 'boot'), ('摄影', 'camera'),
  ('急救', 'firstaid');

-- 用户技能关联表
CREATE TABLE IF NOT EXISTS user_skills (
  user_id INT UNSIGNED NOT NULL,
  tag_id  INT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, tag_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (tag_id)  REFERENCES skill_tags(id) ON DELETE CASCADE
);

-- 用户关注表
CREATE TABLE IF NOT EXISTS user_follows (
  follower_id  INT UNSIGNED NOT NULL,
  following_id INT UNSIGNED NOT NULL,
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, following_id),
  FOREIGN KEY (follower_id)  REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (following_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 线路表
CREATE TABLE IF NOT EXISTS routes (
  id           INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  creator_id   INT UNSIGNED  NOT NULL,
  title        VARCHAR(100)  NOT NULL,
  description  TEXT          DEFAULT NULL,
  difficulty   TINYINT       NOT NULL DEFAULT 2,
  distance_km  DECIMAL(8,2)  DEFAULT 0,
  elevation_m  INT           DEFAULT 0,
  duration_h   DECIMAL(5,1)  DEFAULT 0,
  start_lng    DECIMAL(11,8) NOT NULL,
  start_lat    DECIMAL(10,8) NOT NULL,
  cover_image  VARCHAR(500)  DEFAULT NULL,
  gpx_path     VARCHAR(500)  DEFAULT NULL,
  region       VARCHAR(50)   DEFAULT NULL,
  tags         JSON          DEFAULT NULL,
  view_count   INT UNSIGNED  DEFAULT 0,
  like_count   INT UNSIGNED  DEFAULT 0,
  is_public    TINYINT(1)    DEFAULT 1,
  status       TINYINT       DEFAULT 1,
  created_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_difficulty (difficulty),
  INDEX idx_region (region),
  INDEX idx_creator (creator_id)
);

-- 线路坐标点表
CREATE TABLE IF NOT EXISTS route_points (
  id        INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  route_id  INT UNSIGNED  NOT NULL,
  seq       SMALLINT      NOT NULL,
  lng       DECIMAL(11,8) NOT NULL,
  lat       DECIMAL(10,8) NOT NULL,
  elevation DECIMAL(7,2)  DEFAULT NULL,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE,
  INDEX idx_route (route_id)
);

-- 活动表
CREATE TABLE IF NOT EXISTS activities (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  route_id        INT UNSIGNED NOT NULL,
  organizer_id    INT UNSIGNED NOT NULL,
  title           VARCHAR(100) NOT NULL,
  description     TEXT         DEFAULT NULL,
  start_time      DATETIME     NOT NULL,
  end_time        DATETIME     NOT NULL,
  max_members     TINYINT      DEFAULT 10,
  current_members TINYINT      DEFAULT 1,
  min_level       TINYINT      DEFAULT 1,
  gear_require    VARCHAR(500) DEFAULT NULL,
  safety_info     TEXT         DEFAULT NULL,
  status          TINYINT      DEFAULT 1,
  is_random       TINYINT(1)   DEFAULT 0,
  created_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (route_id)     REFERENCES routes(id),
  FOREIGN KEY (organizer_id) REFERENCES users(id),
  INDEX idx_status (status),
  INDEX idx_start_time (start_time)
);

-- 活动成员表
CREATE TABLE IF NOT EXISTS activity_members (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  activity_id INT UNSIGNED NOT NULL,
  user_id     INT UNSIGNED NOT NULL,
  role        TINYINT      DEFAULT 0,
  status      TINYINT      DEFAULT 0,
  apply_msg   VARCHAR(300) DEFAULT NULL,
  joined_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_activity_user (activity_id, user_id),
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE
);

-- 聊天室表
CREATE TABLE IF NOT EXISTS chat_rooms (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  type        TINYINT      NOT NULL,
  activity_id INT UNSIGNED DEFAULT NULL,
  name        VARCHAR(50)  DEFAULT NULL,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE SET NULL
);

-- 聊天室成员表
CREATE TABLE IF NOT EXISTS room_members (
  room_id   INT UNSIGNED NOT NULL,
  user_id   INT UNSIGNED NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (room_id, user_id),
  FOREIGN KEY (room_id) REFERENCES chat_rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE
);

-- 消息表
CREATE TABLE IF NOT EXISTS messages (
  id         BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  room_id    INT UNSIGNED    NOT NULL,
  sender_id  INT UNSIGNED    NOT NULL,
  type       TINYINT         DEFAULT 1,
  content    TEXT            NOT NULL,
  is_read    TINYINT(1)      DEFAULT 0,
  created_at TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (room_id)   REFERENCES chat_rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (sender_id) REFERENCES users(id),
  INDEX idx_room_time (room_id, created_at)
);

-- 评论表
CREATE TABLE IF NOT EXISTS comments (
  id          INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  target_type TINYINT       NOT NULL,
  target_id   INT UNSIGNED  NOT NULL,
  user_id     INT UNSIGNED  NOT NULL,
  parent_id   INT UNSIGNED  DEFAULT NULL,
  content     VARCHAR(1000) NOT NULL,
  images      JSON          DEFAULT NULL,
  rating      TINYINT       DEFAULT NULL,
  like_count  INT UNSIGNED  DEFAULT 0,
  created_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE SET NULL,
  INDEX idx_target (target_type, target_id),
  INDEX idx_parent (parent_id)
);

-- 收藏表
CREATE TABLE IF NOT EXISTS favorites (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL,
  target_type TINYINT      NOT NULL,
  target_id   INT UNSIGNED NOT NULL,
  created_at  TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_fav (user_id, target_type, target_id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_type (user_id, target_type)
);

-- 打卡表
CREATE TABLE IF NOT EXISTS checkins (
  id          INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED  NOT NULL,
  activity_id INT UNSIGNED  DEFAULT NULL,
  route_id    INT UNSIGNED  DEFAULT NULL,
  title       VARCHAR(100)  DEFAULT NULL,
  content     VARCHAR(500)  DEFAULT NULL,
  images      JSON          DEFAULT NULL,
  lng         DECIMAL(11,8) DEFAULT NULL,
  lat         DECIMAL(10,8) DEFAULT NULL,
  distance_km DECIMAL(8,2)  DEFAULT NULL,
  checkin_at  TIMESTAMP     DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)     REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE SET NULL,
  FOREIGN KEY (route_id)    REFERENCES routes(id) ON DELETE SET NULL,
  INDEX idx_user (user_id),
  INDEX idx_date (checkin_at)
);

-- AI 会话缓存表
CREATE TABLE IF NOT EXISTS ai_sessions (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id      INT UNSIGNED NOT NULL,
  session_type VARCHAR(20)  NOT NULL,
  messages     JSON         NOT NULL,
  tokens_used  INT          DEFAULT 0,
  updated_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_type (user_id, session_type),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 随机组队池
CREATE TABLE IF NOT EXISTS match_pool (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id     INT UNSIGNED NOT NULL UNIQUE,
  route_id    INT UNSIGNED DEFAULT NULL,
  prefer_date DATE         DEFAULT NULL,
  min_level   TINYINT      DEFAULT 1,
  max_level   TINYINT      DEFAULT 5,
  skill_tags  JSON         DEFAULT NULL,
  status      TINYINT      DEFAULT 1,
  joined_at   TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id)  REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE SET NULL
);
