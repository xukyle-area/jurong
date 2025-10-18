-- MySQL 初始化脚本
-- 创建应用数据库和示例表

CREATE DATABASE IF NOT EXISTS myapp;
USE myapp;

-- 用户表
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 产品表
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2),
    stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 订单表
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10,2),
    status ENUM('pending', 'processing', 'completed', 'cancelled') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- 插入示例数据
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('john_doe', 'john@example.com'),
('jane_smith', 'jane@example.com');

INSERT INTO products (name, description, price, stock) VALUES
('笔记本电脑', '高性能办公笔记本', 5999.00, 50),
('无线鼠标', '蓝牙无线鼠标', 99.00, 200),
('机械键盘', 'RGB背光机械键盘', 299.00, 100);

INSERT INTO orders (user_id, total_amount, status) VALUES
(2, 6098.00, 'completed'),
(3, 398.00, 'processing');

-- 创建索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);

-- 显示创建的表
SHOW TABLES;