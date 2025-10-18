#!/bin/bash

echo "🚀 在 Kubernetes 中部署 Headlamp"
echo ""

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl 未找到，请先安装 kubectl"
    exit 1
fi

# 检查 Kubernetes 集群连接
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ 无法连接到 Kubernetes 集群"
    echo "请确保 Docker Desktop 的 Kubernetes 功能已启用，或配置其他 Kubernetes 集群"
    exit 1
fi

echo "✅ Kubernetes 集群连接正常"
echo ""

# 创建命名空间
echo "1. 创建 infra 命名空间..."
kubectl apply -f deployments/namespace.yaml

echo ""
echo "2. 部署 Headlamp..."
kubectl apply -f deployments/headlamp-deployment.yaml

echo ""
echo "3. 等待 Headlamp 启动..."
kubectl wait --for=condition=ready pod -l app=headlamp -n infra --timeout=60s

echo ""
echo "4. 检查部署状态..."
kubectl get pods -n infra -l app=headlamp
kubectl get services -n infra -l app=headlamp

echo ""
echo "✅ Headlamp 部署完成!"
echo ""
echo "📊 访问方式:"
echo "方式 1 - NodePort (推荐):"
echo "  访问地址: http://localhost:30466"
echo ""
echo "方式 2 - 端口转发:"
echo "  运行: kubectl port-forward -n infra service/headlamp 4466:4466"
echo "  然后访问: http://localhost:4466"
echo ""
echo "💡 使用提示:"
echo "- Headlamp 已配置 cluster-admin 权限，可以管理整个集群"
echo "- 通过浏览器访问上述地址即可使用 Kubernetes 管理界面"
echo ""
echo "🛑 删除部署:"
echo "  kubectl delete -f deployments/headlamp-deployment.yaml"