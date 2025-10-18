# Docker Compose vs Kubernetes 对比说明

## 📊 当前部署架构对比

### 🐳 Docker Compose 中运行的服务

| 服务          | 镜像                            | 端口 | 状态     | 说明                         |
| ------------- | ------------------------------- | ---- | -------- | ---------------------------- |
| **ZooKeeper** | confluentinc/cp-zookeeper:7.4.0 | 2181 | ✅ 运行中 | Kafka 协调服务               |
| **Kafka**     | confluentinc/cp-kafka:7.4.0     | 9092 | ✅ 运行中 | 消息队列服务                 |
| **Kafka UI**  | provectuslabs/kafka-ui:latest   | 8080 | ✅ 运行中 | Kafka 管理界面               |
| **Headlamp**  | ghcr.io/kinvolk/headlamp:latest | 4466 | ❌ 停用   | K8s 管理界面（已迁移到 K8s） |

### ☸️ Kubernetes 中运行的服务

| 服务               | Namespace   | 镜像                            | 端口  | 状态     | 说明                  |
| ------------------ | ----------- | ------------------------------- | ----- | -------- | --------------------- |
| **Headlamp**       | infra       | ghcr.io/kinvolk/headlamp:latest | 30466 | ✅ 运行中 | K8s 管理界面          |
| **headlamp-admin** | kube-system | -                               | -     | ✅ 活跃   | 管理员 ServiceAccount |

---

## 🔄 为什么这样混合部署？

### Docker Compose 适合：

**✅ Kafka 生态系统**
- **简单性**: 单个 `docker-compose.yaml` 文件管理整个 Kafka 栈
- **网络**: 服务间通过容器名直接通信（如 `kafka:9092`）
- **依赖管理**: `depends_on` 确保启动顺序
- **开发友好**: 快速启动/停止，适合开发和测试

```yaml
# 例如：Kafka 依赖 ZooKeeper
kafka:
  depends_on:
    - zookeeper
  environment:
    KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
```

### Kubernetes 适合：

**✅ Headlamp (Kubernetes 管理工具)**
- **集群内认证**: 使用 ServiceAccount 自动认证
- **权限管理**: RBAC 精确控制权限
- **高可用**: Pod 自动重启，服务发现
- **企业级**: 生产环境的标准

```yaml
# 例如：ServiceAccount 自动权限
serviceAccountName: headlamp
args: ["-in-cluster"]  # 集群内认证
```

---

## 🤔 为什么不全部用 Kubernetes？

### Kafka 在 K8s 中的问题：
1. **镜像兼容性**: `wurstmeister/kafka` 在 ARM Mac 上有问题
2. **复杂性**: 需要 StatefulSet、PVC、多个配置文件
3. **开发体验**: Docker Compose 更简单直接

### Headlamp 在 Docker 中的问题：
1. **网络隔离**: 容器无法访问 K8s API Server (127.0.0.1:6443)
2. **认证复杂**: 需要挂载 kubeconfig，权限管理复杂
3. **功能限制**: 在 K8s 内运行功能更完整

---

## 📋 实际运行对比

### 🐳 Docker Compose 网络
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ ZooKeeper   │◄──►│   Kafka     │◄──►│  Kafka UI   │
│   :2181     │    │   :9092     │    │   :8080     │
└─────────────┘    └─────────────┘    └─────────────┘
       ▲                   ▲                   ▲
       └───────────────────┼───────────────────┘
                    kafka-network
```

### ☸️ Kubernetes 集群
```
┌─────────────────────────────────────────┐
│           Kubernetes Cluster            │
│  ┌─────────────┐    ┌────────────────┐  │
│  │   Headlamp  │◄──►│ K8s API Server │  │
│  │  (Pod)      │    │   :6443        │  │
│  │  :30466     │    └────────────────┘  │
│  └─────────────┘                        │
│         ▲                                │
│  ┌─────────────┐                        │
│  │ ServiceAcc  │                        │
│  │ headlamp-   │                        │
│  │ admin       │                        │
│  └─────────────┘                        │
└─────────────────────────────────────────┘
```

---

## 💡 最佳实践建议

### 当前架构优势：
- **开发效率**: Kafka 用 Docker Compose 快速迭代
- **生产就绪**: Headlamp 在 K8s 中享受企业级特性
- **职责分离**: 消息队列 vs 集群管理工具分开部署

### 如果要统一到 K8s：
```bash
# 可以用 Helm Chart 部署 Kafka
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install kafka bitnami/kafka -n kafka-system --create-namespace
```

### 如果要统一到 Docker：
```bash
# 需要解决网络问题
docker run --network host headlamp
# 但会失去 K8s 的企业级特性
```

---

## 🎯 总结

**当前混合架构是经过权衡的最佳选择**：
- 每个工具都运行在最适合它的环境中
- 保持了开发的简单性和生产的可靠性
- 避免了各种兼容性和复杂性问题