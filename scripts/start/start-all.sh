#!/bin/bash

echo "🚀 启动完整的 Kafka + MySQL 开发环境"
echecho "🌐 服务访问地址："
echo "=================================="
echo "📊 Kafka UI:      http://localhost:8080"
echo "🗄️  phpMyAdmin:    http://localhost:8081"
echo "� Redis Commander: http://localhost:8082"
echo "🌊 Flink Dashboard: http://localhost:8083"
echo "📊 Headlamp (K8s): http://localhost:30466"服务连接信息："
echo "=================================="
echo "Kafka:            localhost:9092"
echo "MySQL:            localhost:3306"
echo "  - 用户名:       root"
echo "  - 密码:         rootpassword"
echo "  - 应用数据库:   projects"
echo "  - 应用用户:     appuser"
echo "  - 应用密码:     apppassword"
echo "Redis:            localhost:6379"
echo "  - 密码:         redispassword"==============================="

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi

echo "📋 当前服务状态:"
docker-compose ps

echo ""
echo "🛑 停止现有服务..."
docker-compose down

echo ""
echo "🚀 启动所有服务..."
docker-compose up -d

echo ""
echo "⏳ 等待服务启动完成..."
sleep 10

echo ""
echo "🔍 检查服务状态..."
docker-compose ps

echo ""
echo "🏥 检查 MySQL 健康状态..."
timeout 30 bash -c 'until docker exec mysql mysqladmin ping -h localhost --silent; do sleep 1; done'

if [ $? -eq 0 ]; then
    echo "✅ MySQL 启动成功!"
else
    echo "⚠️  MySQL 启动可能需要更多时间，请稍后检查"
fi

echo ""
echo "🌐 服务访问地址："
echo "=================================="
echo "📊 Kafka UI:      http://localhost:8080"
echo "🗄️  phpMyAdmin:    http://localhost:8081"
echo "� Redis Commander: http://localhost:8082"
echo "�📊 Headlamp (K8s): http://localhost:30466"
echo ""
echo "🔌 服务连接信息："
echo "=================================="
echo "Kafka:            localhost:9092"
echo "MySQL:            localhost:3306"
echo "  - 用户名:       root"
echo "  - 密码:         rootpassword"
echo "  - 应用数据库:   projects"
echo "  - 应用用户:     appuser"
echo "  - 应用密码:     apppassword"
echo ""
echo "📚 查看日志："
echo "docker-compose logs -f [service_name]"
echo ""
echo "🛑 停止服务："
echo "docker-compose down"
echo ""
echo "🗑️  清理数据："
echo "docker-compose down -v"