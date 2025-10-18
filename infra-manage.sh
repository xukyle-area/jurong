#!/bin/bash#!/bin/bash#!/bin/bash



# Kubernetes 基础设施平台管理工具



set -e# Kubernetes 基础设施平台管理工具# Kubernetes 基础设施平台管理工具



K8S_DEPLOY_SCRIPT="flink/deploy.sh"deploy_platform() {



show_status() {set -e    echo "🚀 部署 Kubernetes 基础设施平台..."

    echo "📊 Kubernetes 基础设施平台状态"

    echo "=========================="    

    

    echo ""K8S_DEPLOY_SCRIPT="flink/deploy.sh"    # 检查集群连接

    echo "☸️  集群连接状态:"

    if kubectl cluster-info &> /dev/null; then    if ! kubectl cluster-info &> /dev/null; then

        echo "✅ 已连接到 Kubernetes 集群"

        kubectl cluster-info --context=$(kubectl config current-context) | head -1show_status() {        echo "❌ 无法连接到 Kubernetes 集群"

    else

        echo "❌ 无法连接到 Kubernetes 集群"    echo "📊 Kubernetes 基础设施平台状态"        echo "请确保 kubectl 已正确配置并连接到集群"

        return 1

    fi    echo "=========================="        exit 1

    

    echo ""        fi

    echo "📦 基础设施平台命名空间状态:"

    if kubectl get namespace infra 2>/dev/null | grep -q "Active"; then    echo ""    

        echo "✅ infra 命名空间存在"

        echo ""    echo "☸️  集群连接状态:"    echo "🎯 开始部署基础设施平台..."

        echo "🔍 Pod 状态:"

        kubectl get pods -n infra    if kubectl cluster-info &> /dev/null; then    $K8S_DEPLOY_SCRIPT deploy

        echo ""

        echo "🌐 服务状态:"        echo "✅ 已连接到 Kubernetes 集群"}DEPLOY_SCRIPT="flink/deploy.sh"

        kubectl get svc -n infra

    else        kubectl cluster-info --context=$(kubectl config current-context) | head -1

        echo "❌ infra 命名空间不存在"

    fi    elseshow_status() {

}

        echo "❌ 无法连接到 Kubernetes 集群"    echo "📊 Kubernetes 基础设施平台状态"

deploy_platform() {

    echo "🚀 部署 Kubernetes 基础设施平台..."        return 1    echo "=========================="

    

    if ! kubectl cluster-info &> /dev/null; then    fi    

        echo "❌ 无法连接到 Kubernetes 集群"

        echo "请确保 kubectl 已正确配置并连接到集群"        echo ""

        exit 1

    fi    echo ""    echo "☸️  集群连接状态:"

    

    echo "🎯 开始部署基础设施平台..."    echo "📦 基础设施平台命名空间状态:"    if kubectl cluster-info &> /dev/null; then

    $K8S_DEPLOY_SCRIPT deploy

}    if kubectl get namespace infra 2>/dev/null | grep -q "Active"; then        echo "✅ 已连接到 Kubernetes 集群"



start_services() {        echo "✅ infra 命名空间存在"        kubectl cluster-info --context=$(kubectl config current-context) | head -1

    echo "🔄 启动基础设施平台服务..."

            echo ""    else

    if ! kubectl get namespace infra &> /dev/null; then

        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"        echo "🔍 Pod 状态:"        echo "❌ 无法连接到 Kubernetes 集群"

        exit 1

    fi        kubectl get pods -n infra        return 1

    

    echo "📦 重启所有服务..."        echo ""    fi

    kubectl rollout restart deployment -n infra

    kubectl rollout restart statefulset -n infra        echo "🌐 服务状态:"    

    

    echo "✅ 服务重启完成"        kubectl get svc -n infra    echo ""

}

    else    echo "📦 基础设施平台命名空间状态:"

stop_services() {

    echo "⏹️ 停止基础设施平台服务..."        echo "❌ infra 命名空间不存在"    if kubectl get namespace infra 2>/dev/null | grep -q "Active"; then

    

    if ! kubectl get namespace infra &> /dev/null; then    fi        echo "✅ infra 命名空间存在"

        echo "❌ 基础设施平台命名空间不存在"

        return 0}        echo ""

    fi

            echo "🔍 Pod 状态:"

    echo "🛑 缩放所有部署到 0 副本..."

    kubectl scale deployment --replicas=0 --all -n infradeploy_platform() {        kubectl get pods -n infra

    kubectl scale statefulset --replicas=0 --all -n infra

        echo "🚀 部署 Kubernetes 基础设施平台..."        echo ""

    echo "✅ 服务已停止"

}            echo "🌐 服务状态:"



cleanup_platform() {    # 检查集群连接        kubectl get svc -n infra

    echo "🧹 清理基础设施平台..."

        if ! kubectl cluster-info &> /dev/null; then    else

    read -p "⚠️  这将删除所有基础设施平台资源，确定继续吗? (y/N): " confirm

    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then        echo "❌ 无法连接到 Kubernetes 集群"        echo "❌ infra 命名空间不存在"

        $K8S_DEPLOY_SCRIPT cleanup

        echo "✅ 清理完成"        echo "请确保 kubectl 已正确配置并连接到集群"    fi

    else

        echo "❌ 清理已取消"        exit 1}

    fi

}    fi



get_connection_info() {    deploy_platform() {

    echo "🔗 服务连接信息"

    echo "============="    echo "🎯 开始部署基础设施平台..."    echo "� 部署 Kubernetes 数据平台..."

    

    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then    $K8S_DEPLOY_SCRIPT deploy    

        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"

        return 1}    # 检查集群连接

    fi

        if ! kubectl cluster-info &> /dev/null; then

    echo ""

    echo "☸️  Kubernetes 集群内连接:"start_services() {        echo "❌ 无法连接到 Kubernetes 集群"

    echo "  Kafka Bootstrap:  kafka-service.infra.svc.cluster.local:9092"

    echo "  MySQL:            mysql-service.infra.svc.cluster.local:3306"    echo "🔄 启动基础设施平台服务..."        echo "请确保 kubectl 已正确配置并连接到集群"

    echo "                    用户: root, 密码: rootpassword"

    echo "  Redis:            redis-service.infra.svc.cluster.local:6379"            exit 1

    echo "                    密码: redispassword"

    echo "  Flink JobManager: flink-jobmanager.infra.svc.cluster.local:8081"    if ! kubectl get namespace infra &> /dev/null; then    fi

    echo ""

    echo "🌐 外部访问 (端口转发):"        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"    

    echo "  kubectl port-forward -n infra svc/kafka-ui 8080:8080 &"

    echo "  kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &"        exit 1    echo "🎯 开始部署数据平台..."

    echo "  kubectl port-forward -n infra svc/redis-commander 8082:8082 &"

    echo "  kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &"    fi    $K8S_DEPLOY_SCRIPT deploy

    echo ""

    echo "  # 访问地址"    }

    echo "  Kafka UI:         http://localhost:8080"

    echo "  phpMyAdmin:       http://localhost:8081 (用户: root)"    echo "📦 重启所有服务..."

    echo "  Redis Commander:  http://localhost:8082"

    echo "  Flink Web UI:     http://localhost:8083"    kubectl rollout restart deployment -n infrastart_services() {

    echo ""

    echo "📡 一键启动所有端口转发:"    kubectl rollout restart statefulset -n infra    echo "🔄 启动数据平台服务..."

    echo "  $0 port-forward"

}        



start_port_forward() {    echo "✅ 服务重启完成"    if ! kubectl get namespace infra &> /dev/null; then

    echo "📡 启动端口转发..."

    }        echo "❌ 数据平台未部署，请先运行: $0 deploy"

    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then

        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"        exit 1

        return 1

    fistop_services() {    fi

    

    echo "🔗 启动所有服务的端口转发..."    echo "⏹️ 停止基础设施平台服务..."    

    

    kubectl port-forward -n infra svc/kafka-ui 8080:8080 &        echo "📦 重启所有服务..."

    KAFKA_UI_PID=$!

        if ! kubectl get namespace infra &> /dev/null; then    kubectl rollout restart deployment -n infra

    kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &

    PHPMYADMIN_PID=$!        echo "❌ 基础设施平台命名空间不存在"    kubectl rollout restart statefulset -n infra

    

    kubectl port-forward -n infra svc/redis-commander 8082:8082 &        return 0    

    REDIS_CMD_PID=$!

        fi    echo "✅ 服务重启完成"

    kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &

    FLINK_UI_PID=$!    }

    

    sleep 3    echo "🛑 缩放所有部署到 0 副本..."

    

    echo "✅ 端口转发已启动:"    kubectl scale deployment --replicas=0 --all -n infrastop_services() {

    echo "  Kafka UI:         http://localhost:8080 (PID: $KAFKA_UI_PID)"

    echo "  phpMyAdmin:       http://localhost:8081 (PID: $PHPMYADMIN_PID)"    kubectl scale statefulset --replicas=0 --all -n infra    echo "⏹️ 停止数据平台服务..."

    echo "  Redis Commander:  http://localhost:8082 (PID: $REDIS_CMD_PID)"

    echo "  Flink Web UI:     http://localhost:8083 (PID: $FLINK_UI_PID)"        

    echo ""

    echo "🛑 停止端口转发: kill $KAFKA_UI_PID $PHPMYADMIN_PID $REDIS_CMD_PID $FLINK_UI_PID"    echo "✅ 服务已停止"    if ! kubectl get namespace infra &> /dev/null; then

}

}        echo "❌ 数据平台命名空间不存在"

show_help() {

    echo "🏗️ Kubernetes 基础设施平台管理工具"        return 0

    echo "============================="

    echo ""cleanup_platform() {    fi

    echo "使用方法: $0 <command>"

    echo ""    echo "🧹 清理基础设施平台..."    

    echo "🏗️ 平台管理:"

    echo "  deploy|up       - 部署完整基础设施平台"        echo "🛑 缩放所有部署到 0 副本..."

    echo "  start           - 启动已部署的服务"

    echo "  stop            - 停止服务 (保留数据)"    read -p "⚠️  这将删除所有基础设施平台资源，确定继续吗? (y/N): " confirm    kubectl scale deployment --replicas=0 --all -n infra

    echo "  cleanup|clean   - 清理所有资源"

    echo "  status          - 查看平台状态"    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then    kubectl scale statefulset --replicas=0 --all -n infra

    echo ""

    echo "🔗 连接访问:"        $K8S_DEPLOY_SCRIPT cleanup    

    echo "  connection|conn - 查看服务连接信息"

    echo "  port-forward|pf - 启动端口转发"        echo "✅ 清理完成"    echo "✅ 服务已停止"

    echo ""

    echo "💡 推荐工作流:"    else}

    echo "  1. 首次部署: $0 deploy"

    echo "  2. 查看状态: $0 status"        echo "❌ 清理已取消"

    echo "  3. 访问服务: $0 port-forward"

    echo "  4. 获取连接: $0 connection"    ficleanup_platform() {

    echo ""

    echo "🔧 高级操作:"}    echo "🧹 清理数据平台..."

    echo "  ./flink/deploy.sh [command] - 详细部署控制"

}    



main() {show_platform_info() {    read -p "⚠️  这将删除所有数据平台资源，确定继续吗? (y/N): " confirm

    case "${1:-help}" in

        "deploy"|"up")    echo "🏗️ Kubernetes 基础设施平台信息"    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then

            deploy_platform

            ;;    echo "========================="        $K8S_DEPLOY_SCRIPT cleanup

        "start")

            start_services    echo ""        echo "✅ 清理完成"

            ;;

        "stop")    echo "🏗️ 架构优势:"    else

            stop_services

            ;;    echo "  ✅ 高可用和自动恢复"        echo "❌ 清理已取消"

        "cleanup"|"clean")

            cleanup_platform    echo "  ✅ 水平扩展和负载均衡"    fi

            ;;

        "status")    echo "  ✅ 服务发现和配置管理"}

            show_status

            ;;    echo "  ✅ 滚动更新零停机"

        "connection"|"conn")

            get_connection_info    echo "  ✅ 监控和日志集中管理"show_platform_info() {

            ;;

        "port-forward"|"pf")    echo "  ✅ 生产级持久化存储"    echo "� Kubernetes 数据平台信息"

            start_port_forward

            ;;    echo ""    echo "========================="

        "help"|*)

            show_help    echo "🎯 适用场景:"    echo ""

            ;;

    esac    echo "  🏭 生产环境部署"    echo "�️ 架构优势:"

}

    echo "  📈 大规模应用支撑"    echo "  ✅ 高可用和自动恢复"

