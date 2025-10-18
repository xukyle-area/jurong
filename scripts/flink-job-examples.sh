#!/bin/bash

# Flink Session 集群作业提交示例
# 当前 Flink 集群地址: http://localhost:8083

echo "🌊 Flink Session 集群作业管理"
echo "==============================="

FLINK_JOBMANAGER="localhost:8083"

# 1. 检查集群状态
check_cluster() {
    echo "📊 检查集群状态..."
    curl -s http://${FLINK_JOBMANAGER}/overview | \
        sed 's/,/,\n  /g' | sed 's/{/{\n  /' | sed 's/}/\n}/'
}

# 2. 列出所有作业
list_jobs() {
    echo "📋 当前作业列表..."
    curl -s http://${FLINK_JOBMANAGER}/jobs
}

# 3. 提交示例作业（WordCount）
submit_wordcount_example() {
    echo "📝 提交 WordCount 示例作业..."
    echo "注意：需要先上传 WordCount JAR 文件"
    
    # 这是一个示例命令，实际使用时需要替换为真实的 JAR 文件
    echo "步骤："
    echo "1. 访问 http://localhost:8083"
    echo "2. 点击 'Submit New Job'"
    echo "3. 上传 flink-examples-streaming_2.12-1.17.2.jar"
    echo "4. 选择 'org.apache.flink.streaming.examples.wordcount.WordCount'"
    echo "5. 设置参数：--input /path/to/input --output /path/to/output"
}

# 4. 创建简单的流作业示例（通过 SQL）
create_sql_job_example() {
    echo "💻 创建 SQL 流作业示例..."
    cat << 'EOF'
-- 创建一个简单的数据生成器表
CREATE TABLE datagen_source (
    id INT,
    name STRING,
    age INT,
    ts TIMESTAMP(3),
    WATERMARK FOR ts AS ts - INTERVAL '1' SECOND
) WITH (
    'connector' = 'datagen',
    'rows-per-second' = '10'
);

-- 创建 Kafka 输出表
CREATE TABLE kafka_sink (
    id INT,
    name STRING,
    age INT,
    ts TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'user-events',
    'properties.bootstrap.servers' = 'kafka:9092',
    'format' = 'json'
);

-- 插入数据到 Kafka
INSERT INTO kafka_sink
SELECT id, name, age, ts
FROM datagen_source;
EOF
}

# 5. 监控作业状态
monitor_job() {
    local job_id=$1
    if [ -z "$job_id" ]; then
        echo "❌ 请提供作业 ID"
        echo "用法: monitor_job <job_id>"
        return 1
    fi
    
    echo "📈 监控作业: $job_id"
    curl -s http://${FLINK_JOBMANAGER}/jobs/${job_id}
}

# 6. 取消作业
cancel_job() {
    local job_id=$1
    if [ -z "$job_id" ]; then
        echo "❌ 请提供作业 ID"
        echo "用法: cancel_job <job_id>"
        return 1
    fi
    
    echo "🛑 取消作业: $job_id"
    curl -X PATCH http://${FLINK_JOBMANAGER}/jobs/${job_id}?mode=cancel
}

# 7. 获取 TaskManager 信息
get_taskmanagers() {
    echo "🖥️  TaskManager 信息..."
    curl -s http://${FLINK_JOBMANAGER}/taskmanagers | \
        python3 -m json.tool 2>/dev/null || \
        curl -s http://${FLINK_JOBMANAGER}/taskmanagers
}

# 主菜单
case "${1:-help}" in
    "status"|"cluster")
        check_cluster
        ;;
    "jobs")
        list_jobs
        ;;
    "taskmanagers"|"tm")
        get_taskmanagers
        ;;
    "wordcount")
        submit_wordcount_example
        ;;
    "sql")
        create_sql_job_example
        ;;
    "monitor")
        monitor_job "$2"
        ;;
    "cancel")
        cancel_job "$2"
        ;;
    "help"|*)
        echo "🌊 Flink Session 集群管理工具"
        echo "=============================="
        echo ""
        echo "使用方法: $0 <command> [args]"
        echo ""
        echo "命令:"
        echo "  status     - 检查集群状态"
        echo "  jobs       - 列出所有作业"
        echo "  taskmanagers - 查看 TaskManager 信息"
        echo "  wordcount  - WordCount 示例提交指南"
        echo "  sql        - SQL 流作业示例"
        echo "  monitor <job_id> - 监控指定作业"
        echo "  cancel <job_id>  - 取消指定作业"
        echo ""
        echo "🌐 Web UI: http://localhost:8083"
        echo "📊 REST API: http://localhost:8083/api/"
        echo ""
        echo "📝 当前集群配置:"
        echo "  - TaskManager: 2 个"
        echo "  - 任务槽: 4 个 (每个 TaskManager 2个)"
        echo "  - 并行度: 1 (默认)"
        ;;
esac