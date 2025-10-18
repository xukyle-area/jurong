#!/bin/bash

# 完整的数据平台 Kubernetes 部署脚本

set -e

echo "🚀 部署完整数据平台到 Kubernetes"
echo "============================="

# 检查必要工具
check_prerequisites() {
    echo "🔍 检查前置条件..."
    
    for tool in kubectl; do
        if ! command -v $tool &> /dev/null; then
            echo "❌ $tool 未安装"
            exit 1
        fi
    done
    
    # 检查 kubectl 连接
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ 无法连接到 Kubernetes 集群"
        exit 1
    fi
    
    echo "✅ 前置条件检查通过"
}

# 创建命名空间
create_namespace() {
    echo "📦 创建命名空间..."
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: data-platform
  labels:
    name: data-platform
EOF
    echo "✅ 命名空间创建完成"
}

# 部署基础设施服务
deploy_infrastructure() {
    echo "🏗️ 部署基础设施服务..."
    
    echo "部署 MySQL, Redis, ZooKeeper, Kafka..."
    kubectl apply -f k8s-complete-stack.yaml
    
    echo "⏳ 等待基础设施服务启动..."
    
    # 等待 MySQL
    echo "等待 MySQL..."
    kubectl wait --for=condition=available --timeout=300s deployment/mysql -n data-platform
    
    # 等待 Redis
    echo "等待 Redis..."
    kubectl wait --for=condition=available --timeout=300s deployment/redis -n data-platform
    
    # 等待 ZooKeeper
    echo "等待 ZooKeeper..."
    kubectl wait --for=condition=ready --timeout=300s pod -l app=zookeeper -n data-platform
    
    # 等待 Kafka
    echo "等待 Kafka..."
    kubectl wait --for=condition=ready --timeout=600s pod -l app=kafka -n data-platform
    
    # 等待 UI 服务
    echo "等待 UI 服务..."
    kubectl wait --for=condition=available --timeout=300s deployment/kafka-ui -n data-platform
    kubectl wait --for=condition=available --timeout=300s deployment/phpmyadmin -n data-platform
    kubectl wait --for=condition=available --timeout=300s deployment/redis-commander -n data-platform
    
    echo "✅ 基础设施服务部署完成"
}

# 部署 Flink 集群
deploy_flink() {
    echo "🌊 部署 Flink 集群..."
    
    kubectl apply -f k8s-flink.yaml
    
    echo "⏳ 等待 Flink 集群启动..."
    
    # 等待 JobManager
    kubectl wait --for=condition=available --timeout=300s deployment/flink-jobmanager -n data-platform
    
    # 等待 TaskManager
    kubectl wait --for=condition=available --timeout=300s deployment/flink-taskmanager -n data-platform
    
    echo "✅ Flink 集群部署完成"
}

# 创建 Kafka 主题
create_kafka_topics() {
    echo "📨 创建 Kafka 主题..."
    
    # 等待 Kafka 完全启动
    sleep 30
    
    # 创建主题
    kubectl exec -n data-platform statefulset/kafka -- kafka-topics --create --bootstrap-server localhost:9092 --topic user-events --partitions 3 --replication-factor 1 --if-not-exists
    kubectl exec -n data-platform statefulset/kafka -- kafka-topics --create --bootstrap-server localhost:9092 --topic order-events --partitions 2 --replication-factor 1 --if-not-exists
    kubectl exec -n data-platform statefulset/kafka -- kafka-topics --create --bootstrap-server localhost:9092 --topic product-updates --partitions 1 --replication-factor 1 --if-not-exists
    
    echo "📋 Kafka 主题列表:"
    kubectl exec -n data-platform statefulset/kafka -- kafka-topics --list --bootstrap-server localhost:9092
    
    echo "✅ Kafka 主题创建完成"
}

