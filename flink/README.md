# 📁 Flink 目录说明

## 📋 文件用途

### 🚀 **核心部署文件**（必需）

1. **`deploy-k8s-complete.sh`** ⭐ 
   - **主要部署脚本**，大部分用户使用这个
   - 一键部署完整数据平台
   - 包含部署、状态检查、清理等功能

2. **`k8s-complete-stack.yaml`** ⭐
   - **完整服务栈配置**
   - 包含：Kafka、ZooKeeper、MySQL、Redis、phpMyAdmin、Redis Commander、Kafka UI
   - 用于标准 Kubernetes 集群部署

3. **`k8s-flink.yaml`** ⭐
   - **Flink 集群配置**  
   - JobManager + TaskManager 部署
   - 与完整服务栈分离，可单独管理

### 🌊 **AWS EMR 集成**（可选）

4. **`deploy.sh`**
   - AWS EMR on EKS + Flink Operator 部署脚本
   - 适用于需要 AWS EMR 环境的用户

5. **`setup-emr-flink.sh`**
   - EMR 环境初始化脚本
   - 创建 EKS 集群、配置 EMR

6. **`flink-emr-deployment.yaml`**
   - EMR Flink 集群配置
   - 生产级 EMR 部署配置

## 🎯 使用指南

### 普通用户（推荐）
```bash
# 完整平台部署
./deploy-k8s-complete.sh deploy

# 查看状态
./deploy-k8s-complete.sh status

# 清理环境
./deploy-k8s-complete.sh cleanup
```

### AWS EMR 用户
```bash
# 设置 EMR 环境
./setup-emr-flink.sh

# 部署 EMR Flink
./deploy.sh
```

### 开发者
```bash
# 只部署基础设施
./deploy-k8s-complete.sh infrastructure

# 单独部署 Flink
./deploy-k8s-complete.sh flink

```

## 🔍 文件依赖关系

```
deploy-k8s-complete.sh
├── k8s-complete-stack.yaml  (基础设施)
└── k8s-flink.yaml          (Flink 集群)

deploy.sh
├── setup-emr-flink.sh      (EMR 环境)
└── flink-emr-deployment.yaml (EMR Flink)

```

## 💡 最佳实践

- **新用户**: 从 `deploy-k8s-complete.sh` 开始
- **生产环境**: 考虑使用 AWS EMR 方案
- **开发测试**: 使用分步部署，便于调试

---

🚀 **开始使用**: `./deploy-k8s-complete.sh deploy`