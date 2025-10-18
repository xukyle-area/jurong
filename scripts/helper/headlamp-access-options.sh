#!/bin/bash

echo "🌐 Headlamp 访问方式大全"
echo "========================"
echo ""

# 获取服务信息
CLUSTER_IP=$(kubectl get service headlamp -n infra -o jsonpath='{.spec.clusterIP}')
NODE_PORT=$(kubectl get service headlamp -n infra -o jsonpath='{.spec.ports[0].nodePort}')
TARGET_PORT=$(kubectl get service headlamp -n infra -o jsonpath='{.spec.ports[0].targetPort}')

echo "📊 当前 Headlamp 服务信息:"
echo "- 集群内部 IP: $CLUSTER_IP"
echo "- NodePort: $NODE_PORT"
echo "- 目标端口: $TARGET_PORT"
echo ""

echo "🚀 访问方式选项:"
echo ""

echo "1️⃣  NodePort 方式 (无需端口转发)"
echo "   http://localhost:$NODE_PORT"
echo "   ✅ 推荐：简单直接，无需额外命令"
echo ""

echo "2️⃣  端口转发方式"
echo "   命令: kubectl port-forward -n infra service/headlamp 4466:4466"
echo "   访问: http://localhost:4466"
echo "   ✅ 推荐：使用标准端口"
echo ""

echo "3️⃣  自定义端口转发"
echo "   命令: kubectl port-forward -n infra service/headlamp 8090:4466"
echo "   访问: http://localhost:8090"
echo "   💡 你可以使用任何未占用的端口"
echo ""

echo "4️⃣  直接 Pod 端口转发"
POD_NAME=$(kubectl get pods -n infra -l app=headlamp -o jsonpath='{.items[0].metadata.name}')
echo "   命令: kubectl port-forward -n infra pod/$POD_NAME 4466:4466"
echo "   访问: http://localhost:4466"
echo "   💡 直接连接到 Pod"
echo ""

echo "5️⃣  使用不同的本地端口"
echo "   你可以选择任何端口，例如："
echo "   - kubectl port-forward -n infra service/headlamp 3000:4466  →  http://localhost:3000"
echo "   - kubectl port-forward -n infra service/headlamp 5000:4466  →  http://localhost:5000"
echo "   - kubectl port-forward -n infra service/headlamp 9999:4466  →  http://localhost:9999"
echo ""

echo "🔧 快速启动命令:"
echo "=================="

echo ""
echo "启动端口转发 (端口 4466):"
echo "kubectl port-forward -n infra service/headlamp 4466:4466 &"
echo ""

echo "启动端口转发 (端口 8080 - 如果你喜欢这个端口):"
echo "kubectl port-forward -n infra service/headlamp 8080:4466 &"
echo ""

echo "启动端口转发 (端口 3000 - 常用的开发端口):"
echo "kubectl port-forward -n infra service/headlamp 3000:4466 &"
echo ""

echo "💡 建议:"
echo "======="
echo "- 如果你不想记住 30466，使用端口转发到 4466"
echo "- 如果你想要更简单，直接使用 NodePort: http://localhost:$NODE_PORT"
echo "- 如果端口冲突，选择其他端口如 3000, 5000, 8080 等"
echo ""

# 检查当前是否有端口转发在运行
echo "🔍 当前运行的端口转发:"
if pgrep -f "kubectl port-forward.*headlamp" > /dev/null; then
    echo "✅ 检测到 Headlamp 端口转发正在运行"
    echo "   进程: $(pgrep -f 'kubectl port-forward.*headlamp')"
else
    echo "❌ 未检测到 Headlamp 端口转发"
fi

echo ""
echo "🛑 停止端口转发:"
echo "pkill -f 'kubectl port-forward.*headlamp'"