# 获取服务访问信息
get_service_info() {
    echo "🌐 服务访问信息:"
    echo "=============="
    
    echo "📊 外部访问地址 (LoadBalancer):"
    
    # 获取 LoadBalancer 外部 IP
    echo "Kafka UI:"
    kubectl get svc kafka-ui -n data-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "phpMyAdmin:"
    kubectl get svc phpmyadmin -n data-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "Redis Commander:"
    kubectl get svc redis-commander -n data-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "Flink Web UI:"
    kubectl get svc flink-jobmanager-ui -n data-platform -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "📡 端口转发命令 (本地访问):"
    echo "kubectl port-forward -n data-platform svc/kafka-ui 8080:8080"
    echo "kubectl port-forward -n data-platform svc/phpmyadmin 8081:8081"
    echo "kubectl port-forward -n data-platform svc/redis-commander 8082:8082"
    echo "kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083"
    echo "kubectl port-forward -n data-platform svc/kafka-external 9092:9092"
    echo "kubectl port-forward -n data-platform svc/mysql-external 3306:3306"
    echo "kubectl port-forward -n data-platform svc/redis-external 6379:6379"
}

# 验证部署
verify_deployment() {
    echo "🔍 验证部署状态..."
    
    echo "📊 所有 Pod 状态:"
    kubectl get pods -n data-platform
    
    echo ""
    echo "📊 所有服务状态:"
    kubectl get svc -n data-platform
    
    echo ""
    echo "📊 存储状态:"
    kubectl get pvc -n data-platform
    
    echo ""
    echo "🏥 健康检查:"
    
    # 检查关键服务健康状态
    echo "MySQL 连接测试:"
    if kubectl exec -n data-platform deployment/mysql -- mysqladmin ping -h localhost --silent; then
        echo "✅ MySQL 健康"
    else
        echo "❌ MySQL 不健康"
    fi
    
    echo "Redis 连接测试:"
    if kubectl exec -n data-platform deployment/redis -- redis-cli -a redispassword ping; then
        echo "✅ Redis 健康"
    else
        echo "❌ Redis 不健康"
    fi
    
    echo "Kafka 连接测试:"
    if kubectl exec -n data-platform statefulset/kafka -- kafka-topics --bootstrap-server localhost:9092 --list > /dev/null; then
        echo "✅ Kafka 健康"
    else
        echo "❌ Kafka 不健康"
    fi
}

# 清理部署
cleanup() {
    echo "🧹 清理所有资源..."
    
    read -p "确定要删除所有资源吗? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        kubectl delete namespace data-platform
        echo "✅ 清理完成"
    else
        echo "❌ 清理已取消"
    fi
}

# 主菜单
main() {
    case "${1:-help}" in
        "deploy")
            check_prerequisites
            create_namespace
            deploy_infrastructure
            deploy_flink
            create_kafka_topics
            get_service_info
            verify_deployment
            ;;
        "infrastructure")
            check_prerequisites
            create_namespace
            deploy_infrastructure
            ;;
        "flink")
            deploy_flink
            ;;
        "topics")
            create_kafka_topics
            ;;
        "status")
            verify_deployment
            ;;
        "info")
            get_service_info
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            echo "🚀 Kubernetes 数据平台部署工具"
            echo "============================="
            echo ""
            echo "使用方法: $0 <command>"
            echo ""
            echo "命令:"
            echo "  deploy        - 完整部署 (推荐)"
            echo "  infrastructure - 仅部署基础设施"
            echo "  flink         - 仅部署 Flink"
            echo "  topics        - 创建 Kafka 主题"
            echo "  status        - 查看部署状态"
            echo "  info          - 查看服务访问信息"
            echo "  cleanup       - 清理所有资源"
            echo ""
            echo "📊 部署后的服务:"
            echo "  - Kafka + ZooKeeper"
            echo "  - MySQL + phpMyAdmin"
            echo "  - Redis + Redis Commander"
            echo "  - Flink JobManager + TaskManager"
            echo "  - Kafka UI"
            echo ""
            echo "🌐 外部访问通过 LoadBalancer 或端口转发"
            ;;
    esac
}

main "$@"