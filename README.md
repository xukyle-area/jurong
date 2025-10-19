# 🚀Jurong 现代数据平台

本项目基于 Kubernetes，集成 Kafka、MySQL、Redis、ZooKeeper、Flink 等服务，适用于本地开发和企业级数据基础设施。

## 目录结构
```
├── README.md
├── deployments/
│   └── kafka-deployment.yaml
├── manifests/
│   └── infra-deployment.yaml
├── mysql-init/
│   ├── 01-init.sql
│   └── 02-kafka-tables.sql
└── scripts/
   └── start-infra-and-session.sh
```

## 功能特性
- Kafka + ZooKeeper 消息队列
- MySQL + phpMyAdmin 数据库
- Redis + Redis Commander 缓存
- Cassandra NoSQL 数据库
- Flink 流计算（可选）
- SQL 文件初始化 MySQL（无需 ConfigMap）

## 快速开始

### 1. 环境准备
确保已安装并启动以下环境：
```bash
# 1. 安装 Docker Desktop
# 下载地址: https://www.docker.com/products/docker-desktop

# 2. 启动 Kubernetes 集群
# 在 Docker Desktop 中启用 Kubernetes
# 或者使用 minikube:
minikube start

# 3. 验证 Kubernetes 集群
kubectl cluster-info
kubectl get nodes
```

### 2. 初始化数据库
编辑 `mysql-init/` 下 SQL 文件，定义表结构和初始化数据。

### 3. 部署基础设施
```sh
kubectl apply -f manifests/infra-deployment.yaml
kubectl apply -f deployments/kafka-deployment.yaml
```
注意：Cassandra 已集成在 `infra-deployment.yaml` 中，会自动部署。

### 4. 启动所有服务
```sh
bash scripts/start-infra-and-session.sh deploy
```

### 5. 检查部署状态
```sh
# 查看所有服务状态
bash scripts/start-infra-and-session.sh status

# 检查 Cassandra 详细状态（如需要）
bash scripts/start-infra-and-session.sh cassandra-status
```

### 6. 访问服务界面
首先设置端口转发：
```sh
kubectl port-forward -n infra svc/kafka-ui 8080:8080 &
kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &
kubectl port-forward -n infra svc/redis-commander 8082:8082 &
kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &
```

然后访问：
- Kafka UI: http://localhost:8080
- phpMyAdmin: http://localhost:8081
- Redis Commander: http://localhost:8082
- Flink Web UI: http://localhost:8083
## 维护与扩展

- 修改数据库结构或数据，直接编辑 `mysql-init/` 下 SQL 文件，重启 MySQL Pod 即可。
- 其他服务配置请参考对应 YAML 文件。
- Kafka、Redis、Flink 等服务如需扩展或自定义，可修改对应 manifests 或 deployments 下的 YAML 文件。
- 推荐使用 Git 进行版本管理，方便团队协作和回滚。

## kubectl 常用命令

### 基础操作
```bash
# 查看集群信息
kubectl cluster-info

# 查看所有节点
kubectl get nodes

# 查看所有命名空间
kubectl get namespaces

# 查看指定命名空间的所有资源
kubectl get all -n infra
```

### Pod 管理
```bash
# 查看所有 Pod
kubectl get pods -A

# 查看指定命名空间的 Pod
kubectl get pods -n infra

# 查看 Pod 详细信息
kubectl describe pod <pod-name> -n infra

# 查看 Pod 日志
kubectl logs <pod-name> -n infra

# 实时查看 Pod 日志
kubectl logs -f <pod-name> -n infra

# 进入 Pod 容器
kubectl exec -it <pod-name> -n infra -- /bin/bash
```

### 服务管理
```bash
# 查看所有服务
kubectl get svc -A

# 端口转发访问服务
kubectl port-forward -n infra svc/<service-name> <本地端口>:<服务端口>

# 例如：访问 Kafka UI
kubectl port-forward -n infra svc/kafka-ui 8080:8080
```