main "$@"
    echo "  🔒 企业级安全要求"    echo "  ✅ 水平扩展和负载均衡"

    echo "  🌍 多环境统一管理"    echo "  ✅ 服务发现和配置管理"

    echo "  🔄 DevOps 自动化"    echo "  ✅ 滚动更新零停机"

    echo ""    echo "  ✅ 监控和日志集中管理"

    echo "📋 服务架构:"    echo "  ✅ 生产级持久化存储"

    printf "%-20s %-40s\n" "组件" "Kubernetes 实现"    echo ""

    echo "============================================================"    echo "🎯 适用场景:"

    printf "%-20s %-40s\n" "Kafka" "StatefulSet + PVC + LoadBalancer"    echo "  🏭 生产环境部署"

    printf "%-20s %-40s\n" "MySQL" "StatefulSet + PVC + 数据持久化"    echo "  📈 大规模数据处理"

    printf "%-20s %-40s\n" "Redis" "Deployment + PVC + 高可用"    echo "  🔒 企业级安全要求"

    printf "%-20s %-40s\n" "Flink" "JobManager + TaskManager 分离部署"    echo "  🌍 多环境统一管理"

    printf "%-20s %-40s\n" "管理界面" "Deployment + Service + Ingress"    echo "  🔄 DevOps 自动化"

    printf "%-20s %-40s\n" "网络" "Service Mesh + NetworkPolicy"    echo ""

    printf "%-20s %-40s\n" "存储" "PersistentVolumeClaims"    echo "📋 服务架构:"

    printf "%-20s %-40s\n" "扩展" "HorizontalPodAutoscaler"    printf "%-20s %-40s\n" "组件" "Kubernetes 实现"

}    echo "============================================================"

    printf "%-20s %-40s\n" "Kafka" "StatefulSet + PVC + LoadBalancer"

