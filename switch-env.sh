#!/bin/bash

# Kubernetes 数据平台管理工具

set -e

K8S_DEPLOY_SCRIPT="flink/deploy-k8s-complete.sh"

show_status() {
    echo "📊 Kubernetes 数据平台状态"
    echo "======================="
    
    echo ""
    echo "☸️  集群连接状态:"
    if kubectl cluster-info &> /dev/null; then
        echo "✅ 已连接到 Kubernetes 集群"
        kubectl cluster-info --context=$(kubectl config current-context) | head -1
    else
        echo "❌ 无法连接到 Kubernetes 集群"
        return 1
    fi
    
    echo ""
    echo "📦 数据平台命名空间状态:"
    if kubectl get namespace data-platform 2>/dev/null | grep -q "Active"; then
        echo "✅ data-platform 命名空间存在"
        echo ""
        echo "🔍 Pod 状态:"
        kubectl get pods -n data-platform
        echo ""
        echo "🌐 服务状态:"
        kubectl get svc -n data-platform
    else
        echo "❌ data-platform 命名空间不存在"
    fi
}

deploy_platform() {
    echo "� 部署 Kubernetes 数据平台..."
    
    # 检查集群连接
    if ! kubectl cluster-info &> /dev/null; then
        echo "❌ 无法连接到 Kubernetes 集群"
        echo "请确保 kubectl 已正确配置并连接到集群"
        exit 1
    fi
    
    echo "🎯 开始部署数据平台..."
    $K8S_DEPLOY_SCRIPT deploy
}

start_services() {
    echo "🔄 启动数据平台服务..."
    
    if ! kubectl get namespace data-platform &> /dev/null; then
        echo "❌ 数据平台未部署，请先运行: $0 deploy"
        exit 1
    fi
    
    echo "📦 重启所有服务..."
    kubectl rollout restart deployment -n data-platform
    kubectl rollout restart statefulset -n data-platform
    
    echo "✅ 服务重启完成"
}

stop_services() {
    echo "⏹️ 停止数据平台服务..."
    
    if ! kubectl get namespace data-platform &> /dev/null; then
        echo "❌ 数据平台命名空间不存在"
        return 0
    fi
    
    echo "🛑 缩放所有部署到 0 副本..."
    kubectl scale deployment --replicas=0 --all -n data-platform
    kubectl scale statefulset --replicas=0 --all -n data-platform
    
    echo "✅ 服务已停止"
}

cleanup_platform() {
    echo "🧹 清理数据平台..."
    
    read -p "⚠️  这将删除所有数据平台资源，确定继续吗? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        $K8S_DEPLOY_SCRIPT cleanup
        echo "✅ 清理完成"
    else
        echo "❌ 清理已取消"
    fi
}

show_platform_info() {
    echo "� Kubernetes 数据平台信息"
    echo "========================="
    echo ""
    echo "�️ 架构优势:"
    echo "  ✅ 高可用和自动恢复"
    echo "  ✅ 水平扩展和负载均衡"
    echo "  ✅ 服务发现和配置管理"
    echo "  ✅ 滚动更新零停机"
    echo "  ✅ 监控和日志集中管理"
    echo "  ✅ 生产级持久化存储"
    echo ""
    echo "🎯 适用场景:"
    echo "  🏭 生产环境部署"
    echo "  📈 大规模数据处理"
    echo "  🔒 企业级安全要求"
    echo "  🌍 多环境统一管理"
    echo "  🔄 DevOps 自动化"
    echo ""
    echo "📋 服务架构:"
    printf "%-20s %-40s\n" "组件" "Kubernetes 实现"
    echo "============================================================"
    printf "%-20s %-40s\n" "Kafka" "StatefulSet + PVC + LoadBalancer"
    printf "%-20s %-40s\n" "MySQL" "StatefulSet + PVC + 数据持久化"
    printf "%-20s %-40s\n" "Redis" "Deployment + PVC + 高可用"
    printf "%-20s %-40s\n" "Flink" "JobManager + TaskManager 分离部署"
    printf "%-20s %-40s\n" "管理界面" "Deployment + Service + Ingress"
    printf "%-20s %-40s\n" "网络" "Service Mesh + NetworkPolicy"
    printf "%-20s %-40s\n" "存储" "PersistentVolumeClaims"
    printf "%-20s %-40s\n" "扩展" "HorizontalPodAutoscaler"
}

