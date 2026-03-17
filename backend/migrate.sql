ALTER TABLE routes ADD COLUMN safety_note TEXT NULL;
ALTER TABLE routes ADD COLUMN gear_list VARCHAR(500) NULL;

-- 活动互评表
CREATE TABLE IF NOT EXISTS activity_reviews (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  activity_id INT UNSIGNED NOT NULL,
  reviewer_id INT UNSIGNED NOT NULL,
  reviewee_id INT UNSIGNED NOT NULL,
  rating      TINYINT NOT NULL,
  content     VARCHAR(500),
  created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_review (activity_id, reviewer_id, reviewee_id),
  KEY idx_reviewee (reviewee_id),
  FOREIGN KEY (activity_id) REFERENCES activities(id),
  FOREIGN KEY (reviewer_id) REFERENCES users(id),
  FOREIGN KEY (reviewee_id) REFERENCES users(id)
);