get_connection_info() {    printf "%-20s %-40s\n" "MySQL" "StatefulSet + PVC + 数据持久化"

    echo "🔗 服务连接信息"    printf "%-20s %-40s\n" "Redis" "Deployment + PVC + 高可用"

    echo "============="    printf "%-20s %-40s\n" "Flink" "JobManager + TaskManager 分离部署"

        printf "%-20s %-40s\n" "管理界面" "Deployment + Service + Ingress"

    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then    printf "%-20s %-40s\n" "网络" "Service Mesh + NetworkPolicy"

        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"    printf "%-20s %-40s\n" "存储" "PersistentVolumeClaims"

        return 1    printf "%-20s %-40s\n" "扩展" "HorizontalPodAutoscaler"

    fi}

    

    echo ""get_connection_info() {

    echo "☸️  Kubernetes 集群内连接:"    echo "🔗 服务连接信息"

    echo "  Kafka Bootstrap:  kafka-service.infra.svc.cluster.local:9092"    echo "============="

    echo "  MySQL:            mysql-service.infra.svc.cluster.local:3306"    

    echo "                    用户: root, 密码: rootpassword"    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then

    echo "  Redis:            redis-service.infra.svc.cluster.local:6379"        echo "❌ 数据平台未部署，请先运行: $0 deploy"

    echo "                    密码: redispassword"        return 1

    echo "  Flink JobManager: flink-jobmanager.infra.svc.cluster.local:8081"    fi

    echo ""    

    echo "🌐 外部访问 (端口转发):"    echo ""

    echo "  # 启动端口转发"    echo "☸️  Kubernetes 集群内连接:"

    echo "  kubectl port-forward -n infra svc/kafka-ui 8080:8080 &"    echo "  Kafka Bootstrap:  kafka-service.infra.svc.cluster.local:9092"

    echo "  kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &"    echo "  MySQL:            mysql-service.infra.svc.cluster.local:3306"

    echo "  kubectl port-forward -n infra svc/redis-commander 8082:8082 &"    echo "                    用户: root, 密码: rootpassword"

    echo "  kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &"    echo "  Redis:            redis-service.infra.svc.cluster.local:6379"

    echo ""    echo "                    密码: redispassword"

    echo "  # 访问地址"    echo "  Flink JobManager: flink-jobmanager.infra.svc.cluster.local:8081"

    echo "  Kafka UI:         http://localhost:8080"    echo ""

    echo "  phpMyAdmin:       http://localhost:8081 (用户: root)"    echo "🌐 外部访问 (端口转发):"

    echo "  Redis Commander:  http://localhost:8082"    echo "  # 启动端口转发"

    echo "  Flink Web UI:     http://localhost:8083"    echo "  kubectl port-forward -n infra svc/kafka-ui 8080:8080 &"

    echo ""    echo "  kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &"

    echo "📡 一键启动所有端口转发:"    echo "  kubectl port-forward -n infra svc/redis-commander 8082:8082 &"

    echo "  $0 port-forward"    echo "  kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &"

}    echo ""

    echo "  # 访问地址"

