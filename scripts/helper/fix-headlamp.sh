#!/bin/bash

echo "🔧 修复 Headlamp Kubernetes 连接问题"
echo ""

# 获取 Docker Desktop Kubernetes API Server 的实际地址
KUBE_API=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
echo "检测到的 Kubernetes API Server: $KUBE_API"

# 检查 Docker Desktop Kubernetes 是否运行
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes 集群未运行"
    echo "请在 Docker Desktop 中启用 Kubernetes 功能"
    exit 1
fi

echo "✅ Kubernetes 集群运行正常"

# 停止现有的 Headlamp
echo "停止当前的 Headlamp 容器..."
docker-compose stop headlamp

# 使用 docker run 直接运行 Headlamp，这样可以更好地控制网络
echo "启动 Headlamp（使用主机网络模式）..."
docker run -d \
  --name headlamp-fixed \
  --restart unless-stopped \
  --network host \
  -v ~/.kube/config:/root/.kube/config:ro \
  -v headlamp-config:/headlamp-config \
  -e HEADLAMP_CONFIG_DIR=/headlamp-config \
  ghcr.io/kinvolk/headlamp:latest

echo "等待 Headlamp 启动..."
sleep 5

# 检查服务状态
if docker ps | grep headlamp-fixed > /dev/null; then
    echo "✅ Headlamp 启动成功!"
    echo ""
    echo "📊 访问地址: http://localhost:4466"
    echo ""
    
    # 检查日志
    echo "📋 启动日志:"
    docker logs headlamp-fixed --tail 5
    
    echo ""
    echo "💡 如果仍然看不到集群，请尝试："
    echo "1. 重启 Docker Desktop"
    echo "2. 确保 Kubernetes 功能已启用"
    echo "3. 运行: kubectl get nodes 确认集群正常"
else
    echo "❌ Headlamp 启动失败"
    echo "查看日志："
    docker logs headlamp-fixed
fi

echo ""
echo "🛑 停止 Headlamp: docker stop headlamp-fixed && docker rm headlamp-fixed"