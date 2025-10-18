# 🚀 现代数据平台 - Jurong# Jurong - Kafka + MySQL 开发环境



> 基于 Kubernetes 的生产级数据处理平台🚀 **一个完整的开发环境**，包含 Kafka、MySQL、Headlamp 等服务，提供了在 Docker Desktop 环境下的完整解决方案。



## 📋 项目概览## ⚡ 快速开始



这是一个现代化的数据平台项目，基于 **Kubernetes** 提供完整的数据处理基础设施：### 一键启动所有服务

```bash

- **消息队列**：Apache Kafka + ZooKeeper# 启动完整服务栈 (Kafka + MySQL + 管理界面)

- **数据库**：MySQL + phpMyAdmin./scripts/start-all.sh

- **缓存**：Redis + Redis Commander  ```

- **流计算**：Apache Flink JobManager + TaskManager

- **监控管理**：Headlamp (Kubernetes 管理界面)### 访问服务

- **可视化界面**：Kafka UI- **Kafka UI**: http://localhost:8080 (管理 Kafka)

- **phpMyAdmin**: http://localhost:8081 (管理 MySQL)  

## 🏗️ Kubernetes 原生架构- **Headlamp**: http://localhost:30466 (管理 Kubernetes)



- ✅ **高可用部署** - StatefulSets 和 Deployments### 使用 Kubernetes

- ✅ **自动扩展** - HorizontalPodAutoscaler 支持  

- ✅ **数据持久化** - PersistentVolumeClaims```bash

- ✅ **服务发现** - Kubernetes Service 网格# 创建命名空间

- ✅ **负载均衡** - LoadBalancer 和 ClusterIPkubectl apply -f deployments/namespace.yaml

- ✅ **监控就绪** - Prometheus 指标集成

# 部署 ZooKeeper

## ⚡ 快速开始kubectl apply -f deployments/zookeeper-deployment.yaml



### 1. 前置条件# 部署 Kafka

kubectl apply -f deployments/kafka-deployment.yaml

确保你有一个可用的 Kubernetes 集群：```



```bash## 服务端点

# 检查集群连接

kubectl cluster-info- **Kafka**: localhost:9092

- **ZooKeeper**: localhost:2181  

# 检查节点状态- **Kafka UI**: http://localhost:8080

kubectl get nodes- **Headlamp (Kubernetes UI)**: http://localhost:4466

```

## 启动 Headlamp

### 2. 一键部署

### Kubernetes 方式（推荐）

```bash```bash

# 部署完整数据平台./deploy-headlamp-k8s.sh

./flink/deploy-k8s-complete.sh deploy```

访问地址: http://localhost:30466

# 查看部署状态

./flink/deploy-k8s-complete.sh status## 🏗️ 架构概览

```

### Docker Compose (应用服务栈)

### 3. 访问服务- **Kafka** + **ZooKeeper** - 消息队列服务

- **MySQL** - 关系型数据库

```bash- **Kafka UI** - Kafka 管理界面

# 启动端口转发- **phpMyAdmin** - MySQL 管理界面

./switch-env.sh port-forward

### Kubernetes (集群管理工具)

# 或者手动端口转发- **Headlamp** - Kubernetes 集群管理界面

kubectl port-forward -n data-platform svc/kafka-ui 8080:8080 &

kubectl port-forward -n data-platform svc/phpmyadmin 8081:8081 &## 📚 详细文档

kubectl port-forward -n data-platform svc/redis-commander 8082:8082 &

kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083 &所有详细文档都在 **[docs/](./docs/)** 目录中：

```

### 🚀 快速入门

**访问地址:**- **[docs/ARCHITECTURE_CLEANUP.md](./docs/ARCHITECTURE_CLEANUP.md)** - 架构说明和服务访问

- 🎛️ **Kafka UI**: http://localhost:8080 - Kafka 集群管理- **[docs/KAFKA_DEPLOYMENT.md](./docs/KAFKA_DEPLOYMENT.md)** - Kafka 部署指南

- 🗄️ **phpMyAdmin**: http://localhost:8081 - MySQL 数据库管理

- 📦 **Redis Commander**: http://localhost:8082 - Redis 缓存管理### 📖 部署指南  

- 🌊 **Flink Web UI**: http://localhost:8083 - 流计算作业管理- **[docs/MYSQL_DEPLOYMENT_GUIDE.md](./docs/MYSQL_DEPLOYMENT_GUIDE.md)** - MySQL 部署指南

- **[docs/DOCKER_COMPOSE_VS_K8S.md](./docs/DOCKER_COMPOSE_VS_K8S.md)** - 架构选择指南

