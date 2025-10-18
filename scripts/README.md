# 📁 Scripts 目录结构说明

## 📋 概览

Scripts 目录包含了 Kubernetes 数据平台的辅助管理脚本。

> **注意**: 主要的部署和管理功能已经集成到了根目录的 `switch-env.sh` 和 `flink/deploy-k8s-complete.sh` 中。

## 🛠️ scripts/helper/ - Kubernetes 辅助工具

这个目录包含专门的 Kubernetes 管理工具脚本：

### 📋 Headlamp Kubernetes 管理界面
- **`deploy-headlamp-k8s.sh`** - ☸️ 部署 Headlamp 到 Kubernetes 集群
- **`get-headlamp-token.sh`** - 🔑 获取 Headlamp 访问令牌
- **`headlamp-access-options.sh`** - 🌐 显示 Headlamp 访问选项
- **`verify-headlamp.sh`** - ✅ 验证 Headlamp 部署状态

### 📋 AWS EMR + Flink 集群管理
- **`manage-emr-flink.sh`** - 🌊 EMR on EKS + Flink 集群管理工具

### 🎯 使用方法

```bash
# 部署 Headlamp Kubernetes 管理界面
./scripts/helper/deploy-headlamp-k8s.sh

# 获取 Headlamp 访问令牌
./scripts/helper/get-headlamp-token.sh

# 管理 EMR Flink 集群
./scripts/helper/manage-emr-flink.sh status
```

## 🗄️ mysql/init/ - MySQL 初始化脚本

数据库初始化脚本位于 `mysql/init/` 目录：

- **`01-init.sql`** - 📊 基础数据库和表创建
- **`02-kafka-tables.sql`** - 📨 Kafka 相关表创建

这些脚本会在 MySQL Pod **首次启动**时按字母顺序自动执行。

## 🚀 主要工具对比

| 功能                | 推荐工具                                  | 备用工具                                |
| ------------------- | ----------------------------------------- | --------------------------------------- |
| **平台部署**        | `./switch-env.sh deploy`                  | `./flink/deploy-k8s-complete.sh deploy` |
| **状态查看**        | `./switch-env.sh status`                  | `kubectl get pods -n data-platform`     |
| **端口转发**        | `./switch-env.sh port-forward`            | 手动 `kubectl port-forward`             |
| **Kubernetes 管理** | `./scripts/helper/deploy-headlamp-k8s.sh` | `kubectl` 命令行                        |
| **EMR 管理**        | `./scripts/helper/manage-emr-flink.sh`    | AWS 控制台                              |

## 📚 相关文档

- **[根目录 README.md](../README.md)** - 项目总览和快速开始
- **[DATA_PLATFORM_GUIDE.md](../DATA_PLATFORM_GUIDE.md)** - 完整使用指南  
- **[docs/](../docs/)** - 详细技术文档

---

💡 **提示**: 大部分日常操作建议使用根目录的主要脚本，这里的脚本主要用于特殊场景和高级管理。