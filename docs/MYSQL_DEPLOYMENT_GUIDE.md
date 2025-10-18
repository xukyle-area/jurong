# MySQL 数据库部署选择指南

## 🤔 MySQL 应该用 Docker Compose 还是 Kubernetes？

### 📊 对比分析

| 特性           | Docker Compose | Kubernetes     |
| -------------- | -------------- | -------------- |
| **设置复杂度** | 🟢 简单         | 🟡 中等         |
| **数据持久化** | 🟡 本地卷       | 🟢 PVC + 存储类 |
| **高可用**     | 🔴 单实例       | 🟢 主从复制     |
| **扩展性**     | 🔴 有限         | 🟢 自动扩展     |
| **监控告警**   | 🟡 基础         | 🟢 企业级       |
| **备份恢复**   | 🟡 手动         | 🟢 自动化       |
| **开发环境**   | 🟢 完美         | 🟡 过度         |
| **生产环境**   | 🟡 勉强         | 🟢 推荐         |

---

## 🎯 推荐方案

### 📝 **开发/测试环境** → Docker Compose
- 快速启动
- 简单配置
- 易于重置数据

### 🏢 **生产环境** → Kubernetes
- 数据安全
- 高可用性
- 企业级特性

---

## 💡 具体实现

### 方案 1: Docker Compose (推荐开发使用)

```yaml
# 添加到现有 docker-compose.yaml
services:
  mysql:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: projects
      MYSQL_USER: appuser
      MYSQL_PASSWORD: apppassword
    volumes:
      - mysql-data:/var/lib/mysql
      - ./mysql/init:/docker-entrypoint-initdb.d  # 初始化脚本
    networks:
      - kafka-network
    restart: unless-stopped

  # 可选：MySQL 管理界面
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: mysql
      PMA_USER: root
      PMA_PASSWORD: rootpassword
    depends_on:
      - mysql
    networks:
      - kafka-network

volumes:
  mysql-data:
```

### 方案 2: Kubernetes (推荐生产使用)

```yaml
# MySQL StatefulSet 和相关资源
apiVersion: v1
kind: Secret
metadata:
  name: mysql-secret
  namespace: infra
type: Opaque
data:
  mysql-root-password: cm9vdHBhc3N3b3Jk  # base64: rootpassword
  mysql-password: YXBwcGFzc3dvcmQ=        # base64: apppassword
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: mysql-config
  namespace: infra
data:
  my.cnf: |
    [mysqld]
    max_connections = 200
    innodb_buffer_pool_size = 128M
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
  namespace: infra
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-root-password
        - name: MYSQL_DATABASE
          value: projects
        - name: MYSQL_USER
          value: appuser
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-secret
              key: mysql-password
        volumeMounts:
        - name: mysql-data
          mountPath: /var/lib/mysql
        - name: mysql-config
          mountPath: /etc/mysql/conf.d
      volumes:
      - name: mysql-config
        configMap:
          name: mysql-config
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

---

## 🚀 基于当前架构的建议

### 推荐：**跟随 Kafka 模式** → Docker Compose

**理由**：
1. **一致性** - 与现有 Kafka 栈保持一致
2. **简单性** - 一个 compose 文件管理整个栈
3. **开发友好** - 快速重置数据库
4. **网络统一** - 共用 kafka-network

### 优化后的完整 docker-compose.yaml：

```yaml
version: '3.8'

services:
  # 现有服务...
  zookeeper: # ... 保持不变
  kafka: # ... 保持不变
  kafka-ui: # ... 保持不变
  
  # 新增 MySQL
  mysql:
    image: mysql:8.0
    container_name: mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD:-rootpassword}
      MYSQL_DATABASE: ${MYSQL_DATABASE:-projects}
      MYSQL_USER: ${MYSQL_USER:-appuser}
      MYSQL_PASSWORD: ${MYSQL_PASSWORD:-apppassword}
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - kafka-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

volumes:
  kafka-data:
  mysql-data:  # 新增
```

---

## 📋 使用场景建议

### 🟢 **用 Docker Compose 如果**：
- 开发/测试环境
- 团队较小
- 应用相对简单
- 需要快速迭代

### 🟢 **用 Kubernetes 如果**：
- 生产环境
- 需要高可用
- 数据非常重要
- 团队有 K8s 运维能力

### 🎯 **混合方案**（当前推荐）：
- MySQL + Kafka → Docker Compose（开发栈）
- Headlamp → Kubernetes（管理工具）
- 生产时再迁移数据库到 K8s





```sql
docker exec -i mysql mysql -u root -prootpassword < /Users/ganten/workspace/github/jurong/mysql/scripts/create-project-db.sql
```