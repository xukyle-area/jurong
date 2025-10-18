#!/bin/bash

echo "🧪 测试 Headlamp Kubernetes 连接"
echo ""

# 检查 Headlamp 容器是否运行
if ! docker ps | grep headlamp-fixed > /dev/null; then
    echo "❌ Headlamp 容器未运行"
    echo "请先运行: ./fix-headlamp.sh"
    exit 1
fi

echo "✅ Headlamp 容器正在运行"

# 测试 Headlamp Web 界面
echo "📡 测试 Headlamp Web 界面..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4466 || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Headlamp Web 界面响应正常"
else
    echo "⚠️  Headlamp Web 界面响应异常 (HTTP $HTTP_CODE)"
fi

# 测试 Kubernetes API 直连
echo "🔍 测试 Kubernetes API 连接..."
if kubectl get nodes > /dev/null 2>&1; then
    echo "✅ kubectl 可以连接到 Kubernetes"
    kubectl get nodes
else
    echo "❌ kubectl 无法连接到 Kubernetes"
fi

# 检查 Headlamp 代理 API
echo "🔄 测试 Headlamp API 代理..."
API_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:4466/clusters/docker-desktop/api/v1/nodes" 2>/dev/null || echo "000")

if [ "$API_CODE" = "200" ]; then
    echo "✅ Headlamp API 代理工作正常"
    echo "🎉 所有连接测试通过!"
    echo ""
    echo "📊 现在可以访问: http://localhost:4466"
    echo "应该能看到 docker-desktop 集群和所有资源"
elif [ "$API_CODE" = "401" ]; then
    echo "🔐 Headlamp API 代理返回 401 (认证问题)"
    echo "这可能是正常的，因为可能需要通过 Web 界面认证"
    echo "请尝试在浏览器中访问: http://localhost:4466"
else
    echo "⚠️  Headlamp API 代理响应异常 (HTTP $API_CODE)"
    echo "请检查 Headlamp 日志:"
    echo "docker logs headlamp-fixed --tail 10"
fi

echo ""
echo "💡 如果网页显示 'Choose a cluster' 并且没有集群："
echo "1. 刷新浏览器页面"
echo "2. 等待几分钟让服务完全加载"
echo "3. 检查 Docker Desktop 的 Kubernetes 是否真的启用了"