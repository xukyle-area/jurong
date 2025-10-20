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
        "cassandra:3.11.16"
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

# 初始化 Cassandra Keyspace 和表
init_cassandra() {
    echo "🗄️ 初始化 Cassandra..."
    
    # 等待 Cassandra Pod 启动
    echo "等待 Cassandra Pod 启动..."
    kubectl wait --for=condition=ready pod -l app=cassandra -n infra --timeout=300s || {
        echo "❌ Cassandra Pod 启动超时"
        return 1
    }
    
    # 等待 Cassandra 服务就绪
    echo "等待 Cassandra 服务就绪..."
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "尝试连接 Cassandra (第 $attempt/$max_attempts 次)..."
        if kubectl exec -n infra statefulset/cassandra -- timeout 10 cqlsh -e "SELECT now() FROM system.local;" > /dev/null 2>&1; then
            echo "✅ Cassandra 连接成功"
            break
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            echo "❌ Cassandra 连接失败，请检查日志: kubectl logs -n infra cassandra-0"
            return 1
        fi
        
        sleep 10
        attempt=$((attempt + 1))
    done
    
    # 创建 keyspace 和表
    kubectl exec -n infra statefulset/cassandra -- cqlsh -e "
    CREATE KEYSPACE IF NOT EXISTS jurong_keyspace 
    WITH REPLICATION = {
        'class' : 'SimpleStrategy',
        'replication_factor' : 1
    };
    
    USE jurong_keyspace;
    
    CREATE TABLE IF NOT EXISTS users (
        user_id UUID PRIMARY KEY,
        username TEXT,
        email TEXT,
        created_at TIMESTAMP,
        updated_at TIMESTAMP
    );
    
    CREATE TABLE IF NOT EXISTS events (
        event_id UUID,
        user_id UUID,
        event_type TEXT,
        event_data TEXT,
        timestamp TIMESTAMP,
        PRIMARY KEY (event_id, timestamp)
    ) WITH CLUSTERING ORDER BY (timestamp DESC);
    
    INSERT INTO users (user_id, username, email, created_at, updated_at) 
    VALUES (uuid(), 'admin', 'admin@jurong.com', toTimestamp(now()), toTimestamp(now()));
    "
    
    echo "📋 Cassandra Keyspace 信息:"
    kubectl exec -n infra statefulset/cassandra -- cqlsh -e "DESCRIBE KEYSPACES;"
    
    echo "📋 Cassandra 表信息:"
    kubectl exec -n infra statefulset/cassandra -- cqlsh -e "USE jurong_keyspace; DESCRIBE TABLES;"
    
    echo "✅ Cassandra 初始化完成"
}

# 获取服务访问信息
get_service_info() {
    echo "🌐 服务访问信息:"
    echo "=============="
    
    echo "📊 外部访问地址 (LoadBalancer):"
    
    # 获取 LoadBalancer 外部 IP
    echo "Kafka UI:"
    kubectl get svc kafka-ui -n infra -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "phpMyAdmin:"
    kubectl get svc phpmyadmin -n infra -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "Redis Commander:"
    kubectl get svc redis-commander -n infra -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "Flink Web UI:"
    kubectl get svc flink-jobmanager-ui -n infra -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "  等待外部 IP 分配..."
    echo ""
    
    echo "📡 端口转发命令 (本地访问):"
    echo "kubectl port-forward -n infra svc/kafka-ui 8080:8080"
    echo "kubectl port-forward -n infra svc/phpmyadmin 8081:8081"
    echo "kubectl port-forward -n infra svc/redis-commander 8082:8082"
    echo "kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083"
    echo "kubectl port-forward -n infra svc/kafka-external 9092:9092"
    echo "kubectl port-forward -n infra svc/mysql-external 3306:3306"
    echo "kubectl port-forward -n infra svc/redis-external 6379:6379"
    echo "kubectl port-forward -n infra svc/cassandra-service 9042:9042"
}

