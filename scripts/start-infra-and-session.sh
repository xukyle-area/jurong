#!/bin/bash

# 完整基础设施平台 Kubernetes 部署脚本
# 包含消息队列、数据库、缓存、流计算等完整基础设施服务

set -e

echo "🚀 部署完整基础设施平台到 Kubernetes"  
echo "=============================="

# 检查必要工具
check_prerequisites() {
    echo "🔍 检查前置条件..."
    
    for tool in kubectl docker; do
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

# 预拉取所有镜像
pull_images() {
    echo "📥 预拉取所有镜像..."
    
    # 定义所有需要的镜像
    images=(
        "confluentinc/cp-zookeeper:7.4.0"
        "confluentinc/cp-kafka:7.4.0"
        "provectuslabs/kafka-ui:latest"
        "mysql:8.0"
        "phpmyadmin/phpmyadmin:latest"
        "redis:7-alpine"
        "rediscommander/redis-commander:latest"
        "flink:1.17"
    )
    
    for image in "${images[@]}"; do
        echo "正在拉取镜像: $image"
        if docker pull "$image"; then
            echo "✅ $image 拉取成功"
        else
            echo "❌ $image 拉取失败，将在部署时重试"
        fi
    done
    
    echo "✅ 镜像预拉取完成"
}

# 创建命名空间
create_namespace() {
    echo "📦 创建命名空间..."
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: infra
  labels:
    name: infra
EOF
    echo "✅ 命名空间创建完成"
}

# 部署基础设施服务
deploy_infrastructure() {
    echo "🏗️ 部署基础设施服务..."
    
    # 获取脚本所在目录的绝对路径
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    echo "部署基础设施服务: MySQL, Redis, ZooKeeper, Kafka, 管理界面..."
    kubectl apply -f "$PROJECT_ROOT/manifests/infra-deployment.yaml"
    
    echo "⏳ 等待基础设施服务启动..."
    
    # 等待 MySQL
    echo "等待 MySQL..."
    kubectl wait --for=condition=available --timeout=300s deployment/mysql -n infra
    
    # 等待 Redis
    echo "等待 Redis..."
    kubectl wait --for=condition=available --timeout=300s deployment/redis -n infra
    
    # 等待 ZooKeeper
    echo "等待 ZooKeeper..."
    kubectl wait --for=condition=ready --timeout=300s pod -l app=zookeeper -n infra
    
    # 等待 Kafka
    echo "等待 Kafka..."
    kubectl wait --for=condition=ready --timeout=600s pod -l app=kafka -n infra
    
    # 等待 UI 服务
    echo "等待 UI 服务..."
    kubectl wait --for=condition=available --timeout=300s deployment/kafka-ui -n infra
    kubectl wait --for=condition=available --timeout=300s deployment/phpmyadmin -n infra
    kubectl wait --for=condition=available --timeout=300s deployment/redis-commander -n infra
    
    echo "✅ 基础设施服务部署完成"
}

# 部署流计算服务
deploy_flink() {
    echo "🌊 部署流计算服务 (Apache Flink)..."
    
    # 获取脚本所在目录的绝对路径
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    
    kubectl apply -f "$PROJECT_ROOT/manifests/flink-session-deployment.yaml"
    
    echo "⏳ 等待流计算服务启动..."
    
    # 等待 JobManager
    kubectl wait --for=condition=available --timeout=300s deployment/flink-jobmanager -n infra
    
    # 等待 TaskManager
    kubectl wait --for=condition=available --timeout=300s deployment/flink-taskmanager -n infra
    
    echo "✅ 流计算服务部署完成"
}

# 创建 Kafka 主题
create_kafka_topics() {
    echo "📨 创建 Kafka 主题..."
    
    # 等待 Kafka 完全启动
    sleep 30
    
    # 创建主题
    kubectl exec -n infra statefulset/kafka -- kafka-topics --create --bootstrap-server localhost:9092 --topic calculate-input --partitions 3 --replication-factor 1 --if-not-exists
    kubectl exec -n infra statefulset/kafka -- kafka-topics --create --bootstrap-server localhost:9092 --topic calculate-output --partitions 2 --replication-factor 1 --if-not-exists
    
    echo "📋 Kafka 主题列表:"
    kubectl exec -n infra statefulset/kafka -- kafka-topics --list --bootstrap-server localhost:9092
    
    echo "✅ Kafka 主题创建完成"
}

# 重启 MySQL 并执行 SQL 文件
restart_mysql_and_execute_sql() {
    echo "🔄 重启 MySQL 并执行 SQL 文件..."
    
    # 获取脚本所在目录的绝对路径
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    SQL_DIR="$PROJECT_ROOT/mysql-init"
    
    # 检查 SQL 目录是否存在
    if [ ! -d "$SQL_DIR" ]; then
        echo "❌ SQL 初始化目录不存在: $SQL_DIR"
        return 1
    fi
    
    # 检查是否有 SQL 文件
    sql_files=("$SQL_DIR"/*.sql)
    if [ ! -f "${sql_files[0]}" ]; then
        echo "❌ 在 $SQL_DIR 中未找到 .sql 文件"
        return 1
    fi
    
    echo "📁 发现以下 SQL 文件:"
    for file in "${sql_files[@]}"; do
        if [ -f "$file" ]; then
            echo "   - $(basename "$file")"
        fi
    done
    
    # 删除现有的 MySQL Pod
    echo "🗑️ 删除现有的 MySQL Pod..."
    kubectl delete pod -n infra -l app=mysql --ignore-not-found=true
    
    # 等待新的 MySQL Pod 启动并就绪
    echo "⏳ 等待新的 MySQL Pod 启动..."
    kubectl wait --for=condition=ready pod -l app=mysql -n infra --timeout=120s
    
    if [ $? -eq 0 ]; then
        echo "✅ MySQL Pod 已就绪"
        
        # 获取 MySQL Pod 名称
        mysql_pod=$(kubectl get pods -n infra -l app=mysql --field-selector=status.phase=Running -o jsonpath='{.items[0].metadata.name}')
        
        if [ -z "$mysql_pod" ]; then
            echo "❌ 无法找到运行中的 MySQL Pod"
            return 1
        fi
        
        echo "🎯 目标 MySQL Pod: $mysql_pod"
        
        # 等待 MySQL 服务完全启动
        echo "⏳ 等待 MySQL 服务完全启动..."
        sleep 10
        
        # 删除现有的 raffles 数据库（如果存在）
        echo "🗑️ 删除现有的 raffles 数据库..."
        kubectl exec -n infra -it "$mysql_pod" -- mysql -u root -prootpassword -e "DROP DATABASE IF EXISTS raffles;" 2>/dev/null || true
        
        # 执行所有 SQL 文件
        for sql_file in "${sql_files[@]}"; do
            if [ -f "$sql_file" ]; then
                echo "📝 执行 SQL 文件: $(basename "$sql_file")"
                
                if kubectl exec -n infra -i "$mysql_pod" -- mysql -u root -prootpassword < "$sql_file"; then
                    echo "✅ $(basename "$sql_file") 执行成功"
                else
                    echo "❌ $(basename "$sql_file") 执行失败"
                    return 1
                fi
            fi
        done
        
        # 验证数据库和表是否创建成功
        echo "🔍 验证数据库和表..."
        echo "数据库列表:"
        kubectl exec -n infra -it "$mysql_pod" -- mysql -u root -prootpassword -e "SHOW DATABASES;" 2>/dev/null | grep -v "Warning"
        
        echo ""
        echo "raffles 数据库中的表:"
        kubectl exec -n infra -it "$mysql_pod" -- mysql -u root -prootpassword -D raffles -e "SHOW TABLES;" 2>/dev/null | grep -v "Warning"
        
        echo ""
        echo "✅ MySQL 重启并 SQL 执行完成!"
        
    else
        echo "❌ MySQL Pod 启动超时"
        return 1
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
        "streaming"|"flink")
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
        "mysql-restart")
            restart_mysql_and_execute_sql
            ;;
        "help"|*)
            echo "🚀 Kubernetes 基础设施平台部署工具"
            echo "============================="
            echo ""
            echo "使用方法: $0 <command>"
            echo ""
            echo "命令:"
            echo "  deploy         - 完整部署基础设施平台 (推荐)"
            echo "  infrastructure - 仅部署基础设施 (数据库、消息队列、缓存)"
            echo "  streaming      - 仅部署流计算服务 (Apache Flink)"
            echo "  topics         - 创建 Kafka 主题"
            echo "  status         - 查看部署状态"
            echo "  info           - 查看服务访问信息"
            echo "  cleanup        - 清理所有资源"
            echo "  mysql-restart  - 重启 MySQL 并执行 mysql-init/*.sql 文件"
            echo ""
            echo "📊 基础设施服务栈:"
            echo "  - 消息队列: Kafka + ZooKeeper + Kafka UI"
            echo "  - 关系数据库: MySQL + phpMyAdmin"
            echo "  - NoSQL 数据库"
            echo "  - 缓存: Redis + Redis Commander"
            echo "  - 流计算: Apache Flink (JobManager + TaskManager)"
            echo ""
            echo "🌐 外部访问通过 LoadBalancer 或端口转发"
            ;;
    esac
}

main "$@"