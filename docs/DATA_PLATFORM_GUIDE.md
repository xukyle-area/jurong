# 完整数据平台架构指南

## 📋 项目概览

这是一个完整的现代数据平台，基于 **Kubernetes** 构建，提供生产级的容器化部署和管理。

### 🏗️ 核心服务

| 服务                | 版本     | 用途             | 端口 |
| ------------------- | -------- | ---------------- | ---- |
| **Apache Kafka**    | 7.4.0    | 消息队列和流处理 | 9092 |
| **ZooKeeper**       | 7.4.0    | Kafka 集群协调   | 2181 |
| **MySQL**           | 8.0      | 关系型数据库     | 3306 |
| **Redis**           | 7-alpine | 缓存和会话存储   | 6379 |
| **Apache Flink**    | 1.17.2   | 流计算引擎       | 8081 |
| **Kafka UI**        | latest   | Kafka 管理界面   | 8080 |
| **phpMyAdmin**      | latest   | MySQL 管理界面   | 8081 |
| **Redis Commander** | latest   | Redis 管理界面   | 8082 |

## 🚀 快速开始

### Kubernetes 部署

```bash
# 确保 kubectl 可以连接到集群
kubectl cluster-info

# 部署完整数据平台
./flink/deploy.sh deploy

# 查看部署状态
./flink/deploy.sh status

# 端口转发访问服务
kubectl port-forward -n data-platform svc/kafka-ui 8080:8080
kubectl port-forward -n data-platform svc/phpmyadmin 8081:8081
kubectl port-forward -n data-platform svc/redis-commander 8082:8082
kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083
```

## 📊 架构图

```
                    ┌─────────────────────────────────────┐
                    │          Web 管理界面                │
                    │  Kafka UI │ phpMyAdmin │ Redis CMD  │
                    └─────────────┬───────────────────────┘
                                  │
                    ┌─────────────────────────────────────┐
                    │           应用层                     │
                    │     Java 微服务 │ Flink 作业        │
                    └─────────────┬───────────────────────┘
                                  │
┌─────────────┬─────────────────────┬─────────────────────┬──────────────┐
│   消息队列   │      数据库         │       缓存          │   流计算      │
│             │                    │                    │              │
│   Kafka     │     MySQL          │      Redis         │    Flink     │
│ ┌─────────┐ │   ┌─────────────┐  │  ┌───────────────┐ │ ┌──────────┐ │
│ │Producer │ │   │Tables/Views │  │  │Key-Value Store│ │ │JobManager│ │
│ │Consumer │ │   │Indexes/etc  │  │  │Sessions/Cache │ │ │TaskMgr   │ │
│ └─────────┘ │   └─────────────┘  │  └───────────────┘ │ └──────────┘ │
│             │                    │                    │              │
│ ZooKeeper   │                    │                    │              │
└─────────────┴────────────────────┴────────────────────┴──────────────┘
                                  │
                    ┌─────────────────────────────────────┐
                    │          持久化存储                  │
                    │    Kubernetes PersistentVolumes    │
                    └─────────────────────────────────────┘
```

## 🛠️ 开发工作流

### 1. 部署和管理

```bash
# 部署完整平台
./flink/deploy.sh deploy

# 查看服务状态
./flink/deploy.sh status

# 清理所有资源
./flink/deploy.sh cleanup
```

### 2. 连接服务进行开发

**Java 应用连接示例:**

```properties
# application.properties - 集群内访问
spring.kafka.bootstrap-servers=kafka-service.data-platform.svc.cluster.local:9092
spring.datasource.url=jdbc:mysql://mysql-service.data-platform.svc.cluster.local:3306/appdb
spring.datasource.username=root
spring.datasource.password=rootpassword
spring.redis.host=redis-service.data-platform.svc.cluster.local
spring.redis.port=6379
spring.redis.password=redispassword

# 本地开发时通过端口转发
spring.kafka.bootstrap-servers=localhost:9092
spring.datasource.url=jdbc:mysql://localhost:3306/appdb
spring.redis.host=localhost
```

**Flink 作业提交:**

```bash
# 端口转发 Flink Web UI
kubectl port-forward -n data-platform svc/flink-jobmanager-ui 8083:8083

# 通过 Web UI 提交作业
curl -X POST http://localhost:8083/jars/upload \
  -H "Content-Type: multipart/form-data" \
  -F "jarfile=@your-flink-job.jar"
```

### 3. 测试和验证

**创建 Kafka 主题:**

```bash
# 自动创建主题（已在部署脚本中包含）
./flink/deploy.sh topics

# 手动创建主题
kubectl exec -n data-platform statefulset/kafka -- \
  kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 1
```

**测试消息发送:**

```bash
# 发送消息
kubectl exec -it -n data-platform statefulset/kafka -- \
  kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic

# 消费消息
kubectl exec -it -n data-platform statefulset/kafka -- \
  kafka-console-consumer --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```

## 🔄 集群管理

### 服务操作

```bash
# 部署服务
./flink/deploy.sh deploy

# 查看服务状态
./flink/deploy.sh status

# 重启特定服务
kubectl rollout restart deployment/kafka-ui -n data-platform
kubectl rollout restart statefulset/kafka -n data-platform

# 扩缩容
kubectl scale deployment/flink-taskmanager --replicas=3 -n data-platform
```

### 数据管理

1. **MySQL 数据备份:**
   ```bash
   # 创建备份
   kubectl exec -n data-platform mysql-0 -- \
     mysqldump -u root -p"rootpassword" appdb > backup-$(date +%Y%m%d).sql
   
   # 恢复数据
   kubectl exec -i -n data-platform mysql-0 -- \
     mysql -u root -p"rootpassword" appdb < backup.sql
   ```

