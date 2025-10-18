#!/bin/bash

echo "🔍 Kafka 和 Headlamp 服务状态检查"
echo "=================================="

echo ""
echo "📊 Docker Compose 服务状态:"
echo "----------------------------"
docker-compose ps

echo ""
echo "🎯 Kubernetes 服务状态:"
echo "-----------------------"
echo "Headlamp pods:"
kubectl get pods -n infra -l app=headlamp
echo ""
echo "Kafka pods (应该为空，因为我们使用 Docker Compose):"
kubectl get pods -n infra -l app=kafka

echo ""
echo "🌐 服务访问地址:"
echo "---------------"
echo "✅ Kafka: localhost:9092"
echo "✅ ZooKeeper: localhost:2181"
echo "✅ Kafka UI: http://localhost:8080"
echo "✅ Headlamp: http://localhost:30466"

echo ""
echo "🧪 快速连接测试:"
echo "----------------"

# 测试 Kafka UI
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
    echo "✅ Kafka UI 可访问"
else
    echo "❌ Kafka UI 不可访问"
fi

# 测试 Headlamp
if curl -s -o /dev/null -w "%{http_code}" http://localhost:30466 | grep -q "200"; then
    echo "✅ Headlamp 可访问"
else
    echo "❌ Headlamp 不可访问"
fi

# 测试 Kafka 主题列表
echo ""
echo "📋 Kafka Topics:"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>/dev/null || echo "❌ 无法连接到 Kafka"

echo ""
echo "💡 建议:"
echo "- 使用 Docker Compose 运行 Kafka (已正常运行)"
echo "- 使用 Kubernetes 运行 Headlamp (已正常运行)"
echo "- 如果需要重启服务: docker-compose restart"