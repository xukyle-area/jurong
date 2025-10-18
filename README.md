# Jurong - Kafka Deployment Environment

本项目提供了在 Docker Desktop 环境下部署 Kafka 的完整解决方案。

## 快速开始

### 使用 Docker Compose（推荐）

```bash
# 启动 Kafka 服务栈
docker-compose up -d

# 测试部署
./test-kafka.sh

# 访问 Kafka UI
open http://localhost:8080
```

### 使用 Kubernetes

```bash
# 创建命名空间
kubectl apply -f deployments/namespace.yaml

# 部署 ZooKeeper
kubectl apply -f deployments/zookeeper-deployment.yaml

# 部署 Kafka
kubectl apply -f deployments/kafka-deployment.yaml
```

## 服务端点

- **Kafka**: localhost:9092
- **ZooKeeper**: localhost:2181  
- **Kafka UI**: http://localhost:8080

## 文档

详细部署说明请参考 [KAFKA_DEPLOYMENT.md](KAFKA_DEPLOYMENT.md)

## For Kubernetes