start_port_forward() {    echo "  Kafka UI:         http://localhost:8080"

    echo "📡 启动端口转发..."    echo "  phpMyAdmin:       http://localhost:8081 (用户: root)"

        echo "  Redis Commander:  http://localhost:8082"

    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then    echo "  Flink Web UI:     http://localhost:8083"

        echo "❌ 基础设施平台未部署，请先运行: $0 deploy"    echo ""

        return 1    echo "📡 一键启动所有端口转发:"

    fi    echo "  $0 port-forward"

    }

    echo "🔗 启动所有服务的端口转发..."

    start_port_forward() {

    # 后台启动端口转发    echo "📡 启动端口转发..."

    kubectl port-forward -n infra svc/kafka-ui 8080:8080 &    

    KAFKA_UI_PID=$!    if ! kubectl get namespace infra 2>/dev/null | grep -q "Active"; then

            echo "❌ 数据平台未部署，请先运行: $0 deploy"

    kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &        return 1

    PHPMYADMIN_PID=$!    fi

        

    kubectl port-forward -n infra svc/redis-commander 8082:8082 &    echo "🔗 启动所有服务的端口转发..."

    REDIS_CMD_PID=$!    

        # 后台启动端口转发

    kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &    kubectl port-forward -n infra svc/kafka-ui 8080:8080 &

    FLINK_UI_PID=$!    KAFKA_UI_PID=$!

        

    sleep 3    kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &

        PHPMYADMIN_PID=$!

    echo "✅ 端口转发已启动:"    

    echo "  Kafka UI:         http://localhost:8080 (PID: $KAFKA_UI_PID)"    kubectl port-forward -n infra svc/redis-commander 8082:8082 &

    echo "  phpMyAdmin:       http://localhost:8081 (PID: $PHPMYADMIN_PID)"    REDIS_CMD_PID=$!

    echo "  Redis Commander:  http://localhost:8082 (PID: $REDIS_CMD_PID)"    

    echo "  Flink Web UI:     http://localhost:8083 (PID: $FLINK_UI_PID)"    kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &

    echo ""    FLINK_UI_PID=$!

    echo "🛑 停止端口转发: kill $KAFKA_UI_PID $PHPMYADMIN_PID $REDIS_CMD_PID $FLINK_UI_PID"    

}    sleep 3

    

