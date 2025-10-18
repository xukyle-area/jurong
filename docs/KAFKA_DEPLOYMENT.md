# Kafka 部署指南

在你的 Docker Desktop 环境下，我为你提供了两种部署 Kafka 的方案：

## 方案 1：使用 Docker Compose（推荐）

这是最简单的方案，适合本地开发和测试：

### 启动服务
```bash
docker-compose up -d
```

### 服务说明
- **ZooKeeper**: 端口 2181
- **Kafka**: 端口 9092
- **Kafka UI**: 端口 8080 (可视化管理界面)

### 访问 Kafka UI
启动后，打开浏览器访问：http://localhost:8080

### 停止服务
```bash
docker-compose down
```

### 清理数据（可选）
```bash
docker-compose down -v
```

## 方案 2：使用 Kubernetes

如果你需要在 Kubernetes 环境中部署：

### 1. 确保 Kubernetes 集群运行
```bash
kubectl cluster-info
```

### 2. 创建命名空间
```bash
kubectl apply -f deployments/namespace.yaml
```

### 3. 部署 ZooKeeper
```bash
kubectl apply -f deployments/zookeeper-deployment.yaml
```

### 4. 部署 Kafka
```bash
kubectl apply -f deployments/kafka-deployment.yaml
```

### 5. 查看服务状态
```bash
kubectl get pods -n infra
kubectl get services -n infra
```

### 6. 端口转发（用于本地访问）
```bash
kubectl port-forward -n infra service/kafka 9092:9092
```

## Kafka 基本使用

### 创建 Topic
```bash
# Docker Compose 方式
docker exec -it kafka kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# Kubernetes 方式
kubectl exec -n infra -it deployment/kafka -- kafka-topics.sh --create --topic test-topic --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
```

### 查看 Topics
```bash
# Docker Compose 方式
docker exec -it kafka kafka-topics.sh --list --bootstrap-server localhost:9092

# Kubernetes 方式
kubectl exec -n infra -it deployment/kafka -- kafka-topics.sh --list --bootstrap-server localhost:9092
```

### 生产消息
```bash
# Docker Compose 方式
docker exec -it kafka kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092

# Kubernetes 方式
kubectl exec -n infra -it deployment/kafka -- kafka-console-producer.sh --topic test-topic --bootstrap-server localhost:9092
```

### 消费消息
```bash
# Docker Compose 方式
docker exec -it kafka kafka-console-consumer.sh --topic test-topic --from-beginning --bootstrap-server localhost:9092

# Kubernetes 方式
kubectl exec -n infra -it deployment/kafka -- kafka-console-consumer.sh --topic test-topic --from-beginning --bootstrap-server localhost:9092
```

## 故障排除

### 查看日志
```bash
# Docker Compose
docker logs kafka
docker logs zookeeper

# Kubernetes
kubectl logs -n infra deployment/kafka
kubectl logs -n infra deployment/zookeeper
```

### 清理资源
```bash
# Kubernetes
kubectl delete namespace infra
```

## 注意事项

1. **Docker Compose 方式**更适合本地开发，简单易用
2. **Kubernetes 方式**更适合生产环境或需要集群管理的场景
3. 本配置使用的是单节点部署，不建议用于生产环境
4. 数据持久化已配置，但使用的是临时存储（emptyDir 或 Docker volume）