#!/bin/bash

echo "🔧 为项目添加 MySQL 数据库"
echo "============================="

# 检查当前 docker-compose 状态
echo "1. 检查当前服务状态..."
docker-compose ps

echo ""
echo "2. 停止现有服务..."
docker-compose down

echo ""
echo "3. 备份当前 docker-compose.yaml..."
cp docker-compose.yaml docker-compose.yaml.backup

echo ""
echo "4. 添加 MySQL 配置到 docker-compose.yaml..."

# 这里只是演示，实际需要手动编辑文件
cat << 'EOF' >> docker-compose.yaml

  mysql:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: projects
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d
    networks:
      - kafka-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: rootpassword
    depends_on:
      - mysql
    networks:
      - kafka-network
EOF

# 更新 volumes 部分
echo "需要在 volumes 部分添加: mysql-data:"

echo ""
echo "5. 创建 MySQL 初始化目录..."
mkdir -p mysql/init

echo ""
echo "6. 创建示例初始化脚本..."
cat << 'EOF' > mysql/init/01-init.sql
-- 创建示例表
CREATE DATABASE IF NOT EXISTS projects;
USE projects;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 插入示例数据
INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com');
EOF

echo ""
echo "✅ MySQL 配置准备完成!"
echo ""
echo "📋 接下来的步骤:"
echo "1. 手动编辑 docker-compose.yaml 添加 MySQL 服务"
echo "2. 在 volumes 部分添加 mysql-data:"
echo "3. 运行: docker-compose up -d"
echo ""
echo "🌐 服务访问地址："
echo "- MySQL: localhost:3306"
echo "- phpMyAdmin: http://localhost:8081"
echo "- 用户名: root, 密码: rootpassword"