2. **Kafka 主题管理:**
   ```bash
   # 查看主题列表
   kubectl exec -n data-platform statefulset/kafka -- \
     kafka-topics --bootstrap-server localhost:9092 --list
   
   # 主题详情
   kubectl exec -n data-platform statefulset/kafka -- \
     kafka-topics --bootstrap-server localhost:9092 --describe --topic your-topic
   ```

## 📈 生产部署

### 1. Kubernetes 集群准备

**本地 (Docker Desktop):**
```bash
# 启用 Kubernetes
# Docker Desktop → Settings → Kubernetes → Enable Kubernetes
```

**云端 (EKS/AKS/GKE):**
```bash
# AWS EKS
eksctl create cluster --name data-platform --region us-west-2

# 配置 kubectl
aws eks update-kubeconfig --region us-west-2 --name data-platform
```

### 2. 部署到生产

```bash
# 完整部署
./flink/deploy.sh deploy

# 分步部署
./flink/deploy.sh infrastructure  # 基础设施
./flink/deploy.sh flink          # Flink 集群
./flink/deploy.sh topics         # Kafka 主题
```

### 3. 监控和维护

```bash
# 查看资源使用
kubectl top pods -n data-platform
kubectl top nodes

# 查看日志
kubectl logs -f deployment/kafka-ui -n data-platform
kubectl logs -f statefulset/kafka -n data-platform

# 扩缩容
kubectl scale deployment/flink-taskmanager --replicas=3 -n data-platform
```

## 🔍 故障排除

### 常见问题

1. **服务启动失败**
   ```bash
   # 查看详细日志
   kubectl logs -f kafka-0 -n data-platform
   kubectl describe pod kafka-0 -n data-platform
   
   # 查看事件
   kubectl get events -n data-platform --sort-by=.metadata.creationTimestamp
   ```

2. **端口转发问题**
   ```bash
   # 检查端口占用
   lsof -i :8080
   
   # 重新建立端口转发
   kubectl port-forward -n data-platform svc/kafka-ui 8080:8080
   ```

3. **存储空间不足**
   ```bash
   # 检查 PVC 使用情况
   kubectl get pvc -n data-platform
   kubectl describe pvc -n data-platform
   
   # 清理不需要的资源
   kubectl delete pod <failed-pod> -n data-platform
   ```

4. **连接问题**
   ```bash
   # 网络调试
   kubectl exec -n data-platform kafka-0 -- nc -zv localhost 9092
   kubectl exec -n data-platform kafka-0 -- nc -zv mysql-service 3306
   
   # 检查服务状态
   kubectl get svc -n data-platform
   ```

### 性能调优

1. **Kafka 优化**
   ```bash
   # 增加分区数
   kubectl exec -n data-platform statefulset/kafka -- \
     kafka-topics --alter --bootstrap-server localhost:9092 \
     --topic your-topic --partitions 6
   
   # 修改 K8s 资源配置
   kubectl patch statefulset kafka -n data-platform -p '{"spec":{"template":{"spec":{"containers":[{"name":"kafka","env":[{"name":"KAFKA_HEAP_OPTS","value":"-Xmx2G -Xms2G"}]}]}}}}'
   ```

2. **Flink 优化**
   ```yaml
   # 在 k8s-flink.yaml 中调整资源
   resources:
     requests:
       memory: "1Gi"
       cpu: "500m"
     limits:
       memory: "2Gi"
       cpu: "1000m"
   ```

## 📚 扩展功能

### 1. 添加新服务

**示例：Elasticsearch**

```yaml
# 添加到 k8s-complete-stack.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: data-platform
spec:
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.8.0
        env:
        - name: discovery.type
          value: single-node
        - name: xpack.security.enabled
          value: "false"
        ports:
        - containerPort: 9200
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: data-platform
spec:
  selector:
    app: elasticsearch
  ports:
  - port: 9200
    targetPort: 9200
```

### 2. 集成监控

**Prometheus + Grafana:**

```bash
# 添加到 K8s 集群
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### 3. 数据备份

**自动备份脚本:**

```bash
#!/bin/bash
# scripts/backup.sh

# MySQL 备份
kubectl exec mysql-0 -n data-platform -- \
  mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" appdb > "backup-$(date +%Y%m%d).sql"

# Redis 备份
kubectl exec redis-0 -n data-platform -- \
  redis-cli --rdb /data/dump-$(date +%Y%m%d).rdb
```

## 🎯 最佳实践

1. **Kubernetes 原生部署**
   - 利用 K8s 的高可用和自动恢复能力
   - 使用 StatefulSets 管理有状态服务
   - 合理配置资源请求和限制

2. **配置管理**
   - 敏感信息使用 Secrets
   - 环境变量使用 ConfigMaps
   - 使用 Helm Charts 管理复杂配置

3. **数据持久化**
   - 重要数据使用 PVC
   - 定期备份和恢复测试
   - 配置适当的 StorageClass

4. **监控告警**
   - 设置资源使用告警
   - 配置服务健康检查
   - 使用 Prometheus + Grafana 监控栈

5. **安全性**
   - 配置 RBAC 权限控制
   - 使用 NetworkPolicies 限制网络访问
   - 定期更新镜像和安全补丁

## 📞 支持

如有问题，请查看：
- 项目 README.md
- scripts/ 目录下的帮助脚本
- 使用 `./flink/deploy.sh help` 获取帮助

---

🚀 **开始你的 Kubernetes 数据平台之旅！**