# 📁 Scripts 目录结构说明

## 🚀 scripts/start/ - 启动相关脚本

这个目录包含启动和基础操作相关的脚本：

### 📋 文件列表

- **`start-all.sh`** - 🚀 启动完整的 Kafka + MySQL 开发环境
- **`check-status.sh`** - � 检查所有服务状态  
- **`test-kafka.sh`** - 🧪 测试 Kafka 连接和功能

### 🎯 使用方法

```bash
# 启动所有服务
./scripts/start/start-all.sh

# 检查服务状态
./scripts/start/check-status.sh

# 测试 Kafka 功能
./scripts/start/test-kafka.sh
```

## 🛠️ scripts/helper/ - 辅助工具脚本

这个目录包含各种管理和辅助工具脚本：

### 📋 MySQL 相关工具
- **`manage-mysql.sh`** - 🗄️ MySQL 交互式管理工具
- **`exec-sql.sh`** - 📄 执行 SQL 文件工具
- **`add-mysql.sh`** - ➕ 向现有环境添加 MySQL 的向导

### 📋 Headlamp 相关工具
- **`deploy-headlamp-k8s.sh`** - ☸️ 部署 Headlamp 到 Kubernetes
- **`get-headlamp-token.sh`** - 🔑 获取 Headlamp 访问令牌
- 以及其他 Headlamp 管理脚本...

## 🗄️ mysql/init/ - MySQL 初始化脚本

- **`01-init.sql`** - � 基础数据库和表创建
- **`02-kafka-tables.sql`** - � Kafka 相关表创建

这些脚本会在 MySQL 容器**首次启动**时按字母顺序自动执行。