get_connection_info() {
    echo "🔗 服务连接信息"
    echo "============="
    
    if ! kubectl get namespace data-platform 2>/dev/null | grep -q "Active"; then
        echo "❌ 数据平台未部署，请先运行: $0 deploy"
        return 1
    fi
    
    echo ""
    echo "☸️  Kubernetes 集群内连接:"
    echo "  Kafka Bootstrap:  kafka-service.data-platform.svc.cluster.local:9092"
    echo "  MySQL:            mysql-service.data-platform.svc.cluster.local:3306"
    echo "                    用户: root, 密码: rootpassword"
    echo "  Redis:            redis-service.data-platform.svc.cluster.local:6379"
    echo "                    密码: redispassword"
    echo "  Flink JobManager: flink-jobmanager.data-platform.svc.cluster.local:8081"
    echo ""
    echo "🌐 外部访问 (端口转发):"
    echo "  # 启动端口转发"
    echo "  kubectl port-forward -n data-platform svc/kafka-ui 8080:8080 &"
    echo "  kubectl port-forward -n data-platform svc/phpmyadmin 8081:8081 &"
    echo "  kubectl port-forward -n data-platform svc/redis-commander 8082:8082 &"
    echo "  kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083 &"
    echo ""
    echo "  # 访问地址"
    echo "  Kafka UI:         http://localhost:8080"
    echo "  phpMyAdmin:       http://localhost:8081 (用户: root)"
    echo "  Redis Commander:  http://localhost:8082"
    echo "  Flink Web UI:     http://localhost:8083"
    echo ""
    echo "📡 一键启动所有端口转发:"
    echo "  $0 port-forward"
}

start_port_forward() {
    echo "📡 启动端口转发..."
    
    if ! kubectl get namespace data-platform 2>/dev/null | grep -q "Active"; then
        echo "❌ 数据平台未部署，请先运行: $0 deploy"
        return 1
    fi
    
    echo "🔗 启动所有服务的端口转发..."
    
    # 后台启动端口转发
    kubectl port-forward -n data-platform svc/kafka-ui 8080:8080 &
    KAFKA_UI_PID=$!
    
    kubectl port-forward -n data-platform svc/phpmyadmin 8081:8081 &
    PHPMYADMIN_PID=$!
    
    kubectl port-forward -n data-platform svc/redis-commander 8082:8082 &
    REDIS_CMD_PID=$!
    
    kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083 &
    FLINK_UI_PID=$!
    
    sleep 3
    
    echo "✅ 端口转发已启动:"
    echo "  Kafka UI:         http://localhost:8080 (PID: $KAFKA_UI_PID)"
    echo "  phpMyAdmin:       http://localhost:8081 (PID: $PHPMYADMIN_PID)"
    echo "  Redis Commander:  http://localhost:8082 (PID: $REDIS_CMD_PID)"
    echo "  Flink Web UI:     http://localhost:8083 (PID: $FLINK_UI_PID)"
    echo ""
    echo "🛑 停止端口转发: kill $KAFKA_UI_PID $PHPMYADMIN_PID $REDIS_CMD_PID $FLINK_UI_PID"
}

main() {
    case "${1:-help}" in
        "deploy"|"up")
            deploy_platform
            ;;
        "start")
            start_services
            ;;
        "stop")
            stop_services
            ;;
        "cleanup"|"clean")
            cleanup_platform
            ;;
        "status")
            show_status
            ;;
        "info"|"platform-info")
            show_platform_info
            ;;
        "connection"|"conn")
            get_connection_info
            ;;
        "port-forward"|"pf")
            start_port_forward
            ;;
        "help"|*)
            echo "� Kubernetes 数据平台管理工具"
            echo "============================="
            echo ""
            echo "使用方法: $0 <command>"
            echo ""
            echo "🏗️ 平台管理:"
            echo "  deploy|up       - 部署完整数据平台"
            echo "  start           - 启动已部署的服务"
            echo "  stop            - 停止服务 (保留数据)"
            echo "  cleanup|clean   - 清理所有资源"
            echo "  status          - 查看平台状态"
            echo ""
            echo "🔗 连接访问:"
            echo "  connection|conn - 查看服务连接信息"
            echo "  port-forward|pf - 启动端口转发"
            echo "  info            - 查看平台架构信息"
            echo ""
            echo "💡 推荐工作流:"
            echo "  1. 首次部署: $0 deploy"
            echo "  2. 查看状态: $0 status"
            echo "  3. 访问服务: $0 port-forward"
            echo "  4. 获取连接: $0 connection"
            echo ""
            echo "🔧 高级操作:"
            echo "  ./flink/deploy-k8s-complete.sh [command] - 详细部署控制"
            ;;
    esac
}

main "$@"