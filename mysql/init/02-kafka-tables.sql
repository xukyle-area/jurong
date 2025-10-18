-- 创建 Kafka 相关的数据表
-- 用于存储 Kafka 消息处理的状态信息

USE myapp;

-- Kafka 主题元数据表
CREATE TABLE kafka_topics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    topic_name VARCHAR(100) NOT NULL UNIQUE,
    partition_count INT DEFAULT 1,
    replication_factor INT DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Kafka 消息处理状态表
CREATE TABLE kafka_message_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    topic VARCHAR(100) NOT NULL,
    partition_id INT NOT NULL,
    offset_value BIGINT NOT NULL,
    message_key VARCHAR(255),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'processed', 'failed') DEFAULT 'pending',
    retry_count INT DEFAULT 0,
    error_message TEXT
);

-- 用户活动日志表（接收来自 Kafka 的事件）
CREATE TABLE user_activities (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    activity_type VARCHAR(50),
    activity_data JSON,
    source_topic VARCHAR(100),
    kafka_offset BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 插入示例 Kafka 主题
INSERT INTO kafka_topics (topic_name, partition_count) VALUES
('user-events', 3),
('order-events', 2),
('product-updates', 1);

-- 创建索引
CREATE INDEX idx_kafka_message_status_topic_partition ON kafka_message_status(topic, partition_id);
CREATE INDEX idx_kafka_message_status_offset ON kafka_message_status(offset_value);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_type ON user_activities(activity_type);

-- 显示新创建的表
SELECT 'Kafka相关表创建完成' as status;
SHOW TABLES LIKE '%kafka%';