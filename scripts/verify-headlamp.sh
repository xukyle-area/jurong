#!/bin/bash

echo "🎯 Headlamp 最终验证和使用指南"
echo ""

# 检查 Kubernetes 集群
echo "1. 检查 Kubernetes 集群状态..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ Kubernetes 集群运行正常"
    kubectl get nodes
else
    echo "❌ Kubernetes 集群未运行"
    exit 1
fi

echo ""

# 检查 Headlamp 部署
echo "2. 检查 Headlamp 部署状态..."
if kubectl get pods -n infra -l app=headlamp | grep Running > /dev/null; then
    echo "✅ Headlamp 在 Kubernetes 中运行正常"
    kubectl get pods -n infra -l app=headlamp
    kubectl get services -n infra -l app=headlamp
else
    echo "❌ Headlamp 未在 Kubernetes 中运行"
    echo "请运行: ./deploy-headlamp-k8s.sh"
    exit 1
fi

echo ""

# 测试服务访问
echo "3. 测试 Headlamp 服务访问..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:30466 2>/dev/null || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Headlamp Web 界面响应正常 (HTTP $HTTP_CODE)"
elif [ "$HTTP_CODE" = "000" ]; then
    echo "⚠️  无法连接到 Headlamp，可能需要等待更长时间"
    echo "NodePort 服务可能需要几分钟才能完全就绪"
else
    echo "⚠️  Headlamp Web 界面响应异常 (HTTP $HTTP_CODE)"
fi

echo ""
echo "🌐 访问 Headlamp:"
echo "主要地址: http://localhost:30466"
echo ""

# 端口转发选项
echo "📡 如果 NodePort 不工作，尝试端口转发:"
echo "运行命令: kubectl port-forward -n infra service/headlamp 4466:4466"
echo "然后访问: http://localhost:4466"
echo ""

# 检查集群资源
echo "4. 当前集群资源概览:"
echo "Namespaces:"
kubectl get namespaces
echo ""
echo "Pods in infra namespace:"
kubectl get pods -n infra
echo ""

echo "✨ 使用提示:"
echo "- Headlamp 运行在 Kubernetes 内部，具有 cluster-admin 权限"
echo "- 可以管理整个 Kubernetes 集群"
echo "- 如果看不到集群，刷新浏览器页面等待加载"
echo "- Headlamp 会自动使用 ServiceAccount 认证"
echo ""

echo "🛑 管理命令:"
echo "查看日志: kubectl logs -n infra deployment/headlamp"
echo "重启服务: kubectl rollout restart -n infra deployment/headlamp"
echo "删除服务: kubectl delete -f deployments/headlamp-deployment.yaml"