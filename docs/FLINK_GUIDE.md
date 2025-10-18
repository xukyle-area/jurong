# Flink + Kafka 集成指南

## 🌊 Flink 实时流处理架构

```
Kafka (数据源) → Flink (流处理) → MySQL/Redis (数据存储)
```

## 📋 服务访问信息

- **Flink Dashboard**: http://localhost:8083
- **Kafka Broker**: kafka:9092 (容器内) / localhost:9092 (外部)
- **MySQL**: mysql:3306 (容器内) / localhost:3306 (外部)  
- **Redis**: redis:6379 (容器内) / localhost:6379 (外部)

## 🔧 Flink Job 开发示例

### 1. Maven 依赖
```xml
<dependencies>
    <dependency>
        <groupId>org.apache.flink</groupId>
        <artifactId>flink-streaming-java</artifactId>
        <version>1.17.2</version>
    </dependency>
    <dependency>
        <groupId>org.apache.flink</groupId>
        <artifactId>flink-connector-kafka</artifactId>
        <version>1.17.2</version>
    </dependency>
    <dependency>
        <groupId>org.apache.flink</groupId>
        <artifactId>flink-connector-jdbc</artifactId>
        <version>3.1.0-1.17</version>
    </dependency>
</dependencies>
```

### 2. Kafka 消费者示例
```java
// Kafka Source
FlinkKafkaConsumer<String> consumer = new FlinkKafkaConsumer<>(
    "user-events",  // topic
    new SimpleStringSchema(),
    properties);

DataStream<String> stream = env.addSource(consumer);
```

### 3. 数据处理和输出
```java
// 处理数据并写入 MySQL
stream.map(new MapFunction<String, UserEvent>() {
    @Override
    public UserEvent map(String value) throws Exception {
        // 解析 JSON 或其他格式
        return parseUserEvent(value);
    }
}).addSink(JdbcSink.sink(
    "INSERT INTO user_activities (user_id, activity_type, activity_data) VALUES (?, ?, ?)",
    (statement, event) -> {
        statement.setInt(1, event.getUserId());
        statement.setString(2, event.getActivityType());
        statement.setString(3, event.getActivityData());
    },
    JdbcExecutionOptions.builder()
        .withBatchSize(1000)
        .withBatchIntervalMs(200)
        .build(),
    new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
        .withUrl("jdbc:mysql://mysql:3306/projects")
        .withDriverName("com.mysql.cj.jdbc.Driver")
        .withUsername("appuser")
        .withPassword("apppassword")
        .build()));
```

## 🚀 作业提交流程

1. **打包作业**: `mvn clean package`
2. **上传 JAR**: 通过 Flink Web UI 或 REST API
3. **提交作业**: 配置参数并启动
4. **监控作业**: 通过 Dashboard 查看状态

## 📊 常用 Flink SQL

```sql
-- 创建 Kafka 源表
CREATE TABLE user_events (
    user_id INT,
    activity_type STRING,
    activity_data STRING,
    event_time TIMESTAMP(3) METADATA FROM 'timestamp'
) WITH (
    'connector' = 'kafka',
    'topic' = 'user-events',
    'properties.bootstrap.servers' = 'kafka:9092',
    'format' = 'json'
);

-- 实时聚合查询
SELECT 
    user_id,
    COUNT(*) as activity_count,
    TUMBLE_END(event_time, INTERVAL '1' MINUTE) as window_end
FROM user_events
GROUP BY user_id, TUMBLE(event_time, INTERVAL '1' MINUTE);
```

## 🎯 典型应用场景

1. **实时ETL**: Kafka → Flink → MySQL
2. **实时聚合**: 计算用户活跃度、订单统计等
3. **异常检测**: 实时监控异常模式
4. **实时推荐**: 基于用户行为的实时推荐