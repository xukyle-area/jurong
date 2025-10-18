#!/bin/bash

echo "🚀 启动 Headlamp - Kubernetes 管理界面"
echo ""

# 检查是否有 Kubernetes 集群可用
if ! kubectl cluster-info &> /dev/null; then
    echo "⚠️  警告: 未检测到可用的 Kubernetes 集群"
    echo "请确保 Docker Desktop 的 Kubernetes 功能已启用，或者连接到其他 Kubernetes 集群"
    echo ""
fi

# 启动服务
echo "1. 启动 Headlamp 和相关服务..."
docker-compose up -d

echo ""
echo "2. 检查服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ 服务已启动!"
echo ""
echo "📊 访问地址:"
echo "- Headlamp (Kubernetes UI): http://localhost:4466"
echo "- Kafka UI: http://localhost:8080"
echo "- Kafka: localhost:9092"
echo "- ZooKeeper: localhost:2181"
echo ""

# 等待 Headlamp 完全启动
echo "⏳ 等待 Headlamp 完全启动..."
sleep 5

# 检查 Headlamp 服务
if curl -s http://localhost:4466 > /dev/null; then
    echo "✅ Headlamp 已就绪!"
    echo "🌐 打开浏览器访问: http://localhost:4466"
else
    echo "⚠️  Headlamp 可能还在启动中，请稍后访问: http://localhost:4466"
fi

echo ""
echo "💡 使用提示:"
echo "- 如果 Headlamp 显示无集群，请确保 Docker Desktop 的 Kubernetes 已启用"
echo "- 你也可以连接到其他 Kubernetes 集群"
echo ""
echo "🛑 停止服务: docker-compose down"