main() {    echo "✅ 端口转发已启动:"

    case "${1:-help}" in    echo "  Kafka UI:         http://localhost:8080 (PID: $KAFKA_UI_PID)"

        "deploy"|"up")    echo "  phpMyAdmin:       http://localhost:8081 (PID: $PHPMYADMIN_PID)"

            deploy_platform    echo "  Redis Commander:  http://localhost:8082 (PID: $REDIS_CMD_PID)"

            ;;    echo "  Flink Web UI:     http://localhost:8083 (PID: $FLINK_UI_PID)"

        "start")    echo ""

            start_services    echo "🛑 停止端口转发: kill $KAFKA_UI_PID $PHPMYADMIN_PID $REDIS_CMD_PID $FLINK_UI_PID"

            ;;}

        "stop")

            stop_servicesmain() {

            ;;    case "${1:-help}" in

        "cleanup"|"clean")        "deploy"|"up")

            cleanup_platform            deploy_platform

            ;;            ;;

        "status")        "start")

            show_status            start_services

            ;;            ;;

        "info"|"platform-info")        "stop")

            show_platform_info            stop_services

            ;;            ;;

        "connection"|"conn")        "cleanup"|"clean")

            get_connection_info            cleanup_platform

            ;;            ;;

        "port-forward"|"pf")        "status")

            start_port_forward            show_status

            ;;            ;;

        "help"|*)        "info"|"platform-info")

            echo "🏗️ Kubernetes 基础设施平台管理工具"            show_platform_info

            echo "============================="            ;;

            echo ""        "connection"|"conn")

            echo "使用方法: $0 <command>"            get_connection_info

            echo ""            ;;

            echo "🏗️ 平台管理:"        "port-forward"|"pf")

            echo "  deploy|up       - 部署完整基础设施平台"            start_port_forward

            echo "  start           - 启动已部署的服务"            ;;

            echo "  stop            - 停止服务 (保留数据)"        "help"|*)

            echo "  cleanup|clean   - 清理所有资源"            echo "� Kubernetes 数据平台管理工具"

            echo "  status          - 查看平台状态"            echo "============================="

            echo ""            echo ""

            echo "🔗 连接访问:"            echo "使用方法: $0 <command>"

            echo "  connection|conn - 查看服务连接信息"            echo ""

            echo "  port-forward|pf - 启动端口转发"            echo "🏗️ 平台管理:"

            echo "  info            - 查看平台架构信息"            echo "  deploy|up       - 部署完整数据平台"

            echo ""            echo "  start           - 启动已部署的服务"

            echo "💡 推荐工作流:"            echo "  stop            - 停止服务 (保留数据)"

            echo "  1. 首次部署: $0 deploy"            echo "  cleanup|clean   - 清理所有资源"

            echo "  2. 查看状态: $0 status"            echo "  status          - 查看平台状态"

            echo "  3. 访问服务: $0 port-forward"            echo ""

            echo "  4. 获取连接: $0 connection"            echo "🔗 连接访问:"

            echo ""            echo "  connection|conn - 查看服务连接信息"

            echo "🔧 高级操作:"            echo "  port-forward|pf - 启动端口转发"

            echo "  ./flink/deploy.sh [command] - 详细部署控制"            echo "  info            - 查看平台架构信息"

            ;;            echo ""

    esac            echo "💡 推荐工作流:"

}            echo "  1. 首次部署: $0 deploy"

            echo "  2. 查看状态: $0 status"

main "$@"            echo "  3. 访问服务: $0 port-forward"
            echo "  4. 获取连接: $0 connection"
            echo ""
            echo "🔧 高级操作:"
            echo "  ./flink/deploy.sh [command] - 详细部署控制"
            ;;
    esac
}

main "$@"