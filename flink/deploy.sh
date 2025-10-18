#!/bin/bash

# AWS EMR on EKS + Flink Operator 部署脚本

set -e

echo "🚀 部署 AWS EMR on EKS + Flink 集群"
echo "================================="

# 检查必要工具
check_prerequisites() {
    for tool in kubectl helm aws; do
        if ! command -v $tool &> /dev/null; then
            echo "❌ $tool 未安装"
            exit 1
        fi
    done
    
    # 检查 AWS 认证
    if ! aws sts get-caller-identity &> /dev/null; then
        echo "❌ AWS 认证失败，请配置 AWS 凭证"
        exit 1
    fi
    
    echo "✅ 前置条件检查通过"
}

# 安装必要的 Operators
install_operators() {
    echo "📦 安装 Kubernetes Operators..."
    
    # 1. 安装 Strimzi Kafka Operator
    echo "安装 Strimzi Kafka Operator..."
    kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -
    helm repo add strimzi https://strimzi.io/charts/
    helm repo update
    helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
        --namespace kafka --create-namespace \
        --wait --timeout=300s
    
    # 2. 安装 Redis Operator
    echo "安装 Redis Operator..."
    helm repo add redis-operator https://spotahome.github.io/redis-operator
    helm upgrade --install redis-operator redis-operator/redis-operator \
        --namespace redis-system --create-namespace
    
    # 3. 检查 Flink Operator (应该已通过 setup 脚本安装)
    if ! kubectl get crd flinkdeployments.flink.apache.org &> /dev/null; then
        echo "❌ Flink Operator 未安装，请先运行 setup-emr-flink.sh"
        exit 1
    fi
    
    echo "✅ Operators 安装完成"
}

# 部署基础设施
deploy_infrastructure() {
    echo "🏗️ 部署基础设施服务..."
    
    # 替换环境变量
    export EMR_VIRTUAL_CLUSTER_ID=${EMR_VIRTUAL_CLUSTER_ID:-"your-cluster-id"}
    
    # 部署基础设施
    envsubst < k8s-infrastructure.yaml | kubectl apply -f -
    
    echo "⏳ 等待基础设施服务启动..."
    
    # 等待 Kafka 集群
    kubectl wait --for=condition=Ready kafka/kafka-cluster -n data-platform --timeout=600s
    
    # 等待 MySQL
    kubectl wait --for=condition=available deployment/mysql -n data-platform --timeout=300s
    
    # 等待 Redis
    kubectl wait --for=condition=Ready redisfailover/redis-cluster -n data-platform --timeout=300s
    
    echo "✅ 基础设施部署完成"
}

# 部署 Flink 集群
deploy_flink() {
    echo "🌊 部署 Flink 集群..."
    
    # 确保 EMR 虚拟集群 ID 已设置
    if [ -z "$EMR_VIRTUAL_CLUSTER_ID" ]; then
        echo "❌ EMR_VIRTUAL_CLUSTER_ID 环境变量未设置"
        exit 1
    fi
    
    # 部署 Flink 集群
    envsubst < flink-emr-deployment.yaml | kubectl apply -f -
    
    echo "⏳ 等待 Flink 集群启动..."
    kubectl wait --for=condition=Ready flinkdeployment/flink-session-emr -n emr --timeout=600s
    
    echo "✅ Flink 集群部署完成"
}

# 验证部署
verify_deployment() {
    echo "🔍 验证部署状态..."
    
    echo "📊 基础设施状态:"
    kubectl get pods -n data-platform
    
    echo "🌊 Flink 集群状态:"
    kubectl get flinkdeployment -n emr
    kubectl get pods -n emr
    
    echo "🌐 服务访问信息:"
    echo "Kafka: $(kubectl get svc kafka-cluster-kafka-external-bootstrap -n data-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):9094"
    echo "MySQL: $(kubectl get svc mysql -n data-platform -o jsonpath='{.spec.clusterIP}'):3306"
    echo "Redis: $(kubectl get svc rfs-redis-cluster -n data-platform -o jsonpath='{.spec.clusterIP}'):6379"
    
    # Flink Web UI
    kubectl port-forward svc/flink-session-emr-rest -n emr 8081:8081 &
    echo "Flink UI: http://localhost:8081 (端口转发已启动)"
}

# 主执行流程
main() {
    echo "请选择部署步骤:"
    echo "1) 检查前置条件"
    echo "2) 安装 Operators"
    echo "3) 部署基础设施"
    echo "4) 部署 Flink 集群"
    echo "5) 验证部署"
    echo "6) 全部执行"
    
    read -p "请输入选项 (1-6): " choice
    
    case $choice in
        1) check_prerequisites ;;
        2) install_operators ;;
        3) deploy_infrastructure ;;
        4) deploy_flink ;;
        5) verify_deployment ;;
        6)
            check_prerequisites
            install_operators
            deploy_infrastructure
            deploy_flink
            verify_deployment
            ;;
        *) echo "❌ 无效选项" && exit 1 ;;
    esac
    
    echo "🎉 部署完成!"
}

main "$@"
kubectl wait --for=condition=available --timeout=300s deployment/kafka -n flink-local
kubectl wait --for=condition=available --timeout=300s deployment/zookeeper -n flink-local

# 2. 部署 Flink Session 集群
echo "2. 部署 Flink Session 集群..."
kubectl apply -f k8s/flink-session-local.yaml

# 等待 Session 集群启动
echo "等待 Session 集群启动..."
sleep 30

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