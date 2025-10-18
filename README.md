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

## 🏗️ 架构概览

### Docker Compose (应用服务栈)
- **Kafka** + **ZooKeeper** - 消息队列服务
- **MySQL** - 关系型数据库
- **Kafka UI** - Kafka 管理界面
- **phpMyAdmin** - MySQL 管理界面

### Kubernetes (集群管理工具)
- **Headlamp** - Kubernetes 集群管理界面

## 📚 详细文档

所有详细文档都在 **[docs/](./docs/)** 目录中：

### 🚀 快速入门
- **[docs/ARCHITECTURE_CLEANUP.md](./docs/ARCHITECTURE_CLEANUP.md)** - 架构说明和服务访问
- **[docs/KAFKA_DEPLOYMENT.md](./docs/KAFKA_DEPLOYMENT.md)** - Kafka 部署指南

### 📖 部署指南  
- **[docs/MYSQL_DEPLOYMENT_GUIDE.md](./docs/MYSQL_DEPLOYMENT_GUIDE.md)** - MySQL 部署指南
- **[docs/DOCKER_COMPOSE_VS_K8S.md](./docs/DOCKER_COMPOSE_VS_K8S.md)** - 架构选择指南

### 🔧 故障排除
- **[docs/HEADLAMP_TROUBLESHOOTING.md](./docs/HEADLAMP_TROUBLESHOOTING.md)** - Headlamp 故障排除

## 📁 项目结构

```
jurong/
├── docs/                      # 📚 所有项目文档
├── scripts/                   # 🔧 部署和管理脚本
├── deployments/               # ☸️  Kubernetes 部署文件
├── mysql/                     # 🗄️  MySQL 初始化脚本
├── docker-compose.yaml        # 🐳 Docker Compose 配置
└── README.md                  # 📖 项目说明
```

## 🎯 常用命令

```bash
# 启动所有服务
./scripts/start-all.sh

# 测试 Kafka 连接
./scripts/test-kafka.sh

# 检查服务状态
docker-compose ps

# 停止所有服务
docker-compose down
```

## 📞 获取帮助

1. 查看 **[docs/README.md](./docs/README.md)** 文档索引
2. 检查相关脚本的帮助信息
3. 查看服务日志进行故障排查