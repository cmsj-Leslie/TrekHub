/*
 Navicat Premium Dump SQL

 Source Server         : Database
 Source Server Type    : MySQL
 Source Server Version : 80042 (8.0.42)
 Source Host           : localhost:3306
 Source Schema         : trekhub

 Target Server Type    : MySQL
 Target Server Version : 80042 (8.0.42)
 File Encoding         : 65001

 Date: 21/03/2026 15:38:49
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for activities
-- ----------------------------
DROP TABLE IF EXISTS `activities`;
CREATE TABLE `activities`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '活动ID（主键）',
  `route_id` int UNSIGNED NOT NULL COMMENT '关联线路ID',
  `organizer_id` int UNSIGNED NOT NULL COMMENT '组织者用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '活动标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '活动描述',
  `start_time` datetime NOT NULL COMMENT '活动开始时间',
  `end_time` datetime NOT NULL COMMENT '活动结束时间',
  `max_members` tinyint NULL DEFAULT 10 COMMENT '最大成员数',
  `current_members` tinyint NULL DEFAULT 1 COMMENT '当前成员数',
  `min_level` tinyint NULL DEFAULT 1 COMMENT '最低等级要求',
  `gear_require` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '必备装备要求',
  `safety_info` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '安全提示信息',
  `status` tinyint NULL DEFAULT 1 COMMENT '活动状态（0已取消/1招募中/2已满员/3已结束）',
  `is_random` tinyint(1) NULL DEFAULT 0 COMMENT '是否随机组队创建（0否/1是）',
  `created_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `route_id`(`route_id` ASC) USING BTREE,
  INDEX `organizer_id`(`organizer_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_start_time`(`start_time` ASC) USING BTREE,
  CONSTRAINT `activities_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activities_ibfk_2` FOREIGN KEY (`organizer_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '徒步活动表 - 存储组队活动信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activities
-- ----------------------------
INSERT INTO `activities` VALUES (1, 4, 2, '亚丁牛奶海两日营地活动', '计划从洛绒牛场扎营，次日凌晨3点出发拍牛奶海日出，限额8人。需自带睡袋、防潮垫，营地提供帐篷租借。', '2026-03-30 18:36:02', '2026-04-01 18:36:02', 8, 4, 3, '保暖层（抓绒+羽绒）、防水冲锋衣、登山杖、头灯（必备）、高原药品', '亚丁海拔4000m+，高反风险高，心肺疾病患者禁止参与。下撤路线：洛绒牛场沿原路返回稻城县医院约3小时车程。紧急联系：四川省登山协会救援队。', 1, 0, '2026-03-15 18:36:02', '2026-03-17 17:40:16');
INSERT INTO `activities` VALUES (2, 7, 3, '梅里雪山雨崩村3日秘境探访', '飞来寺出发徒步至雨崩村，内转经线含神瀑+冰湖全程游览，住雨崩村传统客栈。名额6人，需有中级徒步经验。', '2026-04-04 18:36:02', '2026-04-07 18:36:02', 6, 2, 3, '冲锋衣裤、登山鞋、登山杖、保暖层、头灯、急救包', '梅里雪山地区天气多变，禁止在神山区域大声喧哗。卡瓦格博峰禁止攀登。下撤路线：飞来寺214国道，就近前往德钦县医院。', 1, 0, '2026-03-15 18:36:02', '2026-03-15 18:36:02');
INSERT INTO `activities` VALUES (3, 12, 4, '珠峰大本营摄影+加乌拉山口5日行', '专为摄影爱好者设计，加乌拉山口日出拍珠峰北坡全景，大本营扎营两晚。需自备相机云台、备用电池（低温耗电快）。限额5人。', '2026-04-14 18:36:02', '2026-04-19 18:36:02', 5, 1, 4, '羽绒服（-20℃以上）、高山睡袋、冰爪（防滑用）、护目镜、防晒霜SPF50+', '海拔5000m+区域，严禁有心脏病、高血压史者参与。需在拉萨适应至少5天。下撤路线：原路返回定日县，县医院有高压氧舱。', 1, 0, '2026-03-15 18:36:02', '2026-03-15 18:36:02');
INSERT INTO `activities` VALUES (4, 9, 4, '狼塔C线全程挑战7日营地行（硬核）', '国内最难长线之一，翻越5个4000m+垭口，全程约100km无补给，需强壮体能和完整户外经验。限额4人，严格审核报名者资质。', '2026-04-29 18:36:02', '2026-05-06 18:36:02', 4, 1, 5, '全套扎营装备（4季帐、高山睡袋）、冰爪、冰镐、10天食物补给、卫星电话', '狼塔C线为极限线路，独自行走危及生命。撤退节点：各垭口均有下撤牧道，遇紧急情况立即下撤。新疆山地救援协会电话须提前存好。', 1, 0, '2026-03-15 18:36:02', '2026-03-15 18:36:02');
INSERT INTO `activities` VALUES (5, 1, 1, '随机组队活动 2026/3/16', NULL, '2026-03-16 03:35:00', '2026-03-16 11:35:00', 5, 3, 1, NULL, '随机组队活动，请注意安全', 3, 1, '2026-03-16 03:35:00', '2026-03-16 15:07:06');
INSERT INTO `activities` VALUES (6, 19, 3, '随机组队活动 2026/3/16', NULL, '2026-03-16 19:40:00', '2026-03-17 03:40:00', 4, 2, 1, NULL, '随机组队活动，请注意安全', 3, 1, '2026-03-16 19:40:00', '2026-03-17 17:38:18');

-- ----------------------------
-- Table structure for activity_members
-- ----------------------------
DROP TABLE IF EXISTS `activity_members`;
CREATE TABLE `activity_members`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键）',
  `activity_id` int UNSIGNED NOT NULL COMMENT '所属活动ID',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `role` tinyint NULL DEFAULT 0 COMMENT '角色（0普通成员/1组织者）',
  `status` tinyint NULL DEFAULT 0 COMMENT '审核状态（0待审核/1已通过/2已拒绝）',
  `apply_msg` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '申请留言',
  `joined_at` datetime NULL DEFAULT NULL COMMENT '加入时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_activity_user`(`activity_id` ASC, `user_id` ASC) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `activity_members_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `activity_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '活动成员表 - 记录活动参与者及审核状态' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_members
-- ----------------------------
INSERT INTO `activity_members` VALUES (1, 1, 2, 1, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (2, 2, 3, 1, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (3, 3, 4, 1, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (4, 4, 4, 1, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (5, 1, 3, 0, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (6, 1, 5, 0, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (7, 2, 5, 0, 1, NULL, '2026-03-15 18:36:02');
INSERT INTO `activity_members` VALUES (8, 5, 1, 1, 1, NULL, '2026-03-16 03:35:00');
INSERT INTO `activity_members` VALUES (9, 5, 2, 0, 1, NULL, '2026-03-16 03:35:00');
INSERT INTO `activity_members` VALUES (10, 5, 3, 0, 1, NULL, '2026-03-16 03:35:00');
INSERT INTO `activity_members` VALUES (11, 6, 3, 1, 1, NULL, '2026-03-16 19:40:00');
INSERT INTO `activity_members` VALUES (12, 6, 1, 0, 1, NULL, '2026-03-16 19:40:00');
INSERT INTO `activity_members` VALUES (13, 1, 1, 0, 1, '', '2026-03-17 17:39:09');

-- ----------------------------
-- Table structure for activity_reviews
-- ----------------------------
DROP TABLE IF EXISTS `activity_reviews`;
CREATE TABLE `activity_reviews`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '评价ID（主键）',
  `activity_id` int UNSIGNED NOT NULL COMMENT '所属活动ID',
  `reviewer_id` int UNSIGNED NOT NULL COMMENT '评价者用户ID',
  `reviewee_id` int UNSIGNED NOT NULL COMMENT '被评价者用户ID',
  `rating` tinyint NOT NULL COMMENT '评分（1-5星）',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '评价内容',
  `created_at` datetime NULL DEFAULT NULL COMMENT '评价时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_review`(`activity_id` ASC, `reviewer_id` ASC, `reviewee_id` ASC) USING BTREE,
  UNIQUE INDEX `activity_reviews_activity_id_reviewer_id_reviewee_id`(`activity_id` ASC, `reviewer_id` ASC, `reviewee_id` ASC) USING BTREE,
  INDEX `idx_reviewee`(`reviewee_id` ASC) USING BTREE,
  INDEX `reviewer_id`(`reviewer_id` ASC) USING BTREE,
  CONSTRAINT `activity_reviews_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_reviews_ibfk_2` FOREIGN KEY (`reviewer_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `activity_reviews_ibfk_3` FOREIGN KEY (`reviewee_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '活动互评表 - 活动结束后参与者互相评价' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of activity_reviews
-- ----------------------------

-- ----------------------------
-- Table structure for ai_sessions
-- ----------------------------
DROP TABLE IF EXISTS `ai_sessions`;
CREATE TABLE `ai_sessions`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '会话ID（主键）',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `session_type` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '会话类型',
  `messages` json NOT NULL COMMENT '对话消息历史(JSON数组)',
  `tokens_used` int NULL DEFAULT 0 COMMENT '已消耗token数量',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '最后更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_user_type`(`user_id` ASC, `session_type` ASC) USING BTREE,
  CONSTRAINT `ai_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'AI对话会话表 - 存储用户与AI助手的对话历史' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of ai_sessions
-- ----------------------------
INSERT INTO `ai_sessions` VALUES (1, 1, 'route_plan', '[{\"role\": \"user\", \"content\": \"你好\"}, {\"role\": \"assistant\", \"content\": \"你好！我是TrekHub的徒步路线助手。请告诉我你的体能等级（1-5级）、想去的地区（如云南、川西等）以及技能标签（如摄影、露营、轻装等），我会为你推荐合适的路线。\"}, {\"role\": \"user\", \"content\": \"Recommend a hiking route in Yunnan.\"}, {\"role\": \"assistant\", \"content\": \"请提供你的体能等级（1-5级）和技能标签（如摄影、露营、轻装等），以便为你推荐合适的云南路线。例如：  \\n- **初级（1-2级）**：虎跳峡轻徒步（2天，摄影友好）  \\n- **中级（3-4级）**：雨崩村徒步（4-5天，需基础露营技能）  \\n- **高级（5级）**：梅里北坡穿越（7天，需高海拔经验）\"}, {\"role\": \"user\", \"content\": \"推荐一条适合新手的周末线路\"}, {\"role\": \"assistant\", \"content\": \"**虎跳峡轻徒步（2天1晚）**  \\n- **适合**：体能1-2级的新手，无需露营（住客栈），轻装即可。  \\n- **亮点**：峡谷风光、摄影友好、路线成熟，周末可完成。  \\n- **提示**：从丽江出发，徒步中虎跳段，注意防滑鞋和防晒。\"}]', 624, '2026-03-17 19:17:40');
INSERT INTO `ai_sessions` VALUES (3, 3, 'route_plan', '[{\"role\": \"user\", \"content\": \"推荐一条适合新手的周末线路\"}, {\"role\": \"assistant\", \"content\": \"**推荐线路：杭州九溪十八涧（西湖区）**  \\n**适合人群**：体能等级1-2级的新手  \\n**路线亮点**：  \\n1. **轻松安全**：全程约6公里，爬升仅150米，石板路为主，单日可完成。  \\n2. **风景多元**：串联溪流、茶田、森林，秋季红叶绝美。  \\n3. **灵活调整**：可从九溪公交站出发，经龙井村折返，或延伸至云栖竹径（增至10公里）。  \\n**贴士**：穿防滑鞋，带500ml饮水，夏季注意防蚊。杭州地铁4号线可达起点，无需门票。\"}]', 201, '2026-03-16 19:50:58');
INSERT INTO `ai_sessions` VALUES (4, 3, 'team_match', '[{\"role\": \"user\", \"content\": \"我是新手，怎么找靠谱的队友？\"}, {\"role\": \"assistant\", \"content\": \"新手找队友，建议先明确活动类型和难度。可在TrekHub平台筛选“新手友好”标签，优先选择经验丰富、评价高的领队。参加同城线下活动或短途徒步，面对面交流更易建立信任。记得查看队友历史活动记录和互评哦！\"}, {\"role\": \"user\", \"content\": \"我是新手，怎么找靠谱的队友？\"}, {\"role\": \"assistant\", \"content\": \"新手找队友，建议先明确活动类型和难度。可在TrekHub平台筛选“新手友好”标签，优先选择经验丰富、评价高的领队。参加同城线下活动或短途徒步，面对面交流更易建立信任。记得查看队友历史活动记录和互评哦！\"}, {\"role\": \"user\", \"content\": \"多少人的队伍最合适？\"}, {\"role\": \"assistant\", \"content\": \"对于新手，建议选择 **4-8人** 的中小型队伍，原因如下：\\n1. **安全可控**：人数适中，领队或老手能兼顾每位队员，突发情况易协调。\\n2. **体验较好**：队伍灵活，行进节奏不易拖沓，新手更容易适应。\\n3. **社交友好**：人数不多不少，方便互相熟悉，建立信任感。\\n\\n⚠️ 避免超过15人的大队伍（易混乱），也别单独行动（风险高）。在TrekHub组队时，可优先筛选“小队精品”类活动哦！\"}]', 588, '2026-03-16 19:51:22');
INSERT INTO `ai_sessions` VALUES (5, 3, 'general', '[{\"role\": \"user\", \"content\": \"我要去温州玩有什么推荐景点\"}, {\"role\": \"assistant\", \"content\": \"温州推荐景点：  \\n1. **雁荡山**：以奇峰、瀑布著称，适合徒步观景。  \\n2. **楠溪江**：山水田园风光，可漂流、古村落游览。  \\n3. **江心屿**：瓯江中的小岛，有历史建筑和园林。  \\n4. **南麂列岛**：海岛风光，适合看海、吃海鲜。  \\n5. **五马街**：市区商业古街，体验当地小吃和购物。  \\n\\n建议根据季节和兴趣选择，山区注意安全，海岛提前查天气。\"}]', 156, '2026-03-16 19:51:56');

-- ----------------------------
-- Table structure for chat_rooms
-- ----------------------------
DROP TABLE IF EXISTS `chat_rooms`;
CREATE TABLE `chat_rooms`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '聊天室ID（主键）',
  `type` tinyint NOT NULL COMMENT '类型（1私聊/2活动群聊）',
  `activity_id` int UNSIGNED NULL DEFAULT NULL COMMENT '关联活动ID（群聊时有值）',
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '聊天室名称（群聊时有值）',
  `created_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `activity_id`(`activity_id` ASC) USING BTREE,
  CONSTRAINT `chat_rooms_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天室表 - 私聊和群聊房间' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chat_rooms
-- ----------------------------
INSERT INTO `chat_rooms` VALUES (1, 2, 1, '亚丁牛奶海两日营地活动', '2026-03-15 18:36:02');
INSERT INTO `chat_rooms` VALUES (2, 2, 2, '梅里雪山雨崩村3日秘境探访', '2026-03-15 18:36:02');
INSERT INTO `chat_rooms` VALUES (3, 2, 3, '珠峰大本营摄影+加乌拉山口5日行', '2026-03-15 18:36:02');
INSERT INTO `chat_rooms` VALUES (4, 2, 4, '狼塔C线全程挑战7日营地行（硬核）', '2026-03-15 18:36:02');
INSERT INTO `chat_rooms` VALUES (5, 1, NULL, NULL, '2026-03-15 21:13:36');
INSERT INTO `chat_rooms` VALUES (6, 2, 5, '组队群 #5', '2026-03-16 03:35:00');
INSERT INTO `chat_rooms` VALUES (7, 1, NULL, NULL, '2026-03-16 05:14:49');
INSERT INTO `chat_rooms` VALUES (8, 2, 6, '组队群 #6', '2026-03-16 19:40:00');

-- ----------------------------
-- Table structure for checkins
-- ----------------------------
DROP TABLE IF EXISTS `checkins`;
CREATE TABLE `checkins`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '打卡ID（主键）',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `activity_id` int UNSIGNED NULL DEFAULT NULL COMMENT '关联活动ID',
  `route_id` int UNSIGNED NULL DEFAULT NULL COMMENT '关联线路ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打卡标题',
  `content` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '打卡内容',
  `images` json NULL COMMENT '打卡图片URL数组(JSON)',
  `lng` decimal(11, 8) NULL DEFAULT NULL COMMENT '打卡地点经度',
  `lat` decimal(10, 8) NULL DEFAULT NULL COMMENT '打卡地点纬度',
  `distance_km` decimal(8, 2) NULL DEFAULT NULL COMMENT '本次徒步距离(km)',
  `checkin_at` datetime NULL DEFAULT NULL COMMENT '打卡时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `activity_id`(`activity_id` ASC) USING BTREE,
  INDEX `route_id`(`route_id` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE,
  INDEX `idx_date`(`checkin_at` ASC) USING BTREE,
  CONSTRAINT `checkins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `checkins_ibfk_2` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT,
  CONSTRAINT `checkins_ibfk_3` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '打卡记录表 - 用户徒步打卡签到数据' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of checkins
-- ----------------------------
INSERT INTO `checkins` VALUES (1, 2, NULL, 1, '第三次登四姑娘大峰 ✓', '今天天气超好，垭口营地看到满天星星，明天冲顶！', NULL, NULL, NULL, 14.00, '2026-03-12 18:36:02');
INSERT INTO `checkins` VALUES (2, 2, NULL, 3, '贡嘎子梅垭口', '子梅垭口4500m，贡嘎雪山就在眼前，太震撼了！', NULL, NULL, NULL, 22.00, '2026-03-05 18:36:02');
INSERT INTO `checkins` VALUES (3, 3, NULL, 7, '雨崩村徒步 Day1', '从飞来寺走到上雨崩，腿已经废了哈哈，但村子好美。', NULL, NULL, NULL, 18.00, '2026-03-08 18:36:02');
INSERT INTO `checkins` VALUES (4, 4, NULL, 9, '狼塔C线 Day3', '今天翻越第三个垭口，4320m，腿软了但心情极好！', NULL, NULL, NULL, 15.00, '2026-03-10 18:36:02');
INSERT INTO `checkins` VALUES (5, 5, NULL, 17, '黄山西海大峡谷打卡', '栈道真的够惊险的，但云海美翻！', NULL, NULL, NULL, 18.00, '2026-03-13 18:36:02');
INSERT INTO `checkins` VALUES (6, 1, NULL, NULL, '爬山了', NULL, '[]', NULL, NULL, NULL, '2026-03-16 03:13:10');
INSERT INTO `checkins` VALUES (7, 3, NULL, NULL, NULL, NULL, '[\"/uploads/images/1773606452025_90p3t9q4k58.jpg\"]', NULL, NULL, NULL, '2026-03-16 04:27:32');

-- ----------------------------
-- Table structure for comment_likes
-- ----------------------------
DROP TABLE IF EXISTS `comment_likes`;
CREATE TABLE `comment_likes`  (
  `user_id` int UNSIGNED NOT NULL COMMENT '点赞用户ID',
  `comment_id` int UNSIGNED NOT NULL COMMENT '评论ID',
  `created_at` datetime NULL DEFAULT NULL COMMENT '点赞时间',
  PRIMARY KEY (`user_id`, `comment_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '评论点赞表 - 记录用户对评论的点赞' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comment_likes
-- ----------------------------
INSERT INTO `comment_likes` VALUES (1, 7, '2026-03-16 19:33:18');
INSERT INTO `comment_likes` VALUES (2, 12, NULL);
INSERT INTO `comment_likes` VALUES (3, 11, '2026-03-16 19:33:11');

-- ----------------------------
-- Table structure for comments
-- ----------------------------
DROP TABLE IF EXISTS `comments`;
CREATE TABLE `comments`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '评论ID（主键）',
  `target_type` tinyint NOT NULL COMMENT '目标类型（1线路/2活动）',
  `target_id` int UNSIGNED NOT NULL COMMENT '目标ID（线路或活动的ID）',
  `user_id` int UNSIGNED NOT NULL COMMENT '评论者用户ID',
  `parent_id` int UNSIGNED NULL DEFAULT NULL COMMENT '父评论ID（回复时有值）',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `images` json NULL COMMENT '评论图片URL数组(JSON)',
  `rating` tinyint NULL DEFAULT NULL COMMENT '评分（1-5星，线路评价时使用）',
  `like_count` int UNSIGNED NULL DEFAULT 0 COMMENT '点赞数',
  `created_at` datetime NULL DEFAULT NULL COMMENT '评论时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_target`(`target_type` ASC, `target_id` ASC) USING BTREE,
  INDEX `idx_parent`(`parent_id` ASC) USING BTREE,
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '评论表 - 支持线路和活动的多目标评论，含回复和评分' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of comments
-- ----------------------------
INSERT INTO `comments` VALUES (1, 1, 1, 3, NULL, '四姑娘大峰真的太美了！猫鼻梁那段乱石坡建议戴手套，我手被划了好几道。整体强烈推荐，垭口营地晚上星空无敌！', NULL, 5, 6, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (2, 1, 1, 5, NULL, '路线描述很准确，实际难度比我想的高一点，垭口前的碎石路段需要手脚并用。下次想挑战幺妹峰环线。', NULL, 4, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (3, 1, 4, 2, NULL, '亚丁牛奶海是我见过最美的高原湖泊，湖水的颜色真的像牛奶！建议一定要住在牛场扎营看日出，比当天往返值太多了。', NULL, 5, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (4, 1, 7, 4, NULL, '雨崩村客栈很简陋但老板很热情，冰湖那段爬升很陡，腿酸到第二天走路困难哈哈。但神瀑的气场真的能让人感受到神圣。', NULL, 5, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (5, 1, 12, 1, NULL, '珠峰大本营日出那刻真的会落泪，6点整第一缕金光打在峰顶，身边的藏族向导也双手合十祈祷。5200m的风吹得站不稳，但值了！', NULL, 5, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (6, 1, 17, 5, NULL, '黄山是我走过性价比最高的山！西海大峡谷的栈道真的惊险，走到一半腿软，但回头看都是云雾缭绕的奇峰，太震撼了。', NULL, 5, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (7, 1, 3, 3, NULL, '子梅垭口爬升很累，但到垭口的那一刻看到贡嘎主峰，所有的累都消失了。建议早起出发，下午垭口容易起雾。', NULL, 5, 1, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (8, 1, 8, 5, NULL, '元阳梯田日出是人生必看，但需要凌晨4点出门！建议住多依树观景台附近的农家乐，房东会叫你起床，很暖心。', NULL, 4, 0, '2026-03-15 18:36:02');
INSERT INTO `comments` VALUES (11, 1, 6, 3, NULL, '很不错', NULL, 5, 5, '2026-03-16 19:28:53');
INSERT INTO `comments` VALUES (12, 2, 1, 1, NULL, '这个景点，真的不错', '[\"/uploads/images/1773740483314_lraf7opehei.jpg\"]', NULL, 1, '2026-03-17 17:41:46');

-- ----------------------------
-- Table structure for favorites
-- ----------------------------
DROP TABLE IF EXISTS `favorites`;
CREATE TABLE `favorites`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '收藏ID（主键）',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `target_type` tinyint NOT NULL COMMENT '目标类型（1线路/2活动）',
  `target_id` int UNSIGNED NOT NULL COMMENT '目标ID',
  `created_at` datetime NULL DEFAULT NULL COMMENT '收藏时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uq_fav`(`user_id` ASC, `target_type` ASC, `target_id` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_id` ASC, `target_type` ASC) USING BTREE,
  CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 26 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '收藏表 - 用户收藏线路或活动的记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of favorites
-- ----------------------------
INSERT INTO `favorites` VALUES (1, 1, 1, 4, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (2, 1, 1, 7, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (3, 1, 1, 12, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (4, 1, 1, 17, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (5, 2, 1, 1, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (6, 2, 1, 2, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (8, 2, 1, 12, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (9, 3, 1, 6, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (10, 3, 1, 7, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (11, 3, 1, 8, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (12, 3, 1, 19, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (13, 4, 1, 9, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (14, 4, 1, 10, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (15, 4, 1, 11, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (16, 4, 1, 12, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (17, 5, 1, 15, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (18, 5, 1, 16, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (19, 5, 1, 17, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (20, 5, 1, 18, '2026-03-15 18:36:02');
INSERT INTO `favorites` VALUES (21, 1, 1, 1, '2026-03-15 21:24:38');
INSERT INTO `favorites` VALUES (24, 1, 1, 3, '2026-03-16 19:37:53');

-- ----------------------------
-- Table structure for match_pool
-- ----------------------------
DROP TABLE IF EXISTS `match_pool`;
CREATE TABLE `match_pool`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID（主键）',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID（唯一）',
  `route_id` int UNSIGNED NULL DEFAULT NULL COMMENT '偏好线路ID',
  `prefer_date` date NULL DEFAULT NULL COMMENT '偏好出行日期',
  `min_level` tinyint NULL DEFAULT 1 COMMENT '队友最低等级',
  `max_level` tinyint NULL DEFAULT 5 COMMENT '队友最高等级',
  `skill_tags` json NULL COMMENT '偏好技能标签(JSON数组)',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态（1等待中/2已匹配）',
  `joined_at` datetime NULL DEFAULT NULL COMMENT '加入匹配池时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `user_id`(`user_id` ASC) USING BTREE,
  INDEX `route_id`(`route_id` ASC) USING BTREE,
  CONSTRAINT `match_pool_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `match_pool_ibfk_2` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE SET NULL ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '随机组队匹配池表 - 用户等待匹配队友的偏好设置' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of match_pool
-- ----------------------------
INSERT INTO `match_pool` VALUES (5, 2, NULL, '2026-03-15', 1, 5, '[]', 0, '2026-03-16 03:34:04');
INSERT INTO `match_pool` VALUES (7, 3, 19, NULL, 1, 5, '[]', 0, '2026-03-16 19:39:10');
INSERT INTO `match_pool` VALUES (8, 1, 19, NULL, 1, 5, '[]', 0, '2026-03-16 19:39:28');

-- ----------------------------
-- Table structure for messages
-- ----------------------------
DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '消息ID（主键）',
  `room_id` int UNSIGNED NOT NULL COMMENT '所属聊天室ID',
  `sender_id` int UNSIGNED NOT NULL COMMENT '发送者用户ID',
  `type` tinyint NULL DEFAULT 1 COMMENT '消息类型（1文字/2图片）',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '消息内容',
  `is_read` tinyint(1) NULL DEFAULT 0 COMMENT '是否已读（0未读/1已读）',
  `created_at` datetime NULL DEFAULT NULL COMMENT '发送时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `sender_id`(`sender_id` ASC) USING BTREE,
  INDEX `idx_room_time`(`room_id` ASC, `created_at` ASC) USING BTREE,
  CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `chat_rooms` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天消息表 - 存储所有聊天消息记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of messages
-- ----------------------------
INSERT INTO `messages` VALUES (1, 6, 1, 1, '你好么', 1, '2026-03-16 03:39:27');
INSERT INTO `messages` VALUES (2, 6, 3, 1, '很好啊', 1, '2026-03-16 03:39:39');
INSERT INTO `messages` VALUES (3, 6, 3, 2, '/uploads/images/1773606452025_90p3t9q4k58.jpg', 1, '2026-03-16 04:27:32');
INSERT INTO `messages` VALUES (4, 7, 1, 1, '你好', 1, '2026-03-16 05:14:52');
INSERT INTO `messages` VALUES (5, 6, 2, 1, '你好', 1, '2026-03-17 19:22:25');

-- ----------------------------
-- Table structure for room_members
-- ----------------------------
DROP TABLE IF EXISTS `room_members`;
CREATE TABLE `room_members`  (
  `room_id` int UNSIGNED NOT NULL COMMENT '聊天室ID',
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `joined_at` datetime NULL DEFAULT NULL COMMENT '加入时间',
  PRIMARY KEY (`room_id`, `user_id`) USING BTREE,
  INDEX `user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `room_members_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `chat_rooms` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `room_members_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '聊天室成员表 - 记录聊天室的参与用户' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of room_members
-- ----------------------------
INSERT INTO `room_members` VALUES (1, 1, NULL);
INSERT INTO `room_members` VALUES (1, 2, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (1, 3, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (1, 5, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (2, 3, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (2, 5, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (3, 4, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (4, 4, '2026-03-15 18:36:02');
INSERT INTO `room_members` VALUES (5, 1, '2026-03-15 21:13:36');
INSERT INTO `room_members` VALUES (6, 1, '2026-03-16 03:35:00');
INSERT INTO `room_members` VALUES (6, 2, '2026-03-16 03:35:00');
INSERT INTO `room_members` VALUES (6, 3, '2026-03-16 03:35:00');
INSERT INTO `room_members` VALUES (7, 1, '2026-03-16 05:14:49');
INSERT INTO `room_members` VALUES (7, 3, '2026-03-16 05:14:49');
INSERT INTO `room_members` VALUES (8, 1, '2026-03-16 19:40:00');
INSERT INTO `room_members` VALUES (8, 3, '2026-03-16 19:40:00');

-- ----------------------------
-- Table structure for route_points
-- ----------------------------
DROP TABLE IF EXISTS `route_points`;
CREATE TABLE `route_points`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '坐标点ID（主键）',
  `route_id` int UNSIGNED NOT NULL COMMENT '所属线路ID',
  `seq` smallint NOT NULL COMMENT '坐标点序号',
  `lng` decimal(11, 8) NOT NULL COMMENT '经度',
  `lat` decimal(10, 8) NOT NULL COMMENT '纬度',
  `elevation` decimal(7, 2) NULL DEFAULT NULL COMMENT '海拔高度(m)',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_route`(`route_id` ASC) USING BTREE,
  CONSTRAINT `route_points_ibfk_1` FOREIGN KEY (`route_id`) REFERENCES `routes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2676 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '线路GPS坐标点表 - 存储线路轨迹点序列' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of route_points
-- ----------------------------
INSERT INTO `route_points` VALUES (1876, 1, 1, 102.89123000, 31.02345000, 3340.00);
INSERT INTO `route_points` VALUES (1877, 1, 2, 102.89256000, 31.02478000, 3481.00);
INSERT INTO `route_points` VALUES (1878, 1, 3, 102.89389000, 31.02611000, 3608.00);
INSERT INTO `route_points` VALUES (1879, 1, 4, 102.89522000, 31.02744000, 3623.00);
INSERT INTO `route_points` VALUES (1880, 1, 5, 102.89655000, 31.02877000, 3580.00);
INSERT INTO `route_points` VALUES (1881, 1, 6, 102.89655000, 31.03010000, 3592.00);
INSERT INTO `route_points` VALUES (1882, 1, 7, 102.89522000, 31.03143000, 3612.00);
INSERT INTO `route_points` VALUES (1883, 1, 8, 102.89389000, 31.03276000, 3633.00);
INSERT INTO `route_points` VALUES (1884, 1, 9, 102.89256000, 31.03409000, 3718.00);
INSERT INTO `route_points` VALUES (1885, 1, 10, 102.89123000, 31.03542000, 3719.00);
INSERT INTO `route_points` VALUES (1886, 1, 11, 102.88990000, 31.03675000, 3752.00);
INSERT INTO `route_points` VALUES (1887, 1, 12, 102.88857000, 31.03808000, 3774.00);
INSERT INTO `route_points` VALUES (1888, 1, 13, 102.88724000, 31.03941000, 3724.00);
INSERT INTO `route_points` VALUES (1889, 1, 14, 102.88591000, 31.04074000, 3711.00);
INSERT INTO `route_points` VALUES (1890, 1, 15, 102.88458000, 31.04207000, 3655.00);
INSERT INTO `route_points` VALUES (1891, 1, 16, 102.88325000, 31.04340000, 3590.00);
INSERT INTO `route_points` VALUES (1892, 1, 17, 102.88192000, 31.04473000, 3600.00);
INSERT INTO `route_points` VALUES (1893, 1, 18, 102.88059000, 31.04606000, 3692.00);
INSERT INTO `route_points` VALUES (1894, 1, 19, 102.87926000, 31.04739000, 3837.00);
INSERT INTO `route_points` VALUES (1895, 1, 20, 102.87793000, 31.04872000, 4060.00);
INSERT INTO `route_points` VALUES (1896, 1, 21, 102.87660000, 31.05005000, 4223.00);
INSERT INTO `route_points` VALUES (1897, 1, 22, 102.87527000, 31.05138000, 4423.00);
INSERT INTO `route_points` VALUES (1898, 1, 23, 102.87394000, 31.05271000, 4629.00);
INSERT INTO `route_points` VALUES (1899, 1, 24, 102.87261000, 31.05404000, 4761.00);
INSERT INTO `route_points` VALUES (1900, 1, 25, 102.87128000, 31.05537000, 4836.00);
INSERT INTO `route_points` VALUES (1901, 1, 26, 102.86995000, 31.05670000, 4776.00);
INSERT INTO `route_points` VALUES (1902, 1, 27, 102.86862000, 31.05803000, 4715.00);
INSERT INTO `route_points` VALUES (1903, 1, 28, 102.86729000, 31.05936000, 4656.00);
INSERT INTO `route_points` VALUES (1904, 1, 29, 102.86596000, 31.06069000, 4578.00);
INSERT INTO `route_points` VALUES (1905, 1, 30, 102.86463000, 31.06202000, 4533.00);
INSERT INTO `route_points` VALUES (1906, 1, 31, 102.86330000, 31.06335000, 4550.00);
INSERT INTO `route_points` VALUES (1907, 1, 32, 102.86197000, 31.06468000, 4619.00);
INSERT INTO `route_points` VALUES (1908, 1, 33, 102.86064000, 31.06601000, 4625.00);
INSERT INTO `route_points` VALUES (1909, 1, 34, 102.85931000, 31.06734000, 4699.00);
INSERT INTO `route_points` VALUES (1910, 1, 35, 102.85798000, 31.06867000, 4713.00);
INSERT INTO `route_points` VALUES (1911, 1, 36, 102.85665000, 31.07000000, 4792.00);
INSERT INTO `route_points` VALUES (1912, 1, 37, 102.85532000, 31.07133000, 4838.00);
INSERT INTO `route_points` VALUES (1913, 1, 38, 102.85399000, 31.07266000, 4844.00);
INSERT INTO `route_points` VALUES (1914, 1, 39, 102.85266000, 31.07399000, 4900.00);
INSERT INTO `route_points` VALUES (1915, 1, 40, 102.85133000, 31.07532000, 4991.00);
INSERT INTO `route_points` VALUES (1916, 2, 1, 102.89123000, 31.02345000, 3200.00);
INSERT INTO `route_points` VALUES (1917, 2, 2, 102.89256000, 31.02478000, 3250.00);
INSERT INTO `route_points` VALUES (1918, 2, 3, 102.89389000, 31.02611000, 3300.00);
INSERT INTO `route_points` VALUES (1919, 2, 4, 102.89522000, 31.02744000, 3350.00);
INSERT INTO `route_points` VALUES (1920, 2, 5, 102.89450000, 31.02870000, 3400.00);
INSERT INTO `route_points` VALUES (1921, 2, 6, 102.89320000, 31.02980000, 3450.00);
INSERT INTO `route_points` VALUES (1922, 2, 7, 102.89190000, 31.03090000, 3500.00);
INSERT INTO `route_points` VALUES (1923, 2, 8, 102.89060000, 31.03200000, 3550.00);
INSERT INTO `route_points` VALUES (1924, 2, 9, 102.88930000, 31.03310000, 3600.00);
INSERT INTO `route_points` VALUES (1925, 2, 10, 102.88800000, 31.03420000, 3650.00);
INSERT INTO `route_points` VALUES (1926, 2, 11, 102.88670000, 31.03300000, 3700.00);
INSERT INTO `route_points` VALUES (1927, 2, 12, 102.88540000, 31.03180000, 3750.00);
INSERT INTO `route_points` VALUES (1928, 2, 13, 102.88410000, 31.03060000, 3800.00);
INSERT INTO `route_points` VALUES (1929, 2, 14, 102.88280000, 31.02940000, 3850.00);
INSERT INTO `route_points` VALUES (1930, 2, 15, 102.88150000, 31.02820000, 3900.00);
INSERT INTO `route_points` VALUES (1931, 2, 16, 102.88200000, 31.02690000, 3850.00);
INSERT INTO `route_points` VALUES (1932, 2, 17, 102.88250000, 31.02560000, 3800.00);
INSERT INTO `route_points` VALUES (1933, 2, 18, 102.88300000, 31.02430000, 3750.00);
INSERT INTO `route_points` VALUES (1934, 2, 19, 102.88350000, 31.02300000, 3700.00);
INSERT INTO `route_points` VALUES (1935, 2, 20, 102.88400000, 31.02170000, 3650.00);
INSERT INTO `route_points` VALUES (1936, 2, 21, 102.88530000, 31.02050000, 3600.00);
INSERT INTO `route_points` VALUES (1937, 2, 22, 102.88660000, 31.01930000, 3550.00);
INSERT INTO `route_points` VALUES (1938, 2, 23, 102.88790000, 31.01810000, 3500.00);
INSERT INTO `route_points` VALUES (1939, 2, 24, 102.88920000, 31.01690000, 3450.00);
INSERT INTO `route_points` VALUES (1940, 2, 25, 102.89050000, 31.01570000, 3400.00);
INSERT INTO `route_points` VALUES (1941, 2, 26, 102.89180000, 31.01450000, 3350.00);
INSERT INTO `route_points` VALUES (1942, 2, 27, 102.89310000, 31.01330000, 3300.00);
INSERT INTO `route_points` VALUES (1943, 2, 28, 102.89440000, 31.01210000, 3250.00);
INSERT INTO `route_points` VALUES (1944, 2, 29, 102.89570000, 31.01090000, 3200.00);
INSERT INTO `route_points` VALUES (1945, 2, 30, 102.89700000, 31.00970000, 3150.00);
INSERT INTO `route_points` VALUES (1946, 2, 31, 102.89830000, 31.00850000, 3100.00);
INSERT INTO `route_points` VALUES (1947, 2, 32, 102.89960000, 31.00730000, 3050.00);
INSERT INTO `route_points` VALUES (1948, 2, 33, 102.90090000, 31.00610000, 3000.00);
INSERT INTO `route_points` VALUES (1949, 2, 34, 102.90220000, 31.00490000, 2950.00);
INSERT INTO `route_points` VALUES (1950, 2, 35, 102.90350000, 31.00370000, 2900.00);
INSERT INTO `route_points` VALUES (1951, 2, 36, 102.90480000, 31.00250000, 2850.00);
INSERT INTO `route_points` VALUES (1952, 2, 37, 102.90610000, 31.00130000, 2800.00);
INSERT INTO `route_points` VALUES (1953, 2, 38, 102.90740000, 31.00010000, 2750.00);
INSERT INTO `route_points` VALUES (1954, 2, 39, 102.90870000, 30.99890000, 2700.00);
INSERT INTO `route_points` VALUES (1955, 2, 40, 102.91000000, 30.99770000, 2650.00);
INSERT INTO `route_points` VALUES (1956, 3, 1, 101.82456000, 29.57321000, 3550.00);
INSERT INTO `route_points` VALUES (1957, 3, 2, 101.82673000, 29.57488000, 3620.00);
INSERT INTO `route_points` VALUES (1958, 3, 3, 101.82945000, 29.57612000, 3680.00);
INSERT INTO `route_points` VALUES (1959, 3, 4, 101.83211000, 29.57703000, 3750.00);
INSERT INTO `route_points` VALUES (1960, 3, 5, 101.83489000, 29.57795000, 3820.00);
INSERT INTO `route_points` VALUES (1961, 3, 6, 101.83602000, 29.57964000, 3780.00);
INSERT INTO `route_points` VALUES (1962, 3, 7, 101.83578000, 29.58133000, 3720.00);
INSERT INTO `route_points` VALUES (1963, 3, 8, 101.83412000, 29.58267000, 3650.00);
INSERT INTO `route_points` VALUES (1964, 3, 9, 101.83245000, 29.58421000, 3700.00);
INSERT INTO `route_points` VALUES (1965, 3, 10, 101.83188000, 29.58604000, 3760.00);
INSERT INTO `route_points` VALUES (1966, 3, 11, 101.83267000, 29.58792000, 3830.00);
INSERT INTO `route_points` VALUES (1967, 3, 12, 101.83123000, 29.58945000, 3900.00);
INSERT INTO `route_points` VALUES (1968, 3, 13, 101.82945000, 29.59012000, 3980.00);
INSERT INTO `route_points` VALUES (1969, 3, 14, 101.82762000, 29.59103000, 4050.00);
INSERT INTO `route_points` VALUES (1970, 3, 15, 101.82611000, 29.59267000, 4120.00);
INSERT INTO `route_points` VALUES (1971, 3, 16, 101.82534000, 29.59428000, 4080.00);
INSERT INTO `route_points` VALUES (1972, 3, 17, 101.82478000, 29.59591000, 4020.00);
INSERT INTO `route_points` VALUES (1973, 3, 18, 101.82345000, 29.59723000, 3950.00);
INSERT INTO `route_points` VALUES (1974, 3, 19, 101.82212000, 29.59864000, 4000.00);
INSERT INTO `route_points` VALUES (1975, 3, 20, 101.82156000, 29.60033000, 4060.00);
INSERT INTO `route_points` VALUES (1976, 3, 21, 101.82234000, 29.60211000, 4130.00);
INSERT INTO `route_points` VALUES (1977, 3, 22, 101.82389000, 29.60345000, 4200.00);
INSERT INTO `route_points` VALUES (1978, 3, 23, 101.82567000, 29.60478000, 4270.00);
INSERT INTO `route_points` VALUES (1979, 3, 24, 101.82723000, 29.60612000, 4340.00);
INSERT INTO `route_points` VALUES (1980, 3, 25, 101.82856000, 29.60764000, 4410.00);
INSERT INTO `route_points` VALUES (1981, 3, 26, 101.82912000, 29.60933000, 4370.00);
INSERT INTO `route_points` VALUES (1982, 3, 27, 101.82845000, 29.61102000, 4300.00);
INSERT INTO `route_points` VALUES (1983, 3, 28, 101.82711000, 29.61245000, 4230.00);
INSERT INTO `route_points` VALUES (1984, 3, 29, 101.82578000, 29.61388000, 4280.00);
INSERT INTO `route_points` VALUES (1985, 3, 30, 101.82512000, 29.61567000, 4340.00);
INSERT INTO `route_points` VALUES (1986, 3, 31, 101.82589000, 29.61745000, 4410.00);
INSERT INTO `route_points` VALUES (1987, 3, 32, 101.82745000, 29.61879000, 4480.00);
INSERT INTO `route_points` VALUES (1988, 3, 33, 101.82923000, 29.62012000, 4550.00);
INSERT INTO `route_points` VALUES (1989, 3, 34, 101.83067000, 29.62145000, 4620.00);
INSERT INTO `route_points` VALUES (1990, 3, 35, 101.83123000, 29.62314000, 4580.00);
INSERT INTO `route_points` VALUES (1991, 3, 36, 101.83056000, 29.62483000, 4510.00);
INSERT INTO `route_points` VALUES (1992, 3, 37, 101.82922000, 29.62626000, 4440.00);
INSERT INTO `route_points` VALUES (1993, 3, 38, 101.82789000, 29.62769000, 4490.00);
INSERT INTO `route_points` VALUES (1994, 3, 39, 101.82723000, 29.62948000, 4550.00);
INSERT INTO `route_points` VALUES (1995, 3, 40, 101.82801000, 29.63126000, 4620.00);
INSERT INTO `route_points` VALUES (1996, 4, 1, 100.27145000, 29.03312000, 4206.00);
INSERT INTO `route_points` VALUES (1997, 4, 2, 100.27288000, 29.03395000, 4253.00);
INSERT INTO `route_points` VALUES (1998, 4, 3, 100.27420000, 29.03460000, 4266.00);
INSERT INTO `route_points` VALUES (1999, 4, 4, 100.27505000, 29.03522000, 4279.00);
INSERT INTO `route_points` VALUES (2000, 4, 5, 100.27580000, 29.03590000, 4297.00);
INSERT INTO `route_points` VALUES (2001, 4, 6, 100.27610000, 29.03675000, 4310.00);
INSERT INTO `route_points` VALUES (2002, 4, 7, 100.27585000, 29.03760000, 4308.00);
INSERT INTO `route_points` VALUES (2003, 4, 8, 100.27530000, 29.03825000, 4328.00);
INSERT INTO `route_points` VALUES (2004, 4, 9, 100.27450000, 29.03880000, 4338.00);
INSERT INTO `route_points` VALUES (2005, 4, 10, 100.27395000, 29.03950000, 4369.00);
INSERT INTO `route_points` VALUES (2006, 4, 11, 100.27370000, 29.04030000, 4393.00);
INSERT INTO `route_points` VALUES (2007, 4, 12, 100.27390000, 29.04115000, 4408.00);
INSERT INTO `route_points` VALUES (2008, 4, 13, 100.27440000, 29.04185000, 4379.00);
INSERT INTO `route_points` VALUES (2009, 4, 14, 100.27525000, 29.04220000, 4373.00);
INSERT INTO `route_points` VALUES (2010, 4, 15, 100.27615000, 29.04235000, 4358.00);
INSERT INTO `route_points` VALUES (2011, 4, 16, 100.27700000, 29.04210000, 4354.00);
INSERT INTO `route_points` VALUES (2012, 4, 17, 100.27765000, 29.04150000, 4346.00);
INSERT INTO `route_points` VALUES (2013, 4, 18, 100.27810000, 29.04070000, 4378.00);
INSERT INTO `route_points` VALUES (2014, 4, 19, 100.27830000, 29.03980000, 4433.00);
INSERT INTO `route_points` VALUES (2015, 4, 20, 100.27815000, 29.03890000, 4521.00);
INSERT INTO `route_points` VALUES (2016, 4, 21, 100.27770000, 29.03815000, 4595.00);
INSERT INTO `route_points` VALUES (2017, 4, 22, 100.27700000, 29.03760000, 4652.00);
INSERT INTO `route_points` VALUES (2018, 4, 23, 100.27620000, 29.03725000, 4738.00);
INSERT INTO `route_points` VALUES (2019, 4, 24, 100.27535000, 29.03710000, 4775.00);
INSERT INTO `route_points` VALUES (2020, 4, 25, 100.27450000, 29.03720000, 4786.00);
INSERT INTO `route_points` VALUES (2021, 4, 26, 100.27375000, 29.03755000, 4793.00);
INSERT INTO `route_points` VALUES (2022, 4, 27, 100.27320000, 29.03810000, 4767.00);
INSERT INTO `route_points` VALUES (2023, 4, 28, 100.27290000, 29.03880000, 4735.00);
INSERT INTO `route_points` VALUES (2024, 4, 29, 100.27285000, 29.03960000, 4715.00);
INSERT INTO `route_points` VALUES (2025, 4, 30, 100.27305000, 29.04040000, 4687.00);
INSERT INTO `route_points` VALUES (2026, 4, 31, 100.27350000, 29.04110000, 4679.00);
INSERT INTO `route_points` VALUES (2027, 4, 32, 100.27415000, 29.04165000, 4681.00);
INSERT INTO `route_points` VALUES (2028, 4, 33, 100.27495000, 29.04200000, 4682.00);
INSERT INTO `route_points` VALUES (2029, 4, 34, 100.27585000, 29.04210000, 4708.00);
INSERT INTO `route_points` VALUES (2030, 4, 35, 100.27675000, 29.04195000, 4714.00);
INSERT INTO `route_points` VALUES (2031, 4, 36, 100.27755000, 29.04155000, 4711.00);
INSERT INTO `route_points` VALUES (2032, 4, 37, 100.27820000, 29.04095000, 4720.00);
INSERT INTO `route_points` VALUES (2033, 4, 38, 100.27865000, 29.04020000, 4720.00);
INSERT INTO `route_points` VALUES (2034, 4, 39, 100.27885000, 29.03935000, 4735.00);
INSERT INTO `route_points` VALUES (2035, 4, 40, 100.27880000, 29.03850000, 4779.00);
INSERT INTO `route_points` VALUES (2036, 5, 1, 102.36215000, 27.71583000, 2450.00);
INSERT INTO `route_points` VALUES (2037, 5, 2, 102.36372000, 27.71641000, 2480.00);
INSERT INTO `route_points` VALUES (2038, 5, 3, 102.36508000, 27.71725000, 2510.00);
INSERT INTO `route_points` VALUES (2039, 5, 4, 102.36591000, 27.71863000, 2550.00);
INSERT INTO `route_points` VALUES (2040, 5, 5, 102.36542000, 27.71988000, 2590.00);
INSERT INTO `route_points` VALUES (2041, 5, 6, 102.36415000, 27.72034000, 2620.00);
INSERT INTO `route_points` VALUES (2042, 5, 7, 102.36278000, 27.72091000, 2650.00);
INSERT INTO `route_points` VALUES (2043, 5, 8, 102.36145000, 27.72167000, 2680.00);
INSERT INTO `route_points` VALUES (2044, 5, 9, 102.36012000, 27.72253000, 2720.00);
INSERT INTO `route_points` VALUES (2045, 5, 10, 102.35988000, 27.72415000, 2760.00);
INSERT INTO `route_points` VALUES (2046, 5, 11, 102.36091000, 27.72542000, 2790.00);
INSERT INTO `route_points` VALUES (2047, 5, 12, 102.36225000, 27.72618000, 2820.00);
INSERT INTO `route_points` VALUES (2048, 5, 13, 102.36358000, 27.72694000, 2850.00);
INSERT INTO `route_points` VALUES (2049, 5, 14, 102.36471000, 27.72780000, 2880.00);
INSERT INTO `route_points` VALUES (2050, 5, 15, 102.36534000, 27.72912000, 2910.00);
INSERT INTO `route_points` VALUES (2051, 5, 16, 102.36495000, 27.73058000, 2940.00);
INSERT INTO `route_points` VALUES (2052, 5, 17, 102.36362000, 27.73134000, 2900.00);
INSERT INTO `route_points` VALUES (2053, 5, 18, 102.36229000, 27.73210000, 2860.00);
INSERT INTO `route_points` VALUES (2054, 5, 19, 102.36096000, 27.73286000, 2820.00);
INSERT INTO `route_points` VALUES (2055, 5, 20, 102.35963000, 27.73362000, 2780.00);
INSERT INTO `route_points` VALUES (2056, 5, 21, 102.35830000, 27.73438000, 2750.00);
INSERT INTO `route_points` VALUES (2057, 5, 22, 102.35747000, 27.73576000, 2720.00);
INSERT INTO `route_points` VALUES (2058, 5, 23, 102.35796000, 27.73701000, 2700.00);
INSERT INTO `route_points` VALUES (2059, 5, 24, 102.35923000, 27.73757000, 2680.00);
INSERT INTO `route_points` VALUES (2060, 5, 25, 102.36060000, 27.73814000, 2650.00);
INSERT INTO `route_points` VALUES (2061, 5, 26, 102.36193000, 27.73890000, 2620.00);
INSERT INTO `route_points` VALUES (2062, 5, 27, 102.36326000, 27.73966000, 2600.00);
INSERT INTO `route_points` VALUES (2063, 5, 28, 102.36459000, 27.74042000, 2580.00);
INSERT INTO `route_points` VALUES (2064, 5, 29, 102.36542000, 27.74180000, 2560.00);
INSERT INTO `route_points` VALUES (2065, 5, 30, 102.36493000, 27.74305000, 2540.00);
INSERT INTO `route_points` VALUES (2066, 5, 31, 102.36366000, 27.74361000, 2520.00);
INSERT INTO `route_points` VALUES (2067, 5, 32, 102.36229000, 27.74418000, 2500.00);
INSERT INTO `route_points` VALUES (2068, 5, 33, 102.36096000, 27.74494000, 2480.00);
INSERT INTO `route_points` VALUES (2069, 5, 34, 102.35963000, 27.74570000, 2460.00);
INSERT INTO `route_points` VALUES (2070, 5, 35, 102.35830000, 27.74646000, 2440.00);
INSERT INTO `route_points` VALUES (2071, 5, 36, 102.35747000, 27.74784000, 2420.00);
INSERT INTO `route_points` VALUES (2072, 5, 37, 102.35796000, 27.74909000, 2400.00);
INSERT INTO `route_points` VALUES (2073, 5, 38, 102.35923000, 27.74965000, 2380.00);
INSERT INTO `route_points` VALUES (2074, 5, 39, 102.36060000, 27.75022000, 2360.00);
INSERT INTO `route_points` VALUES (2075, 5, 40, 102.36193000, 27.75098000, 2340.00);
INSERT INTO `route_points` VALUES (2076, 6, 1, 98.68231000, 25.11745000, 1560.00);
INSERT INTO `route_points` VALUES (2077, 6, 2, 98.68472000, 25.11893000, 1620.00);
INSERT INTO `route_points` VALUES (2078, 6, 3, 98.68655000, 25.12017000, 1680.00);
INSERT INTO `route_points` VALUES (2079, 6, 4, 98.68783000, 25.12164000, 1750.00);
INSERT INTO `route_points` VALUES (2080, 6, 5, 98.68701000, 25.12322000, 1820.00);
INSERT INTO `route_points` VALUES (2081, 6, 6, 98.68544000, 25.12458000, 1880.00);
INSERT INTO `route_points` VALUES (2082, 6, 7, 98.68377000, 25.12591000, 1950.00);
INSERT INTO `route_points` VALUES (2083, 6, 8, 98.68295000, 25.12736000, 2020.00);
INSERT INTO `route_points` VALUES (2084, 6, 9, 98.68328000, 25.12904000, 2100.00);
INSERT INTO `route_points` VALUES (2085, 6, 10, 98.68466000, 25.13012000, 2150.00);
INSERT INTO `route_points` VALUES (2086, 6, 11, 98.68633000, 25.13088000, 2180.00);
INSERT INTO `route_points` VALUES (2087, 6, 12, 98.68814000, 25.13105000, 2160.00);
INSERT INTO `route_points` VALUES (2088, 6, 13, 98.68992000, 25.13021000, 2120.00);
INSERT INTO `route_points` VALUES (2089, 6, 14, 98.69105000, 25.12867000, 2080.00);
INSERT INTO `route_points` VALUES (2090, 6, 15, 98.69188000, 25.12693000, 2050.00);
INSERT INTO `route_points` VALUES (2091, 6, 16, 98.69271000, 25.12519000, 2020.00);
INSERT INTO `route_points` VALUES (2092, 6, 17, 98.69403000, 25.12411000, 1980.00);
INSERT INTO `route_points` VALUES (2093, 6, 18, 98.69587000, 25.12395000, 1950.00);
INSERT INTO `route_points` VALUES (2094, 6, 19, 98.69762000, 25.12483000, 1980.00);
INSERT INTO `route_points` VALUES (2095, 6, 20, 98.69845000, 25.12657000, 2050.00);
INSERT INTO `route_points` VALUES (2096, 6, 21, 98.69812000, 25.12835000, 2120.00);
INSERT INTO `route_points` VALUES (2097, 6, 22, 98.69684000, 25.12982000, 2180.00);
INSERT INTO `route_points` VALUES (2098, 6, 23, 98.69517000, 25.13115000, 2250.00);
INSERT INTO `route_points` VALUES (2099, 6, 24, 98.69350000, 25.13248000, 2320.00);
INSERT INTO `route_points` VALUES (2100, 6, 25, 98.69268000, 25.13393000, 2380.00);
INSERT INTO `route_points` VALUES (2101, 6, 26, 98.69301000, 25.13561000, 2450.00);
INSERT INTO `route_points` VALUES (2102, 6, 27, 98.69439000, 25.13669000, 2500.00);
INSERT INTO `route_points` VALUES (2103, 6, 28, 98.69606000, 25.13745000, 2530.00);
INSERT INTO `route_points` VALUES (2104, 6, 29, 98.69787000, 25.13762000, 2510.00);
INSERT INTO `route_points` VALUES (2105, 6, 30, 98.69965000, 25.13678000, 2470.00);
INSERT INTO `route_points` VALUES (2106, 6, 31, 98.70078000, 25.13524000, 2430.00);
INSERT INTO `route_points` VALUES (2107, 6, 32, 98.70161000, 25.13350000, 2400.00);
INSERT INTO `route_points` VALUES (2108, 6, 33, 98.70244000, 25.13176000, 2370.00);
INSERT INTO `route_points` VALUES (2109, 6, 34, 98.70376000, 25.13068000, 2330.00);
INSERT INTO `route_points` VALUES (2110, 6, 35, 98.70560000, 25.13052000, 2300.00);
INSERT INTO `route_points` VALUES (2111, 6, 36, 98.70735000, 25.13140000, 2330.00);
INSERT INTO `route_points` VALUES (2112, 6, 37, 98.70818000, 25.13314000, 2400.00);
INSERT INTO `route_points` VALUES (2113, 6, 38, 98.70785000, 25.13492000, 2470.00);
INSERT INTO `route_points` VALUES (2114, 6, 39, 98.70657000, 25.13639000, 2530.00);
INSERT INTO `route_points` VALUES (2115, 6, 40, 98.70490000, 25.13772000, 2580.00);
INSERT INTO `route_points` VALUES (2116, 7, 1, 98.79653000, 28.42315000, 3150.00);
INSERT INTO `route_points` VALUES (2117, 7, 2, 98.79821000, 28.42472000, 3180.00);
INSERT INTO `route_points` VALUES (2118, 7, 3, 98.80034000, 28.42588000, 3220.00);
INSERT INTO `route_points` VALUES (2119, 7, 4, 98.80217000, 28.42691000, 3280.00);
INSERT INTO `route_points` VALUES (2120, 7, 5, 98.80345000, 28.42803000, 3320.00);
INSERT INTO `route_points` VALUES (2121, 7, 6, 98.80412000, 28.42965000, 3260.00);
INSERT INTO `route_points` VALUES (2122, 7, 7, 98.80378000, 28.43122000, 3210.00);
INSERT INTO `route_points` VALUES (2123, 7, 8, 98.80291000, 28.43280000, 3170.00);
INSERT INTO `route_points` VALUES (2124, 7, 9, 98.80144000, 28.43395000, 3220.00);
INSERT INTO `route_points` VALUES (2125, 7, 10, 98.80002000, 28.43561000, 3280.00);
INSERT INTO `route_points` VALUES (2126, 7, 11, 98.79935000, 28.43744000, 3350.00);
INSERT INTO `route_points` VALUES (2127, 7, 12, 98.79888000, 28.43927000, 3420.00);
INSERT INTO `route_points` VALUES (2128, 7, 13, 98.79721000, 28.44033000, 3380.00);
INSERT INTO `route_points` VALUES (2129, 7, 14, 98.79548000, 28.44120000, 3320.00);
INSERT INTO `route_points` VALUES (2130, 7, 15, 98.79375000, 28.44207000, 3280.00);
INSERT INTO `route_points` VALUES (2131, 7, 16, 98.79231000, 28.44385000, 3340.00);
INSERT INTO `route_points` VALUES (2132, 7, 17, 98.79164000, 28.44568000, 3410.00);
INSERT INTO `route_points` VALUES (2133, 7, 18, 98.79197000, 28.44751000, 3480.00);
INSERT INTO `route_points` VALUES (2134, 7, 19, 98.79344000, 28.44866000, 3520.00);
INSERT INTO `route_points` VALUES (2135, 7, 20, 98.79517000, 28.44953000, 3470.00);
INSERT INTO `route_points` VALUES (2136, 7, 21, 98.79690000, 28.45040000, 3420.00);
INSERT INTO `route_points` VALUES (2137, 7, 22, 98.79863000, 28.45127000, 3380.00);
INSERT INTO `route_points` VALUES (2138, 7, 23, 98.80036000, 28.45214000, 3450.00);
INSERT INTO `route_points` VALUES (2139, 7, 24, 98.80180000, 28.45392000, 3520.00);
INSERT INTO `route_points` VALUES (2140, 7, 25, 98.80247000, 28.45575000, 3580.00);
INSERT INTO `route_points` VALUES (2141, 7, 26, 98.80214000, 28.45758000, 3530.00);
INSERT INTO `route_points` VALUES (2142, 7, 27, 98.80067000, 28.45873000, 3480.00);
INSERT INTO `route_points` VALUES (2143, 7, 28, 98.79894000, 28.45960000, 3550.00);
INSERT INTO `route_points` VALUES (2144, 7, 29, 98.79721000, 28.46047000, 3620.00);
INSERT INTO `route_points` VALUES (2145, 7, 30, 98.79548000, 28.46134000, 3680.00);
INSERT INTO `route_points` VALUES (2146, 7, 31, 98.79375000, 28.46221000, 3630.00);
INSERT INTO `route_points` VALUES (2147, 7, 32, 98.79202000, 28.46308000, 3570.00);
INSERT INTO `route_points` VALUES (2148, 7, 33, 98.79029000, 28.46395000, 3520.00);
INSERT INTO `route_points` VALUES (2149, 7, 34, 98.78856000, 28.46482000, 3480.00);
INSERT INTO `route_points` VALUES (2150, 7, 35, 98.78683000, 28.46569000, 3550.00);
INSERT INTO `route_points` VALUES (2151, 7, 36, 98.78510000, 28.46656000, 3620.00);
INSERT INTO `route_points` VALUES (2152, 7, 37, 98.78337000, 28.46743000, 3570.00);
INSERT INTO `route_points` VALUES (2153, 7, 38, 98.78164000, 28.46830000, 3510.00);
INSERT INTO `route_points` VALUES (2154, 7, 39, 98.77991000, 28.46917000, 3460.00);
INSERT INTO `route_points` VALUES (2155, 7, 40, 98.77818000, 28.47004000, 3420.00);
INSERT INTO `route_points` VALUES (2156, 8, 1, 102.77912000, 23.08845000, 1560.00);
INSERT INTO `route_points` VALUES (2157, 8, 2, 102.78033000, 23.08912000, 1580.00);
INSERT INTO `route_points` VALUES (2158, 8, 3, 102.78185000, 23.08980000, 1600.00);
INSERT INTO `route_points` VALUES (2159, 8, 4, 102.78210000, 23.09055000, 1620.00);
INSERT INTO `route_points` VALUES (2160, 8, 5, 102.78145000, 23.09120000, 1640.00);
INSERT INTO `route_points` VALUES (2161, 8, 6, 102.78080000, 23.09185000, 1660.00);
INSERT INTO `route_points` VALUES (2162, 8, 7, 102.78015000, 23.09230000, 1680.00);
INSERT INTO `route_points` VALUES (2163, 8, 8, 102.77940000, 23.09275000, 1660.00);
INSERT INTO `route_points` VALUES (2164, 8, 9, 102.77865000, 23.09320000, 1640.00);
INSERT INTO `route_points` VALUES (2165, 8, 10, 102.77790000, 23.09365000, 1620.00);
INSERT INTO `route_points` VALUES (2166, 8, 11, 102.77715000, 23.09410000, 1600.00);
INSERT INTO `route_points` VALUES (2167, 8, 12, 102.77640000, 23.09455000, 1580.00);
INSERT INTO `route_points` VALUES (2168, 8, 13, 102.77565000, 23.09500000, 1560.00);
INSERT INTO `route_points` VALUES (2169, 8, 14, 102.77490000, 23.09545000, 1540.00);
INSERT INTO `route_points` VALUES (2170, 8, 15, 102.77415000, 23.09590000, 1520.00);
INSERT INTO `route_points` VALUES (2171, 8, 16, 102.77340000, 23.09635000, 1500.00);
INSERT INTO `route_points` VALUES (2172, 8, 17, 102.77265000, 23.09680000, 1480.00);
INSERT INTO `route_points` VALUES (2173, 8, 18, 102.77190000, 23.09725000, 1460.00);
INSERT INTO `route_points` VALUES (2174, 8, 19, 102.77115000, 23.09770000, 1440.00);
INSERT INTO `route_points` VALUES (2175, 8, 20, 102.77040000, 23.09815000, 1420.00);
INSERT INTO `route_points` VALUES (2176, 8, 21, 102.76965000, 23.09860000, 1400.00);
INSERT INTO `route_points` VALUES (2177, 8, 22, 102.76890000, 23.09905000, 1380.00);
INSERT INTO `route_points` VALUES (2178, 8, 23, 102.76815000, 23.09950000, 1360.00);
INSERT INTO `route_points` VALUES (2179, 8, 24, 102.76740000, 23.09995000, 1340.00);
INSERT INTO `route_points` VALUES (2180, 8, 25, 102.76665000, 23.10040000, 1320.00);
INSERT INTO `route_points` VALUES (2181, 8, 26, 102.76590000, 23.10085000, 1300.00);
INSERT INTO `route_points` VALUES (2182, 8, 27, 102.76515000, 23.10130000, 1280.00);
INSERT INTO `route_points` VALUES (2183, 8, 28, 102.76440000, 23.10175000, 1260.00);
INSERT INTO `route_points` VALUES (2184, 8, 29, 102.76365000, 23.10220000, 1240.00);
INSERT INTO `route_points` VALUES (2185, 8, 30, 102.76290000, 23.10265000, 1220.00);
INSERT INTO `route_points` VALUES (2186, 8, 31, 102.76215000, 23.10310000, 1200.00);
INSERT INTO `route_points` VALUES (2187, 8, 32, 102.76140000, 23.10355000, 1180.00);
INSERT INTO `route_points` VALUES (2188, 8, 33, 102.76065000, 23.10400000, 1160.00);
INSERT INTO `route_points` VALUES (2189, 8, 34, 102.75990000, 23.10445000, 1140.00);
INSERT INTO `route_points` VALUES (2190, 8, 35, 102.75915000, 23.10490000, 1120.00);
INSERT INTO `route_points` VALUES (2191, 8, 36, 102.75840000, 23.10535000, 1100.00);
INSERT INTO `route_points` VALUES (2192, 8, 37, 102.75765000, 23.10580000, 1080.00);
INSERT INTO `route_points` VALUES (2193, 8, 38, 102.75690000, 23.10625000, 1060.00);
INSERT INTO `route_points` VALUES (2194, 8, 39, 102.75615000, 23.10670000, 1040.00);
INSERT INTO `route_points` VALUES (2195, 8, 40, 102.75540000, 23.10715000, 1020.00);
INSERT INTO `route_points` VALUES (2196, 9, 1, 86.83215000, 43.75128000, 2100.00);
INSERT INTO `route_points` VALUES (2197, 9, 2, 86.83572000, 43.75341000, 2250.00);
INSERT INTO `route_points` VALUES (2198, 9, 3, 86.83890000, 43.75633000, 2450.00);
INSERT INTO `route_points` VALUES (2199, 9, 4, 86.84125000, 43.75918000, 2680.00);
INSERT INTO `route_points` VALUES (2200, 9, 5, 86.84001000, 43.76294000, 2950.00);
INSERT INTO `route_points` VALUES (2201, 9, 6, 86.83763000, 43.76520000, 3120.00);
INSERT INTO `route_points` VALUES (2202, 9, 7, 86.83495000, 43.76788000, 3380.00);
INSERT INTO `route_points` VALUES (2203, 9, 8, 86.83210000, 43.77005000, 3650.00);
INSERT INTO `route_points` VALUES (2204, 9, 9, 86.82945000, 43.77291000, 3880.00);
INSERT INTO `route_points` VALUES (2205, 9, 10, 86.82780000, 43.77644000, 3520.00);
INSERT INTO `route_points` VALUES (2206, 9, 11, 86.82533000, 43.77921000, 3300.00);
INSERT INTO `route_points` VALUES (2207, 9, 12, 86.82294000, 43.78207000, 3450.00);
INSERT INTO `route_points` VALUES (2208, 9, 13, 86.82015000, 43.78492000, 3680.00);
INSERT INTO `route_points` VALUES (2209, 9, 14, 86.81729000, 43.78760000, 3920.00);
INSERT INTO `route_points` VALUES (2210, 9, 15, 86.81452000, 43.79033000, 4150.00);
INSERT INTO `route_points` VALUES (2211, 9, 16, 86.81188000, 43.79315000, 3880.00);
INSERT INTO `route_points` VALUES (2212, 9, 17, 86.80921000, 43.79582000, 3650.00);
INSERT INTO `route_points` VALUES (2213, 9, 18, 86.80654000, 43.79849000, 3420.00);
INSERT INTO `route_points` VALUES (2214, 9, 19, 86.80387000, 43.80116000, 3650.00);
INSERT INTO `route_points` VALUES (2215, 9, 20, 86.80120000, 43.80383000, 3900.00);
INSERT INTO `route_points` VALUES (2216, 9, 21, 86.79853000, 43.80650000, 4120.00);
INSERT INTO `route_points` VALUES (2217, 9, 22, 86.79586000, 43.80917000, 3850.00);
INSERT INTO `route_points` VALUES (2218, 9, 23, 86.79319000, 43.81184000, 3600.00);
INSERT INTO `route_points` VALUES (2219, 9, 24, 86.79052000, 43.81451000, 3820.00);
INSERT INTO `route_points` VALUES (2220, 9, 25, 86.78785000, 43.81718000, 4050.00);
INSERT INTO `route_points` VALUES (2221, 9, 26, 86.78518000, 43.81985000, 4280.00);
INSERT INTO `route_points` VALUES (2222, 9, 27, 86.78251000, 43.82252000, 4000.00);
INSERT INTO `route_points` VALUES (2223, 9, 28, 86.77984000, 43.82519000, 3750.00);
INSERT INTO `route_points` VALUES (2224, 9, 29, 86.77717000, 43.82786000, 3950.00);
INSERT INTO `route_points` VALUES (2225, 9, 30, 86.77450000, 43.83053000, 4180.00);
INSERT INTO `route_points` VALUES (2226, 9, 31, 86.77183000, 43.83320000, 4400.00);
INSERT INTO `route_points` VALUES (2227, 9, 32, 86.76916000, 43.83587000, 4150.00);
INSERT INTO `route_points` VALUES (2228, 9, 33, 86.76649000, 43.83854000, 3900.00);
INSERT INTO `route_points` VALUES (2229, 9, 34, 86.76382000, 43.84121000, 4100.00);
INSERT INTO `route_points` VALUES (2230, 9, 35, 86.76115000, 43.84388000, 4320.00);
INSERT INTO `route_points` VALUES (2231, 9, 36, 86.75848000, 43.84655000, 4550.00);
INSERT INTO `route_points` VALUES (2232, 9, 37, 86.75581000, 43.84922000, 4300.00);
INSERT INTO `route_points` VALUES (2233, 9, 38, 86.75314000, 43.85189000, 4050.00);
INSERT INTO `route_points` VALUES (2234, 9, 39, 86.75047000, 43.85456000, 3800.00);
INSERT INTO `route_points` VALUES (2235, 9, 40, 86.74780000, 43.85723000, 3550.00);
INSERT INTO `route_points` VALUES (2236, 10, 1, 81.15233000, 42.98745000, 1850.00);
INSERT INTO `route_points` VALUES (2237, 10, 2, 81.15367000, 42.98812000, 1870.00);
INSERT INTO `route_points` VALUES (2238, 10, 3, 81.15502000, 42.98890000, 1900.00);
INSERT INTO `route_points` VALUES (2239, 10, 4, 81.15610000, 42.98955000, 1930.00);
INSERT INTO `route_points` VALUES (2240, 10, 5, 81.15688000, 42.99020000, 1960.00);
INSERT INTO `route_points` VALUES (2241, 10, 6, 81.15675000, 42.99105000, 1980.00);
INSERT INTO `route_points` VALUES (2242, 10, 7, 81.15620000, 42.99188000, 2010.00);
INSERT INTO `route_points` VALUES (2243, 10, 8, 81.15545000, 42.99260000, 2040.00);
INSERT INTO `route_points` VALUES (2244, 10, 9, 81.15433000, 42.99315000, 2070.00);
INSERT INTO `route_points` VALUES (2245, 10, 10, 81.15310000, 42.99340000, 2050.00);
INSERT INTO `route_points` VALUES (2246, 10, 11, 81.15188000, 42.99375000, 2030.00);
INSERT INTO `route_points` VALUES (2247, 10, 12, 81.15095000, 42.99450000, 2000.00);
INSERT INTO `route_points` VALUES (2248, 10, 13, 81.15020000, 42.99533000, 1980.00);
INSERT INTO `route_points` VALUES (2249, 10, 14, 81.14985000, 42.99620000, 1950.00);
INSERT INTO `route_points` VALUES (2250, 10, 15, 81.14990000, 42.99705000, 1920.00);
INSERT INTO `route_points` VALUES (2251, 10, 16, 81.15035000, 42.99785000, 1900.00);
INSERT INTO `route_points` VALUES (2252, 10, 17, 81.15120000, 42.99840000, 1880.00);
INSERT INTO `route_points` VALUES (2253, 10, 18, 81.15215000, 42.99875000, 1860.00);
INSERT INTO `route_points` VALUES (2254, 10, 19, 81.15300000, 42.99910000, 1840.00);
INSERT INTO `route_points` VALUES (2255, 10, 20, 81.15385000, 42.99955000, 1820.00);
INSERT INTO `route_points` VALUES (2256, 10, 21, 81.15470000, 43.00020000, 1800.00);
INSERT INTO `route_points` VALUES (2257, 10, 22, 81.15530000, 43.00105000, 1780.00);
INSERT INTO `route_points` VALUES (2258, 10, 23, 81.15565000, 43.00200000, 1760.00);
INSERT INTO `route_points` VALUES (2259, 10, 24, 81.15550000, 43.00295000, 1740.00);
INSERT INTO `route_points` VALUES (2260, 10, 25, 81.15505000, 43.00380000, 1720.00);
INSERT INTO `route_points` VALUES (2261, 10, 26, 81.15420000, 43.00445000, 1700.00);
INSERT INTO `route_points` VALUES (2262, 10, 27, 81.15315000, 43.00490000, 1720.00);
INSERT INTO `route_points` VALUES (2263, 10, 28, 81.15200000, 43.00515000, 1750.00);
INSERT INTO `route_points` VALUES (2264, 10, 29, 81.15085000, 43.00540000, 1780.00);
INSERT INTO `route_points` VALUES (2265, 10, 30, 81.14970000, 43.00575000, 1810.00);
INSERT INTO `route_points` VALUES (2266, 10, 31, 81.14865000, 43.00630000, 1840.00);
INSERT INTO `route_points` VALUES (2267, 10, 32, 81.14780000, 43.00705000, 1870.00);
INSERT INTO `route_points` VALUES (2268, 10, 33, 81.14715000, 43.00790000, 1900.00);
INSERT INTO `route_points` VALUES (2269, 10, 34, 81.14670000, 43.00885000, 1930.00);
INSERT INTO `route_points` VALUES (2270, 10, 35, 81.14645000, 43.00980000, 1960.00);
INSERT INTO `route_points` VALUES (2271, 10, 36, 81.14640000, 43.01075000, 1990.00);
INSERT INTO `route_points` VALUES (2272, 10, 37, 81.14655000, 43.01170000, 2020.00);
INSERT INTO `route_points` VALUES (2273, 10, 38, 81.14690000, 43.01255000, 2050.00);
INSERT INTO `route_points` VALUES (2274, 10, 39, 81.14745000, 43.01330000, 2030.00);
INSERT INTO `route_points` VALUES (2275, 10, 40, 81.14820000, 43.01395000, 2000.00);
INSERT INTO `route_points` VALUES (2276, 11, 1, 80.17532000, 42.01345000, 2654.00);
INSERT INTO `route_points` VALUES (2277, 11, 2, 80.17856000, 42.01522000, 2816.00);
INSERT INTO `route_points` VALUES (2278, 11, 3, 80.18189000, 42.01678000, 2909.00);
INSERT INTO `route_points` VALUES (2279, 11, 4, 80.18412000, 42.01891000, 3033.00);
INSERT INTO `route_points` VALUES (2280, 11, 5, 80.18245000, 42.02134000, 3074.00);
INSERT INTO `route_points` VALUES (2281, 11, 6, 80.17988000, 42.02367000, 3114.00);
INSERT INTO `route_points` VALUES (2282, 11, 7, 80.17721000, 42.02512000, 3121.00);
INSERT INTO `route_points` VALUES (2283, 11, 8, 80.17433000, 42.02655000, 3125.00);
INSERT INTO `route_points` VALUES (2284, 11, 9, 80.17189000, 42.02891000, 3120.00);
INSERT INTO `route_points` VALUES (2285, 11, 10, 80.16945000, 42.03127000, 3181.00);
INSERT INTO `route_points` VALUES (2286, 11, 11, 80.16712000, 42.03364000, 3330.00);
INSERT INTO `route_points` VALUES (2287, 11, 12, 80.16478000, 42.03521000, 3271.00);
INSERT INTO `route_points` VALUES (2288, 11, 13, 80.16234000, 42.03688000, 3296.00);
INSERT INTO `route_points` VALUES (2289, 11, 14, 80.15991000, 42.03845000, 3148.00);
INSERT INTO `route_points` VALUES (2290, 11, 15, 80.15747000, 42.03992000, 3111.00);
INSERT INTO `route_points` VALUES (2291, 11, 16, 80.15503000, 42.04139000, 3090.00);
INSERT INTO `route_points` VALUES (2292, 11, 17, 80.15259000, 42.04286000, 3065.00);
INSERT INTO `route_points` VALUES (2293, 11, 18, 80.15015000, 42.04433000, 3128.00);
INSERT INTO `route_points` VALUES (2294, 11, 19, 80.14771000, 42.04580000, 3425.00);
INSERT INTO `route_points` VALUES (2295, 11, 20, 80.14527000, 42.04727000, 3642.00);
INSERT INTO `route_points` VALUES (2296, 11, 21, 80.14283000, 42.04874000, 4003.00);
INSERT INTO `route_points` VALUES (2297, 11, 22, 80.14039000, 42.05021000, 4269.00);
INSERT INTO `route_points` VALUES (2298, 11, 23, 80.13795000, 42.05168000, 4456.00);
INSERT INTO `route_points` VALUES (2299, 11, 24, 80.13551000, 42.05315000, 4736.00);
INSERT INTO `route_points` VALUES (2300, 11, 25, 80.13307000, 42.05462000, 4753.00);
INSERT INTO `route_points` VALUES (2301, 11, 26, 80.13063000, 42.05609000, 4690.00);
INSERT INTO `route_points` VALUES (2302, 11, 27, 80.12819000, 42.05756000, 4601.00);
INSERT INTO `route_points` VALUES (2303, 11, 28, 80.12575000, 42.05903000, 4488.00);
INSERT INTO `route_points` VALUES (2304, 11, 29, 80.12331000, 42.06050000, 4462.00);
INSERT INTO `route_points` VALUES (2305, 11, 30, 80.12087000, 42.06197000, 4322.00);
INSERT INTO `route_points` VALUES (2306, 11, 31, 80.11843000, 42.06344000, 4379.00);
INSERT INTO `route_points` VALUES (2307, 11, 32, 80.11599000, 42.06491000, 4365.00);
INSERT INTO `route_points` VALUES (2308, 11, 33, 80.11355000, 42.06638000, 4538.00);
INSERT INTO `route_points` VALUES (2309, 11, 34, 80.11111000, 42.06785000, 4589.00);
INSERT INTO `route_points` VALUES (2310, 11, 35, 80.10867000, 42.06932000, 4697.00);
INSERT INTO `route_points` VALUES (2311, 11, 36, 80.10623000, 42.07079000, 4654.00);
INSERT INTO `route_points` VALUES (2312, 11, 37, 80.10379000, 42.07226000, 4688.00);
INSERT INTO `route_points` VALUES (2313, 11, 38, 80.10135000, 42.07373000, 4736.00);
INSERT INTO `route_points` VALUES (2314, 11, 39, 80.09891000, 42.07520000, 4821.00);
INSERT INTO `route_points` VALUES (2315, 11, 40, 80.09647000, 42.07667000, 5076.00);
INSERT INTO `route_points` VALUES (2316, 12, 1, 86.85432000, 28.13765000, 4387.00);
INSERT INTO `route_points` VALUES (2317, 12, 2, 86.85678000, 28.13921000, 4495.00);
INSERT INTO `route_points` VALUES (2318, 12, 3, 86.85943000, 28.14088000, 4528.00);
INSERT INTO `route_points` VALUES (2319, 12, 4, 86.86217000, 28.14205000, 4592.00);
INSERT INTO `route_points` VALUES (2320, 12, 5, 86.86492000, 28.14311000, 4586.00);
INSERT INTO `route_points` VALUES (2321, 12, 6, 86.86735000, 28.14489000, 4596.00);
INSERT INTO `route_points` VALUES (2322, 12, 7, 86.86901000, 28.14732000, 4615.00);
INSERT INTO `route_points` VALUES (2323, 12, 8, 86.87022000, 28.15014000, 4616.00);
INSERT INTO `route_points` VALUES (2324, 12, 9, 86.87105000, 28.15327000, 4631.00);
INSERT INTO `route_points` VALUES (2325, 12, 10, 86.87188000, 28.15641000, 4651.00);
INSERT INTO `route_points` VALUES (2326, 12, 11, 86.87234000, 28.15975000, 4680.00);
INSERT INTO `route_points` VALUES (2327, 12, 12, 86.87201000, 28.16298000, 4659.00);
INSERT INTO `route_points` VALUES (2328, 12, 13, 86.87129000, 28.16612000, 4645.00);
INSERT INTO `route_points` VALUES (2329, 12, 14, 86.87015000, 28.16904000, 4632.00);
INSERT INTO `route_points` VALUES (2330, 12, 15, 86.86892000, 28.17187000, 4608.00);
INSERT INTO `route_points` VALUES (2331, 12, 16, 86.86748000, 28.17459000, 4570.00);
INSERT INTO `route_points` VALUES (2332, 12, 17, 86.86583000, 28.17721000, 4596.00);
INSERT INTO `route_points` VALUES (2333, 12, 18, 86.86407000, 28.17973000, 4608.00);
INSERT INTO `route_points` VALUES (2334, 12, 19, 86.86221000, 28.18215000, 4718.00);
INSERT INTO `route_points` VALUES (2335, 12, 20, 86.86034000, 28.18447000, 4841.00);
INSERT INTO `route_points` VALUES (2336, 12, 21, 86.85847000, 28.18669000, 4944.00);
INSERT INTO `route_points` VALUES (2337, 12, 22, 86.85660000, 28.18881000, 5069.00);
INSERT INTO `route_points` VALUES (2338, 12, 23, 86.85473000, 28.19083000, 5190.00);
INSERT INTO `route_points` VALUES (2339, 12, 24, 86.85286000, 28.19275000, 5269.00);
INSERT INTO `route_points` VALUES (2340, 12, 25, 86.85099000, 28.19457000, 5316.00);
INSERT INTO `route_points` VALUES (2341, 12, 26, 86.84912000, 28.19629000, 5298.00);
INSERT INTO `route_points` VALUES (2342, 12, 27, 86.84725000, 28.19791000, 5263.00);
INSERT INTO `route_points` VALUES (2343, 12, 28, 86.84538000, 28.19943000, 5219.00);
INSERT INTO `route_points` VALUES (2344, 12, 29, 86.84351000, 28.20085000, 5172.00);
INSERT INTO `route_points` VALUES (2345, 12, 30, 86.84164000, 28.20217000, 5117.00);
INSERT INTO `route_points` VALUES (2346, 12, 31, 86.83977000, 28.20339000, 5152.00);
INSERT INTO `route_points` VALUES (2347, 12, 32, 86.83790000, 28.20451000, 5185.00);
INSERT INTO `route_points` VALUES (2348, 12, 33, 86.83603000, 28.20553000, 5210.00);
INSERT INTO `route_points` VALUES (2349, 12, 34, 86.83416000, 28.20645000, 5234.00);
INSERT INTO `route_points` VALUES (2350, 12, 35, 86.83229000, 28.20727000, 5257.00);
INSERT INTO `route_points` VALUES (2351, 12, 36, 86.83042000, 28.20799000, 5307.00);
INSERT INTO `route_points` VALUES (2352, 12, 37, 86.82855000, 28.20861000, 5279.00);
INSERT INTO `route_points` VALUES (2353, 12, 38, 86.82668000, 28.20913000, 5307.00);
INSERT INTO `route_points` VALUES (2354, 12, 39, 86.82481000, 28.20955000, 5333.00);
INSERT INTO `route_points` VALUES (2355, 12, 40, 86.82294000, 28.20987000, 5391.00);
INSERT INTO `route_points` VALUES (2356, 13, 1, 81.30694000, 31.06944000, 4675.00);
INSERT INTO `route_points` VALUES (2357, 13, 2, 81.30861000, 31.07111000, 4690.00);
INSERT INTO `route_points` VALUES (2358, 13, 3, 81.31139000, 31.07278000, 4720.00);
INSERT INTO `route_points` VALUES (2359, 13, 4, 81.31389000, 31.07417000, 4750.00);
INSERT INTO `route_points` VALUES (2360, 13, 5, 81.31528000, 31.07611000, 4780.00);
INSERT INTO `route_points` VALUES (2361, 13, 6, 81.31472000, 31.07833000, 4820.00);
INSERT INTO `route_points` VALUES (2362, 13, 7, 81.31306000, 31.08056000, 4860.00);
INSERT INTO `route_points` VALUES (2363, 13, 8, 81.31167000, 31.08278000, 4900.00);
INSERT INTO `route_points` VALUES (2364, 13, 9, 81.31250000, 31.08500000, 4950.00);
INSERT INTO `route_points` VALUES (2365, 13, 10, 81.31417000, 31.08694000, 5000.00);
INSERT INTO `route_points` VALUES (2366, 13, 11, 81.31639000, 31.08806000, 5030.00);
INSERT INTO `route_points` VALUES (2367, 13, 12, 81.31889000, 31.08917000, 5060.00);
INSERT INTO `route_points` VALUES (2368, 13, 13, 81.32111000, 31.09028000, 5100.00);
INSERT INTO `route_points` VALUES (2369, 13, 14, 81.32306000, 31.09139000, 5150.00);
INSERT INTO `route_points` VALUES (2370, 13, 15, 81.32472000, 31.09306000, 5200.00);
INSERT INTO `route_points` VALUES (2371, 13, 16, 81.32583000, 31.09528000, 5250.00);
INSERT INTO `route_points` VALUES (2372, 13, 17, 81.32639000, 31.09778000, 5300.00);
INSERT INTO `route_points` VALUES (2373, 13, 18, 81.32556000, 31.10000000, 5350.00);
INSERT INTO `route_points` VALUES (2374, 13, 19, 81.32389000, 31.10194000, 5400.00);
INSERT INTO `route_points` VALUES (2375, 13, 20, 81.32194000, 31.10361000, 5450.00);
INSERT INTO `route_points` VALUES (2376, 13, 21, 81.32028000, 31.10556000, 5500.00);
INSERT INTO `route_points` VALUES (2377, 13, 22, 81.31917000, 31.10778000, 5550.00);
INSERT INTO `route_points` VALUES (2378, 13, 23, 81.31889000, 31.11000000, 5600.00);
INSERT INTO `route_points` VALUES (2379, 13, 24, 81.31972000, 31.11222000, 5630.00);
INSERT INTO `route_points` VALUES (2380, 13, 25, 81.32139000, 31.11417000, 5650.00);
INSERT INTO `route_points` VALUES (2381, 13, 26, 81.32361000, 31.11556000, 5620.00);
INSERT INTO `route_points` VALUES (2382, 13, 27, 81.32583000, 31.11694000, 5580.00);
INSERT INTO `route_points` VALUES (2383, 13, 28, 81.32778000, 31.11861000, 5550.00);
INSERT INTO `route_points` VALUES (2384, 13, 29, 81.32917000, 31.12083000, 5520.00);
INSERT INTO `route_points` VALUES (2385, 13, 30, 81.32972000, 31.12333000, 5480.00);
INSERT INTO `route_points` VALUES (2386, 13, 31, 81.32889000, 31.12556000, 5450.00);
INSERT INTO `route_points` VALUES (2387, 13, 32, 81.32722000, 31.12778000, 5420.00);
INSERT INTO `route_points` VALUES (2388, 13, 33, 81.32528000, 31.12972000, 5400.00);
INSERT INTO `route_points` VALUES (2389, 13, 34, 81.32306000, 31.13139000, 5380.00);
INSERT INTO `route_points` VALUES (2390, 13, 35, 81.32083000, 31.13278000, 5350.00);
INSERT INTO `route_points` VALUES (2391, 13, 36, 81.31861000, 31.13417000, 5320.00);
INSERT INTO `route_points` VALUES (2392, 13, 37, 81.31667000, 31.13583000, 5300.00);
INSERT INTO `route_points` VALUES (2393, 13, 38, 81.31528000, 31.13778000, 5280.00);
INSERT INTO `route_points` VALUES (2394, 13, 39, 81.31472000, 31.14000000, 5250.00);
INSERT INTO `route_points` VALUES (2395, 13, 40, 81.31556000, 31.14222000, 5220.00);
INSERT INTO `route_points` VALUES (2396, 14, 1, 100.74312000, 33.28547000, 3980.00);
INSERT INTO `route_points` VALUES (2397, 14, 2, 100.74588000, 33.28691000, 4010.00);
INSERT INTO `route_points` VALUES (2398, 14, 3, 100.74833000, 33.28805000, 4050.00);
INSERT INTO `route_points` VALUES (2399, 14, 4, 100.74901000, 33.29022000, 4120.00);
INSERT INTO `route_points` VALUES (2400, 14, 5, 100.74759000, 33.29215000, 4180.00);
INSERT INTO `route_points` VALUES (2401, 14, 6, 100.74480000, 33.29388000, 4230.00);
INSERT INTO `route_points` VALUES (2402, 14, 7, 100.74215000, 33.29561000, 4280.00);
INSERT INTO `route_points` VALUES (2403, 14, 8, 100.73940000, 33.29674000, 4250.00);
INSERT INTO `route_points` VALUES (2404, 14, 9, 100.73665000, 33.29750000, 4220.00);
INSERT INTO `route_points` VALUES (2405, 14, 10, 100.73490000, 33.29933000, 4270.00);
INSERT INTO `route_points` VALUES (2406, 14, 11, 100.73558000, 33.30186000, 4350.00);
INSERT INTO `route_points` VALUES (2407, 14, 12, 100.73702000, 33.30439000, 4420.00);
INSERT INTO `route_points` VALUES (2408, 14, 13, 100.73615000, 33.30692000, 4450.00);
INSERT INTO `route_points` VALUES (2409, 14, 14, 100.73336000, 33.30865000, 4400.00);
INSERT INTO `route_points` VALUES (2410, 14, 15, 100.73057000, 33.30978000, 4380.00);
INSERT INTO `route_points` VALUES (2411, 14, 16, 100.72778000, 33.31054000, 4350.00);
INSERT INTO `route_points` VALUES (2412, 14, 17, 100.72509000, 33.31237000, 4400.00);
INSERT INTO `route_points` VALUES (2413, 14, 18, 100.72431000, 33.31510000, 4480.00);
INSERT INTO `route_points` VALUES (2414, 14, 19, 100.72565000, 33.31783000, 4550.00);
INSERT INTO `route_points` VALUES (2415, 14, 20, 100.72458000, 33.32056000, 4580.00);
INSERT INTO `route_points` VALUES (2416, 14, 21, 100.72169000, 33.32209000, 4520.00);
INSERT INTO `route_points` VALUES (2417, 14, 22, 100.71880000, 33.32325000, 4480.00);
INSERT INTO `route_points` VALUES (2418, 14, 23, 100.71591000, 33.32441000, 4450.00);
INSERT INTO `route_points` VALUES (2419, 14, 24, 100.71322000, 33.32604000, 4500.00);
INSERT INTO `route_points` VALUES (2420, 14, 25, 100.71234000, 33.32897000, 4580.00);
INSERT INTO `route_points` VALUES (2421, 14, 26, 100.71358000, 33.33190000, 4650.00);
INSERT INTO `route_points` VALUES (2422, 14, 27, 100.71231000, 33.33483000, 4680.00);
INSERT INTO `route_points` VALUES (2423, 14, 28, 100.70932000, 33.33616000, 4620.00);
INSERT INTO `route_points` VALUES (2424, 14, 29, 100.70633000, 33.33712000, 4580.00);
INSERT INTO `route_points` VALUES (2425, 14, 30, 100.70334000, 33.33808000, 4550.00);
INSERT INTO `route_points` VALUES (2426, 14, 31, 100.70065000, 33.33951000, 4600.00);
INSERT INTO `route_points` VALUES (2427, 14, 32, 100.69967000, 33.34264000, 4680.00);
INSERT INTO `route_points` VALUES (2428, 14, 33, 100.70081000, 33.34577000, 4750.00);
INSERT INTO `route_points` VALUES (2429, 14, 34, 100.69944000, 33.34890000, 4780.00);
INSERT INTO `route_points` VALUES (2430, 14, 35, 100.69635000, 33.35003000, 4720.00);
INSERT INTO `route_points` VALUES (2431, 14, 36, 100.69326000, 33.35079000, 4680.00);
INSERT INTO `route_points` VALUES (2432, 14, 37, 100.69017000, 33.35155000, 4650.00);
INSERT INTO `route_points` VALUES (2433, 14, 38, 100.68738000, 33.35298000, 4700.00);
INSERT INTO `route_points` VALUES (2434, 14, 39, 100.68630000, 33.35631000, 4780.00);
INSERT INTO `route_points` VALUES (2435, 14, 40, 100.68734000, 33.35964000, 4850.00);
INSERT INTO `route_points` VALUES (2436, 15, 1, 102.90512000, 34.18753000, 2950.00);
INSERT INTO `route_points` VALUES (2437, 15, 2, 102.90785000, 34.18821000, 2980.00);
INSERT INTO `route_points` VALUES (2438, 15, 3, 102.91033000, 34.18974000, 3020.00);
INSERT INTO `route_points` VALUES (2439, 15, 4, 102.91218000, 34.19105000, 3080.00);
INSERT INTO `route_points` VALUES (2440, 15, 5, 102.91142000, 34.19267000, 3120.00);
INSERT INTO `route_points` VALUES (2441, 15, 6, 102.90988000, 34.19355000, 3150.00);
INSERT INTO `route_points` VALUES (2442, 15, 7, 102.90761000, 34.19412000, 3180.00);
INSERT INTO `route_points` VALUES (2443, 15, 8, 102.90594000, 34.19588000, 3220.00);
INSERT INTO `route_points` VALUES (2444, 15, 9, 102.90437000, 34.19725000, 3280.00);
INSERT INTO `route_points` VALUES (2445, 15, 10, 102.90215000, 34.19801000, 3250.00);
INSERT INTO `route_points` VALUES (2446, 15, 11, 102.89983000, 34.19934000, 3220.00);
INSERT INTO `route_points` VALUES (2447, 15, 12, 102.89762000, 34.20057000, 3180.00);
INSERT INTO `route_points` VALUES (2448, 15, 13, 102.89541000, 34.20192000, 3150.00);
INSERT INTO `route_points` VALUES (2449, 15, 14, 102.89325000, 34.20318000, 3120.00);
INSERT INTO `route_points` VALUES (2450, 15, 15, 102.89107000, 34.20465000, 3100.00);
INSERT INTO `route_points` VALUES (2451, 15, 16, 102.88943000, 34.20632000, 3080.00);
INSERT INTO `route_points` VALUES (2452, 15, 17, 102.88792000, 34.20814000, 3120.00);
INSERT INTO `route_points` VALUES (2453, 15, 18, 102.88655000, 34.20987000, 3180.00);
INSERT INTO `route_points` VALUES (2454, 15, 19, 102.88521000, 34.21163000, 3220.00);
INSERT INTO `route_points` VALUES (2455, 15, 20, 102.88374000, 34.21325000, 3180.00);
INSERT INTO `route_points` VALUES (2456, 15, 21, 102.88209000, 34.21488000, 3150.00);
INSERT INTO `route_points` VALUES (2457, 15, 22, 102.88047000, 34.21652000, 3120.00);
INSERT INTO `route_points` VALUES (2458, 15, 23, 102.87885000, 34.21816000, 3100.00);
INSERT INTO `route_points` VALUES (2459, 15, 24, 102.87723000, 34.21979000, 3080.00);
INSERT INTO `route_points` VALUES (2460, 15, 25, 102.87561000, 34.22143000, 3120.00);
INSERT INTO `route_points` VALUES (2461, 15, 26, 102.87399000, 34.22306000, 3180.00);
INSERT INTO `route_points` VALUES (2462, 15, 27, 102.87237000, 34.22470000, 3220.00);
INSERT INTO `route_points` VALUES (2463, 15, 28, 102.87075000, 34.22633000, 3180.00);
INSERT INTO `route_points` VALUES (2464, 15, 29, 102.86913000, 34.22797000, 3150.00);
INSERT INTO `route_points` VALUES (2465, 15, 30, 102.86751000, 34.22960000, 3120.00);
INSERT INTO `route_points` VALUES (2466, 15, 31, 102.86589000, 34.23124000, 3100.00);
INSERT INTO `route_points` VALUES (2467, 15, 32, 102.86427000, 34.23287000, 3080.00);
INSERT INTO `route_points` VALUES (2468, 15, 33, 102.86265000, 34.23451000, 3120.00);
INSERT INTO `route_points` VALUES (2469, 15, 34, 102.86103000, 34.23614000, 3180.00);
INSERT INTO `route_points` VALUES (2470, 15, 35, 102.85941000, 34.23778000, 3220.00);
INSERT INTO `route_points` VALUES (2471, 15, 36, 102.85779000, 34.23941000, 3180.00);
INSERT INTO `route_points` VALUES (2472, 15, 37, 102.85617000, 34.24105000, 3150.00);
INSERT INTO `route_points` VALUES (2473, 15, 38, 102.85455000, 34.24268000, 3120.00);
INSERT INTO `route_points` VALUES (2474, 15, 39, 102.85293000, 34.24432000, 3100.00);
INSERT INTO `route_points` VALUES (2475, 15, 40, 102.85131000, 34.24595000, 3080.00);
INSERT INTO `route_points` VALUES (2476, 16, 1, 120.91345000, 28.71562000, 420.00);
INSERT INTO `route_points` VALUES (2477, 16, 2, 120.91588000, 28.71633000, 460.00);
INSERT INTO `route_points` VALUES (2478, 16, 3, 120.91712000, 28.71785000, 510.00);
INSERT INTO `route_points` VALUES (2479, 16, 4, 120.91678000, 28.71904000, 580.00);
INSERT INTO `route_points` VALUES (2480, 16, 5, 120.91522000, 28.71991000, 640.00);
INSERT INTO `route_points` VALUES (2481, 16, 6, 120.91405000, 28.72137000, 720.00);
INSERT INTO `route_points` VALUES (2482, 16, 7, 120.91388000, 28.72315000, 790.00);
INSERT INTO `route_points` VALUES (2483, 16, 8, 120.91492000, 28.72468000, 850.00);
INSERT INTO `route_points` VALUES (2484, 16, 9, 120.91655000, 28.72541000, 920.00);
INSERT INTO `route_points` VALUES (2485, 16, 10, 120.91833000, 28.72479000, 980.00);
INSERT INTO `route_points` VALUES (2486, 16, 11, 120.91947000, 28.72326000, 1040.00);
INSERT INTO `route_points` VALUES (2487, 16, 12, 120.92063000, 28.72194000, 1100.00);
INSERT INTO `route_points` VALUES (2488, 16, 13, 120.92218000, 28.72255000, 1150.00);
INSERT INTO `route_points` VALUES (2489, 16, 14, 120.92371000, 28.72388000, 1190.00);
INSERT INTO `route_points` VALUES (2490, 16, 15, 120.92495000, 28.72532000, 1240.00);
INSERT INTO `route_points` VALUES (2491, 16, 16, 120.92436000, 28.72697000, 1280.00);
INSERT INTO `route_points` VALUES (2492, 16, 17, 120.92284000, 28.72813000, 1320.00);
INSERT INTO `route_points` VALUES (2493, 16, 18, 120.92105000, 28.72944000, 1360.00);
INSERT INTO `route_points` VALUES (2494, 16, 19, 120.91977000, 28.73102000, 1380.00);
INSERT INTO `route_points` VALUES (2495, 16, 20, 120.92014000, 28.73285000, 1340.00);
INSERT INTO `route_points` VALUES (2496, 16, 21, 120.92168000, 28.73392000, 1300.00);
INSERT INTO `route_points` VALUES (2497, 16, 22, 120.92342000, 28.73466000, 1260.00);
INSERT INTO `route_points` VALUES (2498, 16, 23, 120.92517000, 28.73531000, 1220.00);
INSERT INTO `route_points` VALUES (2499, 16, 24, 120.92683000, 28.73645000, 1180.00);
INSERT INTO `route_points` VALUES (2500, 16, 25, 120.92794000, 28.73811000, 1140.00);
INSERT INTO `route_points` VALUES (2501, 16, 26, 120.92725000, 28.73986000, 1100.00);
INSERT INTO `route_points` VALUES (2502, 16, 27, 120.92563000, 28.74092000, 1060.00);
INSERT INTO `route_points` VALUES (2503, 16, 28, 120.92391000, 28.74167000, 1020.00);
INSERT INTO `route_points` VALUES (2504, 16, 29, 120.92218000, 28.74253000, 980.00);
INSERT INTO `route_points` VALUES (2505, 16, 30, 120.92045000, 28.74389000, 940.00);
INSERT INTO `route_points` VALUES (2506, 16, 31, 120.91932000, 28.74561000, 900.00);
INSERT INTO `route_points` VALUES (2507, 16, 32, 120.91876000, 28.74743000, 860.00);
INSERT INTO `route_points` VALUES (2508, 16, 33, 120.91944000, 28.74925000, 820.00);
INSERT INTO `route_points` VALUES (2509, 16, 34, 120.92107000, 28.75038000, 780.00);
INSERT INTO `route_points` VALUES (2510, 16, 35, 120.92295000, 28.75122000, 740.00);
INSERT INTO `route_points` VALUES (2511, 16, 36, 120.92478000, 28.75206000, 700.00);
INSERT INTO `route_points` VALUES (2512, 16, 37, 120.92621000, 28.75349000, 660.00);
INSERT INTO `route_points` VALUES (2513, 16, 38, 120.92688000, 28.75532000, 620.00);
INSERT INTO `route_points` VALUES (2514, 16, 39, 120.92614000, 28.75705000, 580.00);
INSERT INTO `route_points` VALUES (2515, 16, 40, 120.92467000, 28.75823000, 540.00);
INSERT INTO `route_points` VALUES (2516, 17, 1, 118.16923000, 30.13987000, 1630.00);
INSERT INTO `route_points` VALUES (2517, 17, 2, 118.16945000, 30.14012000, 1625.00);
INSERT INTO `route_points` VALUES (2518, 17, 3, 118.16968000, 30.14035000, 1620.00);
INSERT INTO `route_points` VALUES (2519, 17, 4, 118.16992000, 30.14058000, 1615.00);
INSERT INTO `route_points` VALUES (2520, 17, 5, 118.17015000, 30.14082000, 1610.00);
INSERT INTO `route_points` VALUES (2521, 17, 6, 118.17002000, 30.14105000, 1605.00);
INSERT INTO `route_points` VALUES (2522, 17, 7, 118.16978000, 30.14128000, 1600.00);
INSERT INTO `route_points` VALUES (2523, 17, 8, 118.16955000, 30.14152000, 1595.00);
INSERT INTO `route_points` VALUES (2524, 17, 9, 118.16932000, 30.14175000, 1590.00);
INSERT INTO `route_points` VALUES (2525, 17, 10, 118.16910000, 30.14200000, 1585.00);
INSERT INTO `route_points` VALUES (2526, 17, 11, 118.16885000, 30.14223000, 1580.00);
INSERT INTO `route_points` VALUES (2527, 17, 12, 118.16862000, 30.14248000, 1575.00);
INSERT INTO `route_points` VALUES (2528, 17, 13, 118.16840000, 30.14272000, 1570.00);
INSERT INTO `route_points` VALUES (2529, 17, 14, 118.16818000, 30.14295000, 1565.00);
INSERT INTO `route_points` VALUES (2530, 17, 15, 118.16795000, 30.14320000, 1560.00);
INSERT INTO `route_points` VALUES (2531, 17, 16, 118.16773000, 30.14345000, 1555.00);
INSERT INTO `route_points` VALUES (2532, 17, 17, 118.16750000, 30.14370000, 1550.00);
INSERT INTO `route_points` VALUES (2533, 17, 18, 118.16728000, 30.14395000, 1545.00);
INSERT INTO `route_points` VALUES (2534, 17, 19, 118.16705000, 30.14420000, 1540.00);
INSERT INTO `route_points` VALUES (2535, 17, 20, 118.16683000, 30.14445000, 1535.00);
INSERT INTO `route_points` VALUES (2536, 17, 21, 118.16660000, 30.14470000, 1530.00);
INSERT INTO `route_points` VALUES (2537, 17, 22, 118.16638000, 30.14495000, 1525.00);
INSERT INTO `route_points` VALUES (2538, 17, 23, 118.16615000, 30.14520000, 1520.00);
INSERT INTO `route_points` VALUES (2539, 17, 24, 118.16593000, 30.14545000, 1515.00);
INSERT INTO `route_points` VALUES (2540, 17, 25, 118.16570000, 30.14570000, 1510.00);
INSERT INTO `route_points` VALUES (2541, 17, 26, 118.16548000, 30.14595000, 1505.00);
INSERT INTO `route_points` VALUES (2542, 17, 27, 118.16525000, 30.14620000, 1500.00);
INSERT INTO `route_points` VALUES (2543, 17, 28, 118.16503000, 30.14645000, 1495.00);
INSERT INTO `route_points` VALUES (2544, 17, 29, 118.16480000, 30.14670000, 1490.00);
INSERT INTO `route_points` VALUES (2545, 17, 30, 118.16458000, 30.14695000, 1485.00);
INSERT INTO `route_points` VALUES (2546, 17, 31, 118.16435000, 30.14720000, 1480.00);
INSERT INTO `route_points` VALUES (2547, 17, 32, 118.16413000, 30.14745000, 1475.00);
INSERT INTO `route_points` VALUES (2548, 17, 33, 118.16390000, 30.14770000, 1470.00);
INSERT INTO `route_points` VALUES (2549, 17, 34, 118.16368000, 30.14795000, 1465.00);
INSERT INTO `route_points` VALUES (2550, 17, 35, 118.16345000, 30.14820000, 1460.00);
INSERT INTO `route_points` VALUES (2551, 17, 36, 118.16323000, 30.14845000, 1455.00);
INSERT INTO `route_points` VALUES (2552, 17, 37, 118.16300000, 30.14870000, 1450.00);
INSERT INTO `route_points` VALUES (2553, 17, 38, 118.16278000, 30.14895000, 1445.00);
INSERT INTO `route_points` VALUES (2554, 17, 39, 118.16255000, 30.14920000, 1440.00);
INSERT INTO `route_points` VALUES (2555, 17, 40, 118.16233000, 30.14945000, 1435.00);
INSERT INTO `route_points` VALUES (2556, 18, 1, 121.09583000, 29.25861000, 479.00);
INSERT INTO `route_points` VALUES (2557, 18, 2, 121.09612000, 29.25903000, 531.00);
INSERT INTO `route_points` VALUES (2558, 18, 3, 121.09658000, 29.25947000, 553.00);
INSERT INTO `route_points` VALUES (2559, 18, 4, 121.09692000, 29.25988000, 570.00);
INSERT INTO `route_points` VALUES (2560, 18, 5, 121.09725000, 29.26031000, 567.00);
INSERT INTO `route_points` VALUES (2561, 18, 6, 121.09763000, 29.26065000, 584.00);
INSERT INTO `route_points` VALUES (2562, 18, 7, 121.09801000, 29.26092000, 584.00);
INSERT INTO `route_points` VALUES (2563, 18, 8, 121.09840000, 29.26118000, 594.00);
INSERT INTO `route_points` VALUES (2564, 18, 9, 121.09875000, 29.26142000, 584.00);
INSERT INTO `route_points` VALUES (2565, 18, 10, 121.09910000, 29.26165000, 604.00);
INSERT INTO `route_points` VALUES (2566, 18, 11, 121.09945000, 29.26188000, 642.00);
INSERT INTO `route_points` VALUES (2567, 18, 12, 121.09980000, 29.26210000, 633.00);
INSERT INTO `route_points` VALUES (2568, 18, 13, 121.10015000, 29.26233000, 615.00);
INSERT INTO `route_points` VALUES (2569, 18, 14, 121.10050000, 29.26255000, 601.00);
INSERT INTO `route_points` VALUES (2570, 18, 15, 121.10085000, 29.26278000, 581.00);
INSERT INTO `route_points` VALUES (2571, 18, 16, 121.10120000, 29.26300000, 566.00);
INSERT INTO `route_points` VALUES (2572, 18, 17, 121.10155000, 29.26323000, 589.00);
INSERT INTO `route_points` VALUES (2573, 18, 18, 121.10190000, 29.26345000, 616.00);
INSERT INTO `route_points` VALUES (2574, 18, 19, 121.10225000, 29.26368000, 669.00);
INSERT INTO `route_points` VALUES (2575, 18, 20, 121.10260000, 29.26390000, 738.00);
INSERT INTO `route_points` VALUES (2576, 18, 21, 121.10295000, 29.26413000, 814.00);
INSERT INTO `route_points` VALUES (2577, 18, 22, 121.10330000, 29.26435000, 897.00);
INSERT INTO `route_points` VALUES (2578, 18, 23, 121.10365000, 29.26458000, 971.00);
INSERT INTO `route_points` VALUES (2579, 18, 24, 121.10400000, 29.26480000, 1021.00);
INSERT INTO `route_points` VALUES (2580, 18, 25, 121.10435000, 29.26503000, 1043.00);
INSERT INTO `route_points` VALUES (2581, 18, 26, 121.10470000, 29.26525000, 1026.00);
INSERT INTO `route_points` VALUES (2582, 18, 27, 121.10505000, 29.26548000, 995.00);
INSERT INTO `route_points` VALUES (2583, 18, 28, 121.10540000, 29.26570000, 967.00);
INSERT INTO `route_points` VALUES (2584, 18, 29, 121.10575000, 29.26593000, 951.00);
INSERT INTO `route_points` VALUES (2585, 18, 30, 121.10610000, 29.26615000, 934.00);
INSERT INTO `route_points` VALUES (2586, 18, 31, 121.10645000, 29.26638000, 948.00);
INSERT INTO `route_points` VALUES (2587, 18, 32, 121.10680000, 29.26660000, 949.00);
INSERT INTO `route_points` VALUES (2588, 18, 33, 121.10715000, 29.26683000, 982.00);
INSERT INTO `route_points` VALUES (2589, 18, 34, 121.10750000, 29.26705000, 995.00);
INSERT INTO `route_points` VALUES (2590, 18, 35, 121.10785000, 29.26728000, 1015.00);
INSERT INTO `route_points` VALUES (2591, 18, 36, 121.10820000, 29.26750000, 1033.00);
INSERT INTO `route_points` VALUES (2592, 18, 37, 121.10855000, 29.26773000, 1049.00);
INSERT INTO `route_points` VALUES (2593, 18, 38, 121.10890000, 29.26795000, 1070.00);
INSERT INTO `route_points` VALUES (2594, 18, 39, 121.10925000, 29.26818000, 1085.00);
INSERT INTO `route_points` VALUES (2595, 18, 40, 121.10960000, 29.26840000, 1125.00);
INSERT INTO `route_points` VALUES (2596, 19, 1, 118.00123000, 27.65845000, 210.00);
INSERT INTO `route_points` VALUES (2597, 19, 2, 118.00215000, 27.65912000, 225.00);
INSERT INTO `route_points` VALUES (2598, 19, 3, 118.00328000, 27.65980000, 245.00);
INSERT INTO `route_points` VALUES (2599, 19, 4, 118.00410000, 27.66033000, 270.00);
INSERT INTO `route_points` VALUES (2600, 19, 5, 118.00405000, 27.66120000, 310.00);
INSERT INTO `route_points` VALUES (2601, 19, 6, 118.00392000, 27.66215000, 350.00);
INSERT INTO `route_points` VALUES (2602, 19, 7, 118.00350000, 27.66280000, 380.00);
INSERT INTO `route_points` VALUES (2603, 19, 8, 118.00288000, 27.66310000, 410.00);
INSERT INTO `route_points` VALUES (2604, 19, 9, 118.00220000, 27.66305000, 430.00);
INSERT INTO `route_points` VALUES (2605, 19, 10, 118.00155000, 27.66340000, 450.00);
INSERT INTO `route_points` VALUES (2606, 19, 11, 118.00100000, 27.66420000, 480.00);
INSERT INTO `route_points` VALUES (2607, 19, 12, 118.00085000, 27.66500000, 460.00);
INSERT INTO `route_points` VALUES (2608, 19, 13, 118.00070000, 27.66585000, 430.00);
INSERT INTO `route_points` VALUES (2609, 19, 14, 118.00030000, 27.66650000, 400.00);
INSERT INTO `route_points` VALUES (2610, 19, 15, 117.99975000, 27.66680000, 380.00);
INSERT INTO `route_points` VALUES (2611, 19, 16, 117.99920000, 27.66700000, 360.00);
INSERT INTO `route_points` VALUES (2612, 19, 17, 117.99865000, 27.66750000, 340.00);
INSERT INTO `route_points` VALUES (2613, 19, 18, 117.99810000, 27.66820000, 320.00);
INSERT INTO `route_points` VALUES (2614, 19, 19, 117.99780000, 27.66900000, 300.00);
INSERT INTO `route_points` VALUES (2615, 19, 20, 117.99760000, 27.66985000, 280.00);
INSERT INTO `route_points` VALUES (2616, 19, 21, 117.99790000, 27.67060000, 260.00);
INSERT INTO `route_points` VALUES (2617, 19, 22, 117.99840000, 27.67120000, 240.00);
INSERT INTO `route_points` VALUES (2618, 19, 23, 117.99900000, 27.67150000, 230.00);
INSERT INTO `route_points` VALUES (2619, 19, 24, 117.99970000, 27.67180000, 220.00);
INSERT INTO `route_points` VALUES (2620, 19, 25, 118.00040000, 27.67210000, 210.00);
INSERT INTO `route_points` VALUES (2621, 19, 26, 118.00110000, 27.67240000, 200.00);
INSERT INTO `route_points` VALUES (2622, 19, 27, 118.00180000, 27.67270000, 190.00);
INSERT INTO `route_points` VALUES (2623, 19, 28, 118.00250000, 27.67300000, 185.00);
INSERT INTO `route_points` VALUES (2624, 19, 29, 118.00320000, 27.67330000, 180.00);
INSERT INTO `route_points` VALUES (2625, 19, 30, 118.00390000, 27.67360000, 190.00);
INSERT INTO `route_points` VALUES (2626, 19, 31, 118.00460000, 27.67390000, 210.00);
INSERT INTO `route_points` VALUES (2627, 19, 32, 118.00530000, 27.67420000, 240.00);
INSERT INTO `route_points` VALUES (2628, 19, 33, 118.00580000, 27.67480000, 270.00);
INSERT INTO `route_points` VALUES (2629, 19, 34, 118.00620000, 27.67550000, 300.00);
INSERT INTO `route_points` VALUES (2630, 19, 35, 118.00650000, 27.67620000, 280.00);
INSERT INTO `route_points` VALUES (2631, 19, 36, 118.00670000, 27.67690000, 250.00);
INSERT INTO `route_points` VALUES (2632, 19, 37, 118.00680000, 27.67760000, 230.00);
INSERT INTO `route_points` VALUES (2633, 19, 38, 118.00660000, 27.67830000, 210.00);
INSERT INTO `route_points` VALUES (2634, 19, 39, 118.00620000, 27.67890000, 200.00);
INSERT INTO `route_points` VALUES (2635, 19, 40, 118.00580000, 27.67950000, 195.00);
INSERT INTO `route_points` VALUES (2636, 20, 1, 113.74612000, 25.02134000, 128.00);
INSERT INTO `route_points` VALUES (2637, 20, 2, 113.74645000, 25.02167000, 135.00);
INSERT INTO `route_points` VALUES (2638, 20, 3, 113.74688000, 25.02192000, 142.00);
INSERT INTO `route_points` VALUES (2639, 20, 4, 113.74732000, 25.02218000, 156.00);
INSERT INTO `route_points` VALUES (2640, 20, 5, 113.74760000, 25.02253000, 168.00);
INSERT INTO `route_points` VALUES (2641, 20, 6, 113.74755000, 25.02298000, 185.00);
INSERT INTO `route_points` VALUES (2642, 20, 7, 113.74720000, 25.02325000, 198.00);
INSERT INTO `route_points` VALUES (2643, 20, 8, 113.74675000, 25.02340000, 210.00);
INSERT INTO `route_points` VALUES (2644, 20, 9, 113.74630000, 25.02362000, 225.00);
INSERT INTO `route_points` VALUES (2645, 20, 10, 113.74605000, 25.02410000, 238.00);
INSERT INTO `route_points` VALUES (2646, 20, 11, 113.74592000, 25.02458000, 252.00);
INSERT INTO `route_points` VALUES (2647, 20, 12, 113.74570000, 25.02503000, 265.00);
INSERT INTO `route_points` VALUES (2648, 20, 13, 113.74535000, 25.02542000, 280.00);
INSERT INTO `route_points` VALUES (2649, 20, 14, 113.74490000, 25.02560000, 295.00);
INSERT INTO `route_points` VALUES (2650, 20, 15, 113.74445000, 25.02575000, 310.00);
INSERT INTO `route_points` VALUES (2651, 20, 16, 113.74400000, 25.02595000, 298.00);
INSERT INTO `route_points` VALUES (2652, 20, 17, 113.74365000, 25.02630000, 285.00);
INSERT INTO `route_points` VALUES (2653, 20, 18, 113.74350000, 25.02678000, 272.00);
INSERT INTO `route_points` VALUES (2654, 20, 19, 113.74362000, 25.02725000, 260.00);
INSERT INTO `route_points` VALUES (2655, 20, 20, 113.74395000, 25.02760000, 248.00);
INSERT INTO `route_points` VALUES (2656, 20, 21, 113.74440000, 25.02785000, 235.00);
INSERT INTO `route_points` VALUES (2657, 20, 22, 113.74485000, 25.02810000, 250.00);
INSERT INTO `route_points` VALUES (2658, 20, 23, 113.74530000, 25.02835000, 268.00);
INSERT INTO `route_points` VALUES (2659, 20, 24, 113.74575000, 25.02860000, 285.00);
INSERT INTO `route_points` VALUES (2660, 20, 25, 113.74620000, 25.02885000, 302.00);
INSERT INTO `route_points` VALUES (2661, 20, 26, 113.74665000, 25.02910000, 318.00);
INSERT INTO `route_points` VALUES (2662, 20, 27, 113.74710000, 25.02935000, 335.00);
INSERT INTO `route_points` VALUES (2663, 20, 28, 113.74755000, 25.02960000, 320.00);
INSERT INTO `route_points` VALUES (2664, 20, 29, 113.74790000, 25.02995000, 305.00);
INSERT INTO `route_points` VALUES (2665, 20, 30, 113.74805000, 25.03043000, 290.00);
INSERT INTO `route_points` VALUES (2666, 20, 31, 113.74790000, 25.03090000, 275.00);
INSERT INTO `route_points` VALUES (2667, 20, 32, 113.74755000, 25.03125000, 260.00);
INSERT INTO `route_points` VALUES (2668, 20, 33, 113.74710000, 25.03150000, 245.00);
INSERT INTO `route_points` VALUES (2669, 20, 34, 113.74665000, 25.03175000, 230.00);
INSERT INTO `route_points` VALUES (2670, 20, 35, 113.74620000, 25.03200000, 248.00);
INSERT INTO `route_points` VALUES (2671, 20, 36, 113.74585000, 25.03235000, 265.00);
INSERT INTO `route_points` VALUES (2672, 20, 37, 113.74570000, 25.03283000, 282.00);
INSERT INTO `route_points` VALUES (2673, 20, 38, 113.74585000, 25.03330000, 298.00);
INSERT INTO `route_points` VALUES (2674, 20, 39, 113.74620000, 25.03365000, 315.00);
INSERT INTO `route_points` VALUES (2675, 20, 40, 113.74665000, 25.03390000, 330.00);

-- ----------------------------
-- Table structure for routes
-- ----------------------------
DROP TABLE IF EXISTS `routes`;
CREATE TABLE `routes`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '线路ID（主键）',
  `creator_id` int UNSIGNED NOT NULL COMMENT '创建者用户ID',
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '线路标题',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '线路描述',
  `difficulty` tinyint NULL DEFAULT 2 COMMENT '难度等级（1简单/2中等/3困难/4专家/5极限）',
  `distance_km` decimal(8, 2) NULL DEFAULT 0.00 COMMENT '总距离(km)',
  `elevation_m` int NULL DEFAULT 0 COMMENT '累计爬升海拔(m)',
  `duration_h` decimal(5, 1) NULL DEFAULT 0.0 COMMENT '预计时长(小时)',
  `start_lng` decimal(11, 8) NOT NULL COMMENT '起点经度',
  `start_lat` decimal(10, 8) NOT NULL COMMENT '起点纬度',
  `cover_image` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '封面图片URL',
  `gpx_path` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'GPX文件路径',
  `region` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '所属地区',
  `tags` json NULL COMMENT '标签(JSON数组)',
  `view_count` int UNSIGNED NULL DEFAULT 0 COMMENT '浏览次数',
  `like_count` int UNSIGNED NULL DEFAULT 0 COMMENT '收藏次数',
  `is_public` tinyint(1) NULL DEFAULT 1 COMMENT '是否公开（0私密/1公开）',
  `status` tinyint NULL DEFAULT 1 COMMENT '状态（0已删除/1正常）',
  `created_at` datetime NULL DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  `safety_note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '安全提示信息',
  `gear_list` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '建议装备清单',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_difficulty`(`difficulty` ASC) USING BTREE,
  INDEX `idx_region`(`region` ASC) USING BTREE,
  INDEX `idx_creator`(`creator_id` ASC) USING BTREE,
  CONSTRAINT `routes_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 21 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '徒步线路表 - 存储用户创建的线路信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of routes
-- ----------------------------
INSERT INTO `routes` VALUES (1, 2, '四姑娘山大峰登顶线路', '四姑娘山大峰（5025m）是大众登山者的经典目标。从日隆镇出发，经猫鼻梁、垭口营地，全程技术难度较高，需具备基本高山经验。秋季观赏红叶和雪山同框绝景，建议在镇上适应1-2天再出发。', 4, 28.50, 2800, 12.0, 102.54420000, 31.03880000, NULL, NULL, '四川·阿坝', '[\"高山\", \"登山\", \"雪山\", \"经典线\"]', 9018, 2, 1, 1, '2026-03-15 18:36:02', '2026-03-17 19:21:49', NULL, NULL);
INSERT INTO `routes` VALUES (2, 2, '四姑娘山幺妹峰环线', '幺妹峰（6250m）是四姑娘山最高峰，本线路为环线观景路线，不登顶，从长坪沟进、海子沟出，穿越海拔4600m垭口，可近距离仰望幺妹峰震撼冰川。全程需扎营两晚。', 4, 42.00, 3100, 32.0, 102.53200000, 31.05200000, NULL, NULL, '四川·阿坝', '[\"高山\", \"扎营\", \"雪山\", \"环线\"]', 6229, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 03:12:18', NULL, NULL);
INSERT INTO `routes` VALUES (3, 1, '贡嘎山东坡转山（子梅垭口）', '子梅垭口（4500m）是观赏贡嘎主峰最近的垭口，晴天可见贡嘎7556m冰雪主峰全貌，气势磅礴。从子梅村往返，全程约22km，爬升1500m。高反风险中等，需提前适应。', 3, 22.00, 1500, 10.0, 102.02380000, 29.57880000, NULL, NULL, '四川·甘孜', '[\"高山\", \"观景\", \"贡嘎\", \"垭口\"]', 11224, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 19:37:53', NULL, NULL);
INSERT INTO `routes` VALUES (4, 4, '稻城亚丁洛绒牛场-牛奶海-五色海', '亚丁景区核心线路，从洛绒牛场出发徒步至牛奶海（4600m）、五色海（4700m），单程约10km，可选择牛场扎营，次日凌晨出发拍日出。高反风险较高，建议香格里拉或稻城适应2天。', 3, 20.00, 1200, 8.0, 99.92720000, 28.43580000, NULL, NULL, '四川·甘孜', '[\"高山\", \"湖泊\", \"扎营\", \"摄影\"]', 15833, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 00:15:26', NULL, NULL);
INSERT INTO `routes` VALUES (5, 1, '螺髻山古冰川地貌徒步', '螺髻山拥有中国保存最完整的第四纪古冰川遗迹，黑龙潭、杜鹃池等高原冰湖散落其间。从彝家第一村出发，穿越杜鹃林，春季杜鹃盛开时绝美。全程技术难度低，适合新手挑战。', 2, 18.00, 900, 7.0, 102.42170000, 27.51330000, NULL, NULL, '四川·凉山', '[\"古冰川\", \"湖泊\", \"杜鹃\", \"新手友好\"]', 5445, 0, 1, 1, '2026-03-15 18:36:02', '2026-03-16 15:07:16', NULL, NULL);
INSERT INTO `routes` VALUES (6, 3, '云南高黎贡山南斋公房穿越', '高黎贡山是生物多样性热点区，南斋公房段保存有原始常绿阔叶林。从腾冲出发翻越垭口至怒江峡谷，途经高山草甸、古茶树群。雨季需注意山蛭，建议4-5月或10-11月前往。', 3, 35.00, 2200, 20.0, 98.50800000, 25.10200000, NULL, NULL, '云南·保山', '[\"穿越\", \"丛林\", \"生物多样性\", \"古茶树\"]', 3902, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 19:43:48', NULL, NULL);
INSERT INTO `routes` VALUES (7, 3, '梅里雪山雨崩村徒步（内转经线）', '雨崩村是梅里雪山脚下的秘境村落，仅能徒步进入。从飞来寺徒步至雨崩，再走内转经线（神瀑-冰湖），可近距离感受卡瓦格博神山。全程需2-3天，建议住雨崩村客栈。', 3, 48.00, 2600, 28.0, 98.60600000, 28.42800000, NULL, NULL, '云南·迪庆', '[\"雪山\", \"村落\", \"转山\", \"扎营\"]', 18645, 2, 1, 1, '2026-03-15 18:36:02', '2026-03-16 19:43:44', NULL, NULL);
INSERT INTO `routes` VALUES (8, 5, '云南元阳哈尼梯田观景徒步', '元阳梯田是世界文化遗产，本线路穿越多依树、坝达、老虎嘴三大观景区，步行于梯田田埂间，感受哈尼族农耕文化。日出时分云雾缭绕梯田，极具摄影价值。全程难度低。', 1, 12.00, 400, 5.0, 102.77400000, 23.12900000, NULL, NULL, '云南·红河', '[\"梯田\", \"文化\", \"摄影\", \"新手友好\"]', 9223, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-17 19:17:06', NULL, NULL);
INSERT INTO `routes` VALUES (9, 4, '新疆狼塔C线（全程穿越）', '狼塔C线是新疆徒步皇冠线路，全程约100km，翻越4-5个4000m+垭口。途经独库公路原始天山风貌，需扎营5-7晚，补给困难，需完整的野外生存经验，是国内顶级的荒野穿越线路之一。', 5, 100.00, 8500, 72.0, 83.56200000, 42.88300000, NULL, NULL, '新疆·伊犁', '[\"极限\", \"穿越\", \"天山\", \"荒野\"]', 7833, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 15:18:37', NULL, NULL);
INSERT INTO `routes` VALUES (10, 4, '新疆喀拉峻大草原环线', '喀拉峻被誉为\"上帝的后花园\"，哈萨克牧民的夏牧场。本环线穿越起伏的高原草甸，偶遇转场的牧民马队，可住毡房体验牧民生活。最佳季节6-8月，草原繁花盛开。', 2, 35.00, 1200, 14.0, 82.85600000, 42.99200000, NULL, NULL, '新疆·伊犁', '[\"草原\", \"文化体验\", \"马队\", \"摄影\"]', 6549, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-16 15:07:08', NULL, NULL);
INSERT INTO `routes` VALUES (11, 4, '天山托木尔峰南坡穿越（托木尔大本营）', '托木尔峰（7443m）是天山最高峰，南坡大本营线路穿越原始冰川地貌，经哈木斯特冰川末端、冰湖，极具震撼感。技术难度高，需冰爪、冰镐装备，建议有高山经验队员参与。', 5, 60.00, 5200, 48.0, 80.12300000, 41.77800000, NULL, NULL, '新疆·阿克苏', '[\"极限\", \"冰川\", \"高山\", \"攀登\"]', 4121, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-15 22:40:05', NULL, NULL);
INSERT INTO `routes` VALUES (12, 2, '西藏珠峰大本营徒步（加乌拉山口）', '从定日县出发，经加乌拉山口（5198m）俯瞰珠峰北坡全貌，再下至珠峰大本营（5200m）扎营，次日清晨日照金山为摄影绝佳时机。全程需高原适应，建议拉萨适应5天以上。', 4, 55.00, 3800, 36.0, 86.55600000, 28.13200000, NULL, NULL, '西藏·日喀则', '[\"珠峰\", \"高海拔\", \"摄影\", \"扎营\"]', 22409, 3, 1, 1, '2026-03-15 18:36:02', '2026-03-15 22:40:15', NULL, NULL);
INSERT INTO `routes` VALUES (13, 1, '西藏冈仁波齐转山（外转经线）', '冈仁波齐（6638m）是世界公认的神山，外转经线约52km，需翻越5630m的卓玛拉山口。藏传佛教、苯教、印度教、耆那教共同的朝圣之地，转山者络绎不绝，文化氛围浓厚。', 4, 52.00, 2400, 24.0, 81.31200000, 30.52600000, NULL, NULL, '西藏·阿里', '[\"神山\", \"朝圣\", \"高海拔\", \"文化\"]', 16800, 0, 1, 1, '2026-03-15 18:36:02', '2026-03-15 18:36:02', NULL, NULL);
INSERT INTO `routes` VALUES (14, 4, '青海年保玉则环线', '年保玉则（4979m）被誉为\"东方的阿尔卑斯\"，仙女湖、妖女湖镶嵌于高原草甸间，湖水碧蓝。环线全程约60km，扎营3晚，高原野花5-7月盛开，是国内最美湿地徒步线路之一。', 3, 60.00, 2800, 32.0, 100.96500000, 33.61800000, NULL, NULL, '青海·果洛', '[\"高原\", \"湖泊\", \"野花\", \"扎营\"]', 12300, 0, 1, 1, '2026-03-15 18:36:02', '2026-03-15 18:36:02', NULL, NULL);
INSERT INTO `routes` VALUES (15, 1, '甘肃扎尕那-则岔石林穿越', '扎尕那是藏族碉楼村寨与石灰岩峰林的梦幻组合，本穿越线翻越垭口进入则岔石林，地貌奇特。可住扎尕那农家乐，体验安多藏区民俗。全程难度适中，推荐徒步新手。', 2, 28.00, 1600, 12.0, 103.13800000, 34.23500000, NULL, NULL, '甘肃·甘南', '[\"石林\", \"藏族文化\", \"穿越\", \"新手友好\"]', 7654, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-15 23:31:24', NULL, NULL);
INSERT INTO `routes` VALUES (16, 5, '浙江括苍山穿越（华东屋脊）', '括苍山主峰米筛浪（1382m）为浙江最高峰，穿越线路沿山脊行走，可俯瞰台州与丽水两地云海。秋季红叶与云雾组合，是华东摄影徒步热门线路，交通便利，适合周末出行。', 2, 22.00, 1100, 8.0, 120.80200000, 28.51400000, NULL, NULL, '浙江·台州', '[\"山脊\", \"云海\", \"摄影\", \"周末\"]', 8873, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-15 21:47:46', NULL, NULL);
INSERT INTO `routes` VALUES (17, 5, '安徽黄山北海-西海大峡谷-天海环线', '黄山经典大环线，穿越北海、西海大峡谷、天海三大景区，全程在景区内徒步，无需独立扎营。峡谷内悬崖栈道惊险刺激，天海荷花池平静如镜。建议避开节假日，工作日人少景美。', 2, 18.00, 1200, 9.0, 118.15600000, 30.13800000, NULL, NULL, '安徽·黄山', '[\"经典\", \"峡谷\", \"云海\", \"世界遗产\"]', 25600, 2, 1, 1, '2026-03-15 18:36:02', '2026-03-15 18:36:02', NULL, NULL);
INSERT INTO `routes` VALUES (18, 5, '浙江天台山石梁飞瀑-华顶森林徒步', '石梁飞瀑是天台山镇山之宝，本线路从石梁出发，穿越华顶国家森林公园，经云锦杜鹃保护区至天台山主峰。春季云锦杜鹃（国内最大的野生杜鹃群）盛开，花海壮观。', 1, 15.00, 700, 6.0, 121.02200000, 29.16500000, NULL, NULL, '浙江·台州', '[\"瀑布\", \"杜鹃\", \"森林\", \"新手友好\"]', 6321, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-15 22:40:08', NULL, NULL);
INSERT INTO `routes` VALUES (19, 3, '福建武夷山天游峰-大王峰-玉女峰环线', '武夷山世界双遗产地，本线路串联天游峰、大王峰、玉女峰三大核心景区，穿行于丹霞赤壁与碧绿溪水间，乘竹筏漂流九曲溪为绝佳体验。全程轻松，适合家庭徒步。', 1, 12.00, 500, 5.0, 117.97800000, 27.72400000, NULL, NULL, '福建·南平', '[\"丹霞\", \"溪流\", \"世界遗产\", \"家庭\"]', 19800, 1, 1, 1, '2026-03-15 18:36:02', '2026-03-15 18:36:02', NULL, NULL);
INSERT INTO `routes` VALUES (20, 3, '广东丹霞山阳元石-锦江画廊穿越', '丹霞山是中国丹霞地貌命名地，阳元石（象形岩）、锦江画廊为核心景观。穿越线路沿赤壁悬崖栈道行走，俯视碧绿锦江，险峻与秀美并存。适合亲子及初级徒步者。', 1, 14.00, 600, 5.5, 113.73800000, 25.02200000, NULL, NULL, '广东·韶关', '[\"丹霞\", \"画廊\", \"亲子\", \"新手友好\"]', 11401, 0, 1, 1, '2026-03-15 18:36:02', '2026-03-15 22:32:48', NULL, NULL);

-- ----------------------------
-- Table structure for skill_tags
-- ----------------------------
DROP TABLE IF EXISTS `skill_tags`;
CREATE TABLE `skill_tags`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '标签ID（主键）',
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '标签名称',
  `icon` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '技能标签表 - 可选的徒步技能标签字典' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of skill_tags
-- ----------------------------
INSERT INTO `skill_tags` VALUES (1, '高山穿越', 'mountain');
INSERT INTO `skill_tags` VALUES (2, '溯溪', 'water');
INSERT INTO `skill_tags` VALUES (3, '攀岩', 'climbing');
INSERT INTO `skill_tags` VALUES (4, '野营', 'tent');
INSERT INTO `skill_tags` VALUES (5, '定向越野', 'compass');
INSERT INTO `skill_tags` VALUES (6, '雪地行走', 'snow');
INSERT INTO `skill_tags` VALUES (7, '丛林穿越', 'forest');
INSERT INTO `skill_tags` VALUES (8, '长距徒步', 'boot');
INSERT INTO `skill_tags` VALUES (9, '摄影', 'camera');
INSERT INTO `skill_tags` VALUES (10, '急救', 'firstaid');

-- ----------------------------
-- Table structure for user_follows
-- ----------------------------
DROP TABLE IF EXISTS `user_follows`;
CREATE TABLE `user_follows`  (
  `follower_id` int UNSIGNED NOT NULL COMMENT '关注者用户ID',
  `following_id` int UNSIGNED NOT NULL COMMENT '被关注者用户ID',
  `created_at` datetime NULL DEFAULT NULL COMMENT '关注时间',
  PRIMARY KEY (`follower_id`, `following_id`) USING BTREE,
  INDEX `following_id`(`following_id` ASC) USING BTREE,
  CONSTRAINT `user_follows_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_follows_ibfk_2` FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户关注关系表 - 记录用户间的关注/粉丝关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_follows
-- ----------------------------
INSERT INTO `user_follows` VALUES (1, 2, '2026-03-16 19:20:17');
INSERT INTO `user_follows` VALUES (1, 3, '2026-03-16 19:25:34');

-- ----------------------------
-- Table structure for user_skills
-- ----------------------------
DROP TABLE IF EXISTS `user_skills`;
CREATE TABLE `user_skills`  (
  `user_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `tag_id` int UNSIGNED NOT NULL COMMENT '技能标签ID',
  PRIMARY KEY (`user_id`, `tag_id`) USING BTREE,
  INDEX `tag_id`(`tag_id` ASC) USING BTREE,
  CONSTRAINT `user_skills_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `user_skills_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `skill_tags` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户技能关联表 - 用户与技能标签的多对多关系' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user_skills
-- ----------------------------
INSERT INTO `user_skills` VALUES (1, 1);
INSERT INTO `user_skills` VALUES (2, 1);
INSERT INTO `user_skills` VALUES (4, 1);
INSERT INTO `user_skills` VALUES (3, 2);
INSERT INTO `user_skills` VALUES (4, 3);
INSERT INTO `user_skills` VALUES (5, 4);
INSERT INTO `user_skills` VALUES (1, 5);
INSERT INTO `user_skills` VALUES (2, 6);
INSERT INTO `user_skills` VALUES (4, 6);
INSERT INTO `user_skills` VALUES (3, 7);
INSERT INTO `user_skills` VALUES (2, 8);
INSERT INTO `user_skills` VALUES (5, 9);

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID（主键）',
  `username` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户名（唯一）',
  `email` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '邮箱（唯一）',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码（bcrypt加密）',
  `avatar` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '头像URL',
  `nickname` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '昵称',
  `bio` varchar(300) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '个人简介',
  `level` tinyint NULL DEFAULT 1 COMMENT '用户等级（1-5）',
  `gender` tinyint NULL DEFAULT 0 COMMENT '性别（0未设置/1男/2女）',
  `role` tinyint NULL DEFAULT 0 COMMENT '角色（0普通用户/1管理员）',
  `total_km` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '累计徒步里程(km)',
  `total_checkin` int NULL DEFAULT 0 COMMENT '累计打卡次数',
  `created_at` datetime NULL DEFAULT NULL COMMENT '注册时间',
  `updated_at` datetime NULL DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE,
  UNIQUE INDEX `email`(`email` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表 - 存储注册用户基本信息' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, 'admin', 'admin@trekhub.com', '$2a$10$v9KLt4ZQytP3TRFwiXzHwO7.AvnV9gHX0.xcsfMG7NEbhNYY..3IS', '/uploads/images/1773648295150_044b4a0tq5qm.png', '管理员', '平台管理员，热爱户外运动', 1, 0, 1, 0.00, 1, '2026-03-15 18:26:51', '2026-03-16 16:04:55');
INSERT INTO `users` VALUES (2, 'test', 'test@trekhub.com', '$2a$10$v9KLt4ZQytP3TRFwiXzHwO7.AvnV9gHX0.xcsfMG7NEbhNYY..3IS', '/uploads/images/1773746534293_vazq5vrhcrd.png', '山野小李', '四川人，喜欢高山穿越，已完成四姑娘山、贡嘎等经典线路', 4, 1, 0, 36.00, 2, '2026-03-15 18:35:15', '2026-03-17 19:22:14');
INSERT INTO `users` VALUES (3, 'wanderer', 'wan@trekhub.com', '$2a$10$v9KLt4ZQytP3TRFwiXzHwO7.AvnV9gHX0.xcsfMG7NEbhNYY..3IS', '/uploads/images/1773606313408_nwglhlaezpk.png', '流浪的云', '云南人，热爱溯溪和丛林穿越', 3, 2, 0, 18.00, 2, '2026-03-15 18:35:15', '2026-03-16 04:27:32');
INSERT INTO `users` VALUES (4, 'peaks_fan', 'peaks@trekhub.com', '$2a$10$v9KLt4ZQytP3TRFwiXzHwO7.AvnV9gHX0.xcsfMG7NEbhNYY..3IS', NULL, '峰峰有味', '新疆人，独爱北疆荒野线路', 5, 1, 0, 15.00, 1, '2026-03-15 18:35:15', '2026-03-15 19:31:43');
INSERT INTO `users` VALUES (5, 'greenpath', 'green@trekhub.com', '$2a$10$v9KLt4ZQytP3TRFwiXzHwO7.AvnV9gHX0.xcsfMG7NEbhNYY..3IS', NULL, '绿野仙踪', '徒步摄影爱好者，走遍华东', 2, 2, 0, 18.00, 1, '2026-03-15 18:35:15', '2026-03-15 19:31:43');

SET FOREIGN_KEY_CHECKS = 1;
