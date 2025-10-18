# Jurong - Kafka + MySQL 开发环境

🚀 **一个完整的开发环境**，包含 Kafka、MySQL、Headlamp 等服务，提供了在 Docker Desktop 环境下的完整解决方案。

## ⚡ 快速开始

### 一键启动所有服务
```bash
# 启动完整服务栈 (Kafka + MySQL + 管理界面)
./scripts/start-all.sh
```

### 访问服务
- **Kafka UI**: http://localhost:8080 (管理 Kafka)
- **phpMyAdmin**: http://localhost:8081 (管理 MySQL)  
- **Headlamp**: http://localhost:30466 (管理 Kubernetes)

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
- **Headlamp (Kubernetes UI)**: http://localhost:4466

## 启动 Headlamp

### Kubernetes 方式（推荐）
```bash
./deploy-headlamp-k8s.sh
```
访问地址: http://localhost:30466

### Docker Compose 方式
```bash
./scripts/start-headlamp.sh
```

### 故障排除
如果遇到连接问题，请参考：
- [Headlamp 故障排除指南](HEADLAMP_TROUBLESHOOTING.md)
- 运行验证脚本: `./scripts/verify-headlamp.sh`

## 📁 项目结构

```
jurong/
├── scripts/                    # 所有脚本文件
│   ├── test-kafka.sh          # Kafka 测试脚本
│   ├── deploy-headlamp-k8s.sh # Headlamp Kubernetes 部署
│   ├── generate-clean-token.sh # 生成登录令牌
│   └── ...                    # 其他工具脚本
├── deployments/               # Kubernetes 部署文件
│   ├── kafka-deployment.yaml
│   ├── headlamp-deployment.yaml
│   └── ...
├── docker-compose.yaml        # Docker Compose 配置
└── README.md

## 文档

详细部署说明请参考 [KAFKA_DEPLOYMENT.md](KAFKA_DEPLOYMENT.md)

## For Kubernetes