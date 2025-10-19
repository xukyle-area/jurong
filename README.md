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
- Flink 流计算（可选）
- SQL 文件初始化 MySQL（无需 ConfigMap）

## 快速开始
1. 编辑 `mysql-init/` 下 SQL 文件，定义表结构和初始化数据。
2. 部署基础设施：
  ```sh
  kubectl apply -f manifests/infra-deployment.yaml
  kubectl apply -f deployments/kafka-deployment.yaml
  ```
3. 启动所有服务：
  ```sh
  bash scripts/start-infra-and-session.sh
  ```
4. 访问服务界面：
  - Kafka UI: http://localhost:8080
  - phpMyAdmin: http://localhost:8081
  - Redis Commander: http://localhost:8082
  - Flink Web UI: http://localhost:8083
#
## 维护与扩展

- 修改数据库结构或数据，直接编辑 `mysql-init/` 下 SQL 文件，重启 MySQL Pod 即可。
- 其他服务配置请参考对应 YAML 文件。
- Kafka、Redis、Flink 等服务如需扩展或自定义，可修改对应 manifests 或 deployments 下的 YAML 文件。
- 推荐使用 Git 进行版本管理，方便团队协作和回滚。

## 常见问题

- 检查 Pod 日志：`kubectl logs <pod-name>`
- 检查服务健康：`kubectl get pods -A`
- 如遇端口冲突，可修改服务暴露端口或端口转发命令。
- MySQL 初始化失败请检查 SQL 文件语法和挂载路径。
- Kafka、Redis 等服务未启动请检查 PVC 挂载和资源限制。

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
```

### 服务端点
- **Kafka**: kafka-service.infra.svc.cluster.local:9092
- **MySQL**: mysql-service.infra.svc.cluster.local:3306
- **Redis**: redis-service.infra.svc.cluster.local:6379
- **ZooKeeper**: zookeeper-service.infra.svc.cluster.local:2181

## 联系方式

如有问题请在本仓库提交 Issue，或通过团队内部渠道联系维护者。