# 验证部署
verify_deployment() {
    echo "🔍 验证部署状态..."
    
    echo "📊 所有 Pod 状态:"
    kubectl get pods -n infra
    
    echo ""
    echo "📊 所有服务状态:"
    kubectl get svc -n infra
    
    echo ""
    echo "📊 存储状态:"
    kubectl get pvc -n infra
    
    echo ""
    echo "🏥 健康检查:"
    
    # 检查关键服务健康状态
    echo "MySQL 连接测试:"
    if kubectl exec -n infra deployment/mysql -- mysqladmin ping -h localhost --silent; then
        echo "✅ MySQL 健康"
    else
        echo "❌ MySQL 不健康"
    fi
    
    echo "Redis 连接测试:"
    if kubectl exec -n infra deployment/redis -- redis-cli -a redispassword ping; then
        echo "✅ Redis 健康"
    else
        echo "❌ Redis 不健康"
    fi
    
    echo "Kafka 连接测试:"
    if kubectl exec -n infra statefulset/kafka -- kafka-topics --bootstrap-server localhost:9092 --list > /dev/null; then
        echo "✅ Kafka 健康"
    else
        echo "❌ Kafka 不健康"
    fi
    
    echo "Cassandra 连接测试:"
    # 检查 Cassandra Pod 是否存在和Running
    if kubectl get pod -n infra -l app=cassandra | grep -q Running; then
        # 尝试连接 Cassandra，使用更简单的测试
        if kubectl exec -n infra statefulset/cassandra -- timeout 10 cqlsh -e "SELECT now() FROM system.local;" > /dev/null 2>&1; then
            echo "✅ Cassandra 健康"
        else
            echo "⚠️  Cassandra Pod 运行中，但 CQL 连接未就绪 (可能仍在启动中)"
            echo "   请等待几分钟后重新检查，或运行: kubectl logs -n infra cassandra-0"
        fi
    else
        echo "❌ Cassandra Pod 未运行"
        echo "   检查 Pod 状态: kubectl get pods -n infra -l app=cassandra"
    fi
}

# 清理部署
cleanup() {
    echo "🧹 清理所有资源..."
    
    read -p "确定要删除所有资源吗? (y/N): " confirm
    if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        kubectl delete namespace infra
        echo "✅ 清理完成"
    else
        echo "❌ 清理已取消"
    fi
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
            init_cassandra
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
        "cassandra")
            init_cassandra
            ;;
        "cassandra-status")
            echo "🔍 Cassandra 详细状态检查..."
            echo "Pod 状态:"
            kubectl get pods -n infra -l app=cassandra
            echo ""
            echo "Pod 日志 (最后 20 行):"
            kubectl logs -n infra cassandra-0 --tail=20 || echo "无法获取日志"
            echo ""
            echo "尝试 CQL 连接:"
            kubectl exec -n infra statefulset/cassandra -- timeout 15 cqlsh -e "SELECT now() FROM system.local; DESCRIBE KEYSPACES;" || echo "CQL 连接失败"
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
            echo "  cassandra      - 初始化 Cassandra Keyspace 和表"
            echo "  cassandra-status - 检查 Cassandra 详细状态和日志"
            echo "  status         - 查看部署状态"
            echo "  info           - 查看服务访问信息"
            echo "  cleanup        - 清理所有资源"
            echo "  mysql-restart  - 重启 MySQL 并执行 mysql-init/*.sql 文件"
            echo ""
            echo "📊 基础设施服务栈:"
            echo "  - 消息队列: Kafka + ZooKeeper + Kafka UI"
            echo "  - 关系数据库: MySQL + phpMyAdmin"
            echo "  - NoSQL 数据库: Cassandra"
            echo "  - 缓存: Redis + Redis Commander"
            echo "  - 流计算: Apache Flink (JobManager + TaskManager)"
            echo ""
            echo "🌐 外部访问通过 LoadBalancer 或端口转发"
            ;;
    esac
}

main "$@"