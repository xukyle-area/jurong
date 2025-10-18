#!/bin/bash

# AWS EMR on EKS + Flink 管理脚本

echo "🔧 EMR on EKS + Flink 集群管理"
echo "=========================="

# 获取集群状态
get_cluster_status() {
    echo "📊 集群状态概览:"
    echo "==============="
    
    echo "🏗️ 基础设施 (data-platform namespace):"
    kubectl get pods,svc -n data-platform
    
    echo ""
    echo "🌊 Flink 集群 (emr namespace):"
    kubectl get flinkdeployment,pods,svc -n emr
    
    echo ""
    echo "📋 EMR 虚拟集群:"
    aws emr-containers list-virtual-clusters --query 'virtualClusters[*].[name,id,state]' --output table
}

# 管理 Flink 作业
manage_flink_jobs() {
    case "$1" in
        "list")
            echo "📋 Flink 作业列表:"
            kubectl exec -n emr deployment/flink-session-emr-jobmanager -- flink list
            ;;
        "submit")
            if [ -z "$2" ]; then
                echo "❌ 请指定作业 JAR 文件"
                echo "用法: $0 jobs submit <jar-file>"
                exit 1
            fi
            
            echo "🚀 提交 Flink 作业: $2"
            kubectl exec -n emr deployment/flink-session-emr-jobmanager -- flink run "$2"
            ;;
        "cancel")
            if [ -z "$2" ]; then
                echo "❌ 请指定作业 ID"
                echo "用法: $0 jobs cancel <job-id>"
                exit 1
            fi
            
            echo "🛑 取消 Flink 作业: $2"
            kubectl exec -n emr deployment/flink-session-emr-jobmanager -- flink cancel "$2"
            ;;
        *)
            echo "Flink 作业管理命令:"
            echo "  list    - 列出运行中的作业"
            echo "  submit  - 提交新作业"
            echo "  cancel  - 取消指定作业"
            ;;
    esac
}

# 查看日志
view_logs() {
    case "$1" in
        "flink-jm")
            echo "📋 Flink JobManager 日志:"
            kubectl logs -n emr deployment/flink-session-emr-jobmanager -f
            ;;
        "flink-tm")
            echo "📋 Flink TaskManager 日志:"
            kubectl logs -n emr -l app=flink-session-emr,component=taskmanager -f
            ;;
        "kafka")
            echo "📋 Kafka 日志:"
            kubectl logs -n data-platform -l app.kubernetes.io/name=kafka -f
            ;;
        "mysql")
            echo "📋 MySQL 日志:"
            kubectl logs -n data-platform deployment/mysql -f
            ;;
        *)
            echo "可用的日志查看选项:"
            echo "  flink-jm  - Flink JobManager"
            echo "  flink-tm  - Flink TaskManager"
            echo "  kafka     - Kafka 集群"
            echo "  mysql     - MySQL 数据库"
            ;;
    esac
}

# 端口转发
port_forward() {
    case "$1" in
        "flink")
            echo "🌐 启动 Flink Web UI 端口转发..."
            kubectl port-forward -n emr svc/flink-session-emr-rest 8081:8081
            ;;
        "kafka")
            echo "🌐 启动 Kafka 端口转发..."
            kubectl port-forward -n data-platform svc/kafka-cluster-kafka-bootstrap 9092:9092
            ;;
        "mysql")
            echo "🌐 启动 MySQL 端口转发..."
            kubectl port-forward -n data-platform svc/mysql 3306:3306
            ;;
        *)
            echo "可用的端口转发选项:"
            echo "  flink  - Flink Web UI (8081)"
            echo "  kafka  - Kafka Bootstrap (9092)"
            echo "  mysql  - MySQL (3306)"
            ;;
    esac
}

# 扩容/缩容
scale_cluster() {
    case "$1" in
        "flink-tm")
            if [ -z "$2" ]; then
                echo "❌ 请指定 TaskManager 副本数"
                echo "用法: $0 scale flink-tm <replicas>"
                exit 1
            fi
            
            echo "📈 扩容 Flink TaskManager 到 $2 个副本..."
            kubectl patch flinkdeployment flink-session-emr -n emr -p "{\"spec\":{\"taskManager\":{\"replicas\":$2}}}" --type=merge
            ;;
        "kafka")
            if [ -z "$2" ]; then
                echo "❌ 请指定 Kafka 副本数"
                echo "用法: $0 scale kafka <replicas>"
                exit 1
            fi
            
            echo "📈 扩容 Kafka 集群到 $2 个副本..."
            kubectl patch kafka kafka-cluster -n data-platform -p "{\"spec\":{\"kafka\":{\"replicas\":$2}}}" --type=merge
            ;;
        *)
            echo "可用的扩容选项:"
            echo "  flink-tm  - Flink TaskManager"
            echo "  kafka     - Kafka 集群"
            ;;
    esac
}

# 主菜单
main() {
    case "${1:-help}" in
        "status")
            get_cluster_status
            ;;
        "jobs")
            manage_flink_jobs "$2" "$3"
            ;;
        "logs")
            view_logs "$2"
            ;;
        "forward")
            port_forward "$2"
            ;;
        "scale")
            scale_cluster "$2" "$3"
            ;;
        "help"|*)
            echo "🔧 EMR on EKS + Flink 集群管理命令:"
            echo "================================"
            echo "$0 status                     - 查看集群状态"
            echo "$0 jobs [list|submit|cancel]  - 管理 Flink 作业"
            echo "$0 logs [flink-jm|flink-tm|kafka|mysql] - 查看日志"
            echo "$0 forward [flink|kafka|mysql] - 端口转发"
            echo "$0 scale [flink-tm|kafka] <replicas> - 扩容/缩容"
            echo ""
            echo "🌐 Web UI 访问 (需要端口转发):"
            echo "  Flink UI: $0 forward flink → http://localhost:8081"
            echo ""
            echo "💡 快速访问:"
            echo "  kubectl get flinkdeployment -n emr"
            echo "  kubectl get pods -n data-platform"
            ;;
    esac
}

main "$@"