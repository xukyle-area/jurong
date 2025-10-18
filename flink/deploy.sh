#!/bin/bash

# 部署脚本 - 模拟你们公司的混合架构

set -e

echo "=== 部署 Flink 混合架构 (基于你们公司配置) ==="

# 检查 kubectl
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装"
    exit 1
fi

# 检查 Flink Operator
if ! kubectl get crd flinkdeployments.flink.apache.org &> /dev/null; then
    echo "警告: Flink Operator 未安装，请先安装:"
    echo "helm repo add flink-operator-repo https://downloads.apache.org/flink/flink-kubernetes-operator-1.6.1/"
    echo "helm install flink-kubernetes-operator flink-operator-repo/flink-kubernetes-operator --create-namespace"
    exit 1
fi

# 1. 部署基础服务
echo "1. 部署基础服务..."
kubectl apply -f k8s/support-services.yaml

# 等待基础服务启动
echo "等待基础服务启动..."
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n flink-local
kubectl wait --for=condition=available --timeout=300s deployment/redis -n flink-local
kubectl wait --for=condition=available --timeout=300s deployment/kafka -n flink-local
kubectl wait --for=condition=available --timeout=300s deployment/zookeeper -n flink-local

# 2. 部署 Flink Session 集群
echo "2. 部署 Flink Session 集群..."
kubectl apply -f k8s/flink-session-local.yaml

# 等待 Session 集群启动
echo "等待 Session 集群启动..."
sleep 30

# 3. 部署示例作业 (可选)
read -p "是否部署示例作业? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "3. 部署示例作业..."
    kubectl apply -f k8s/flink-job-demo.yaml
fi

# 4. 显示访问信息
echo ""
echo "=== 部署完成 ==="
echo ""
echo "服务状态:"
kubectl get pods -n flink-local
echo ""
echo "Flink 集群:"
kubectl get flinkdeployments -n flink-local
echo ""
echo "访问方式:"
echo "1. Session 集群 Web UI:"
echo "   kubectl port-forward service/flink-sessions-local-rest 8081:8081 -n flink-local"
echo "   然后访问: http://localhost:8081"
echo ""
echo "2. 查看日志:"
echo "   kubectl logs -f deployment/flink-sessions-local-jobmanager -n flink-local"
echo ""
echo "3. 连接数据库:"
echo "   kubectl port-forward service/mysql 3306:3306 -n flink-local"
echo ""
echo "4. 连接Redis:"
echo "   kubectl port-forward service/redis 6379:6379 -n flink-local"
echo ""
echo "5. 清理环境:"
echo "   kubectl delete namespace flink-local"