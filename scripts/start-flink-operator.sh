#!/bin/bash

# 启动 Flink Kubernetes Operator
# 使用经过验证的配置文件

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DEPLOYMENT_FILE="$PROJECT_ROOT/manifests/flink-operator-deployment.yaml"

echo "🚀 启动 Flink Kubernetes Operator"
echo "================================="

# 检查配置文件是否存在
if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo "❌ 配置文件不存在: $DEPLOYMENT_FILE"
    exit 1
fi

# 检查 Kubernetes 集群
echo "🔍 检查 Kubernetes 集群..."
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ Kubernetes 集群不可用，请启动 Docker Desktop"
    exit 1
fi
echo "✅ Kubernetes 集群正常"

# 检查 infra 命名空间
echo "📦 检查 infra 命名空间..."
if ! kubectl get namespace infra &>/dev/null; then
    echo "❌ infra 命名空间不存在，请先创建"
    exit 1
fi
echo "✅ infra 命名空间已存在"

# 检查是否已经运行
echo "🔍 检查 Operator 状态..."
if kubectl get pods -n infra -l app.kubernetes.io/name=flink-kubernetes-operator | grep -q Running; then
    echo "✅ Flink Kubernetes Operator 已经在运行"
    kubectl get pods -n infra -l app.kubernetes.io/name=flink-kubernetes-operator
    exit 0
fi

# 安装 FlinkDeployment CRD（如果不存在）
echo "� 检查 FlinkDeployment CRD..."
if ! kubectl get crd flinkdeployments.flink.apache.org &>/dev/null; then
    echo "� 安装 FlinkDeployment CRD..."
    kubectl apply -f https://raw.githubusercontent.com/apache/flink-kubernetes-operator/release-1.6/helm/flink-kubernetes-operator/crds/flinkdeployments.flink.apache.org-v1.yml
    echo "✅ CRD 安装完成"
else
    echo "✅ FlinkDeployment CRD 已存在"
fi

# 部署 Operator
echo "🔧 部署 Flink Kubernetes Operator..."
kubectl apply -f "$DEPLOYMENT_FILE"

# 等待 Operator 启动
echo "⏳ 等待 Operator 启动..."
kubectl wait --for=condition=available --timeout=120s \
    deployment/flink-kubernetes-operator -n infra 2>/dev/null || {
    echo "⚠️  Operator 启动时间较长，检查状态..."
    kubectl get pods -n infra -l app.kubernetes.io/name=flink-kubernetes-operator
    
    # 等待 Pod Ready
    echo "⏳ 等待 Pod Ready..."
    kubectl wait --for=condition=ready --timeout=120s \
        pod -l app.kubernetes.io/name=flink-kubernetes-operator -n infra || {
        echo "❌ Operator 启动失败，查看日志:"
        kubectl logs -n infra -l app.kubernetes.io/name=flink-kubernetes-operator --tail=20
        exit 1
    }
}

# 验证安装
echo "� 验证安装..."
echo ""
echo "📊 Operator 状态:"
kubectl get pods -n infra -l app.kubernetes.io/name=flink-kubernetes-operator

echo ""
echo "📊 可用的 CRD:"
kubectl get crd | grep flink

echo ""
echo "✅ Flink Kubernetes Operator 启动完成!"
echo ""
echo "🎯 现在你可以:"
echo "  - 使用 Application 模式: kubectl apply -f flink/k8s-flink-deployment.yaml"
echo "  - 查看 Operator 日志: kubectl logs -n infra -l app.kubernetes.io/name=flink-kubernetes-operator"
echo "  - 查看所有 Flink 资源: kubectl get flinkdeployment -n infra"