## 🛠️ 管理工具

### 🔧 故障排除

### 平台管理- **[docs/HEADLAMP_TROUBLESHOOTING.md](./docs/HEADLAMP_TROUBLESHOOTING.md)** - Headlamp 故障排除



```bash## 📁 项目结构

# 查看平台状态

./switch-env.sh status```

jurong/

# 查看连接信息├── docs/                      # 📚 所有项目文档

./switch-env.sh connection├── scripts/                   # 🔧 部署和管理脚本

├── deployments/               # ☸️  Kubernetes 部署文件

# 清理所有资源├── mysql/                     # 🗄️  MySQL 初始化脚本

./switch-env.sh cleanup├── docker-compose.yaml        # 🐳 Docker Compose 配置

```└── README.md                  # 📖 项目说明

```

### 服务操作

## 🎯 常用命令

```bash

# 重启服务```bash

kubectl rollout restart deployment/kafka-ui -n data-platform# 启动所有服务

./scripts/start-all.sh

# 扩缩容

kubectl scale deployment/flink-taskmanager --replicas=3 -n data-platform# 测试 Kafka 连接

./scripts/test-kafka.sh

# 查看日志

kubectl logs -f kafka-0 -n data-platform# 检查服务状态

```docker-compose ps



## 📊 服务端点# 停止所有服务

docker-compose down

### 集群内访问 (Pod-to-Pod)```



```yaml## 📞 获取帮助

kafka: kafka-service.data-platform.svc.cluster.local:9092

mysql: mysql-service.data-platform.svc.cluster.local:33061. 查看 **[docs/README.md](./docs/README.md)** 文档索引

redis: redis-service.data-platform.svc.cluster.local:63792. 检查相关脚本的帮助信息

flink: flink-jobmanager.data-platform.svc.cluster.local:80813. 查看服务日志进行故障排查
```

### 外部访问 (端口转发)

```bash
kafka: localhost:9092
mysql: localhost:3306  
redis: localhost:6379
flink: localhost:8081
```

## 🏗️ 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                   🌐 管理界面层                              │
│  Kafka UI │ phpMyAdmin │ Redis Commander │ Flink Web UI    │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   💼 应用服务层                              │
│           Java 微服务 │ Spring Boot │ 数据处理应用          │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   🔧 核心数据层                              │
│   Kafka + ZooKeeper │ MySQL │ Redis │ Apache Flink        │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                   ☸️  Kubernetes 层                         │
│    StatefulSets │ Deployments │ Services │ PVCs           │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 开发指南

### Java 应用连接

```properties
# application.properties

# Kafka 配置
spring.kafka.bootstrap-servers=kafka-service.data-platform.svc.cluster.local:9092
spring.kafka.consumer.group-id=my-app-group

# MySQL 配置  
spring.datasource.url=jdbc:mysql://mysql-service.data-platform.svc.cluster.local:3306/appdb
spring.datasource.username=root
spring.datasource.password=rootpassword

# Redis 配置
spring.redis.host=redis-service.data-platform.svc.cluster.local
spring.redis.port=6379
spring.redis.password=redispassword
```

### Flink 作业提交

```bash
# 上传 JAR 文件
curl -X POST -H "Content-Type: multipart/form-data" \
  -F "jarfile=@your-flink-job.jar" \
  http://localhost:8083/jars/upload

# 提交作业
curl -X POST http://localhost:8083/jars/<jar-id>/run
```

## 📚 详细文档

- 📋 **[完整指南](DATA_PLATFORM_GUIDE.md)** - 详细的使用和部署指南
- 🎉 **[项目总结](PROJECT_SUMMARY.md)** - 功能概览和快速开始
- 📚 **[docs/](docs/)** - 技术文档和故障排除

## 🔍 故障排除

### 常见问题

1. **Pod 启动失败**
   ```bash
   kubectl describe pod <pod-name> -n data-platform
   kubectl logs <pod-name> -n data-platform
   ```

2. **服务无法访问**
   ```bash
   kubectl get svc -n data-platform
   kubectl port-forward -n data-platform svc/<service-name> <local-port>:<service-port>
   ```

3. **存储问题**
   ```bash
   kubectl get pvc -n data-platform
   kubectl describe pvc <pvc-name> -n data-platform
   ```

### 获取帮助

```bash
# 查看可用命令
./switch-env.sh help
./flink/deploy-k8s-complete.sh help

# 查看平台状态
./switch-env.sh status
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

---

🚀 **开始你的 Kubernetes 数据平台之旅！**