### 资源监控
```bash
# 查看资源使用情况
kubectl top nodes
kubectl top pods -n infra

# 查看持久卷
kubectl get pv
kubectl get pvc -n infra

# 查看配置和密钥
kubectl get configmap -n infra
kubectl get secret -n infra
```

### 故障排除
```bash
# 查看事件（排查问题）
kubectl get events -n infra --sort-by='.lastTimestamp'

# 重启部署
kubectl rollout restart deployment/<deployment-name> -n infra

# 扩缩容
kubectl scale deployment/<deployment-name> --replicas=3 -n infra

# 删除资源
kubectl delete pod <pod-name> -n infra
```

## 常见问题

- 检查 Pod 日志：`kubectl logs <pod-name> -n infra`
- 检查服务健康：`kubectl get pods -A`
- 如遇端口冲突，可修改服务暴露端口或端口转发命令。
- MySQL 初始化失败请检查 SQL 文件语法和挂载路径。
- Kafka、Redis 等服务未启动请检查 PVC 挂载和资源限制。

### Cassandra 特殊问题
- **镜像拉取失败**：使用 `cassandra:3.11` 稳定版本
- **启动缓慢**：Cassandra 首次启动需要 2-5 分钟，请耐心等待
- **内存不足**：确保 Docker Desktop 分配至少 4GB 内存
- **检查详细状态**：`./scripts/start-infra-and-session.sh cassandra-status`

## 适用场景

- 微服务架构的本地开发与测试
- 数据管道、流处理、消息队列实验环境
- 企业级数据基础设施原型搭建
- 教学、演示、POC 场景

## 贡献方式

欢迎提交 Issue 或 Pull Request 参与项目完善。
建议在提交前先讨论需求或问题。

## 技术特性

- ✅ **高可用部署** - StatefulSets 和 Deployments
- ✅ **数据持久化** - PersistentVolumeClaims
- ✅ **服务发现** - Kubernetes Service 网格
- ✅ **负载均衡** - LoadBalancer 和 ClusterIP
- ✅ **自动扩展** - HorizontalPodAutoscaler 支持
- ✅ **监控就绪** - Prometheus 指标集成

## 管理工具

### 端口转发访问服务
```bash
# 启动端口转发
kubectl port-forward -n infra svc/kafka-ui 8080:8080 &
kubectl port-forward -n infra svc/phpmyadmin 8081:8081 &
kubectl port-forward -n infra svc/redis-commander 8082:8082 &
kubectl port-forward -n infra svc/flink-jobmanager-ui 8083:8083 &
```

### 平台管理命令
```bash
# 查看平台状态
./infra-manage.sh status

# 查看连接信息
./infra-manage.sh connection

# 清理所有资源
./infra-manage.sh cleanup
```

## 集成开发

### Java Spring Boot 配置示例
```properties
# application.properties
# Kafka 消息队列
spring.kafka.bootstrap-servers=kafka-service.infra.svc.cluster.local:9092
spring.kafka.consumer.group-id=my-app-group

# MySQL 数据库
spring.datasource.url=jdbc:mysql://mysql-service.infra.svc.cluster.local:3306/appdb
spring.datasource.username=root
spring.datasource.password=rootpassword

# Redis 缓存
spring.redis.host=redis-service.infra.svc.cluster.local
spring.redis.port=6379
spring.redis.password=redispassword

# Cassandra 数据库
spring.data.cassandra.contact-points=cassandra-service.infra.svc.cluster.local
spring.data.cassandra.port=9042
spring.data.cassandra.keyspace-name=jurong_keyspace
spring.data.cassandra.local-datacenter=DC1
```

### 服务端点
- **Kafka**: kafka-service.infra.svc.cluster.local:9092
- **MySQL**: mysql-service.infra.svc.cluster.local:3306
- **Redis**: redis-service.infra.svc.cluster.local:6379
- **Cassandra**: cassandra-service.infra.svc.cluster.local:9042
- **ZooKeeper**: zookeeper-service.infra.svc.cluster.local:2181

## 联系方式

如有问题请在本仓库提交 Issue，或通过团队内部渠道联系维护者。

