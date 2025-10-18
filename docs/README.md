# 📚 项目文档索引

## 📖 文档说明

本目录包含了所有项目相关的技术文档和指南。

## 📋 文档列表

### 🏗️ **架构和部署**
- **[ARCHITECTURE_CLEANUP.md](./ARCHITECTURE_CLEANUP.md)** - 清理后的架构说明，解决重复 Headlamp 问题
- **[DOCKER_COMPOSE_VS_K8S.md](./DOCKER_COMPOSE_VS_K8S.md)** - Docker Compose 与 Kubernetes 架构对比

### ⚙️ **服务部署指南**
- **[KAFKA_DEPLOYMENT.md](./KAFKA_DEPLOYMENT.md)** - Kafka 集群部署完整指南
- **[MYSQL_DEPLOYMENT_GUIDE.md](./MYSQL_DEPLOYMENT_GUIDE.md)** - MySQL 数据库部署指南

### 🔧 **故障排除**
- **[HEADLAMP_TROUBLESHOOTING.md](./HEADLAMP_TROUBLESHOOTING.md)** - Headlamp Kubernetes 管理界面故障排除

## 🎯 快速导航

### 新用户入门：
1. 📖 先阅读 [ARCHITECTURE_CLEANUP.md](./ARCHITECTURE_CLEANUP.md) 了解整体架构
2. 🚀 按照 [KAFKA_DEPLOYMENT.md](./KAFKA_DEPLOYMENT.md) 部署 Kafka 环境
3. 🗄️ 根据需要参考 [MYSQL_DEPLOYMENT_GUIDE.md](./MYSQL_DEPLOYMENT_GUIDE.md) 添加数据库

### 问题排查：
- 🔧 Headlamp 访问问题 → [HEADLAMP_TROUBLESHOOTING.md](./HEADLAMP_TROUBLESHOOTING.md)
- 🏗️ 架构选择困惑 → [DOCKER_COMPOSE_VS_K8S.md](./DOCKER_COMPOSE_VS_K8S.md)

## 📁 相关目录

- **[../scripts/](../scripts/)** - 部署和管理脚本
- **[../deployments/](../deployments/)** - Kubernetes 部署配置文件
- **[../mysql/](../mysql/)** - MySQL 初始化脚本

## 🔄 文档维护

所有文档都应该放在此 `docs` 目录中，保持项目结构的整洁性。

## 📞 支持

如果文档中有任何不清楚的地方，请检查：
1. 相关的脚本文件
2. 容器日志 (`docker-compose logs -f [service]`)
3. Kubernetes 日志 (`kubectl logs -f [pod]`)

---

*最后更新：2025年10月19日*