# 📁 MySQL 脚本重新组织说明

## 🏗️ 新的目录结构

### 📋 **scripts/start/** - 启动时自动执行的脚本
```
scripts/start/
├── 01-init.sql         # 基础数据库和表结构
└── 02-kafka-tables.sql # Kafka 相关表结构
```

**特点**：
- ✅ Docker Compose 启动时**自动执行**
- ✅ 按文件名**字母顺序**执行
- ✅ 仅在 MySQL 容器**首次启动**时执行
- ✅ 用于创建**必需的基础结构**

### 🛠️ **scripts/helper/** - 辅助管理脚本
```
scripts/helper/
├── manage-mysql.sh         # 交互式 MySQL 管理工具
├── exec-sql.sh            # SQL 文件执行工具
├── add-mysql.sh           # MySQL 添加指南脚本
├── create-project-db.sql  # 项目管理数据库示例
└── cleanup-test-data.sql  # 测试数据清理脚本
```

**特点**：
- 🔧 **手动执行**的辅助工具
- 🔧 用于**开发和维护**阶段
- 🔧 **可选功能**，不影响基础系统

## 🚀 使用方法

### **启动时自动执行**
```bash
# 重新初始化数据库（会删除所有数据）
docker-compose down -v
docker-compose up -d

# scripts/start/ 中的脚本会自动按顺序执行
```

### **手动执行辅助脚本**
```bash
# 交互式管理 MySQL
./scripts/helper/manage-mysql.sh

# 执行自定义 SQL 文件
./scripts/helper/exec-sql.sh ./scripts/helper/create-project-db.sql

# 清理测试数据
./scripts/helper/exec-sql.sh ./scripts/helper/cleanup-test-data.sql
```

## 🎯 配置更新

### **docker-compose.yaml 更新**
```yaml
mysql:
  volumes:
    - mysql-data:/var/lib/mysql
    - ./scripts/start:/docker-entrypoint-initdb.d  # 新路径
```

**变更**：
- ❌ 旧路径：`./mysql/init:/docker-entrypoint-initdb.d`
- ✅ 新路径：`./scripts/start:/docker-entrypoint-initdb.d`

## 📚 脚本分类说明

### 🔄 **自动执行脚本** (scripts/start/)
- **目的**：确保基础数据结构存在
- **时机**：MySQL 容器首次启动
- **内容**：数据库、表、索引、基础数据
- **原则**：轻量、必需、稳定

### 🛠️ **辅助管理脚本** (scripts/helper/)
- **目的**：开发和维护阶段使用
- **时机**：根据需要手动执行
- **内容**：测试数据、示例数据库、清理工具
- **原则**：灵活、可选、实用

## ✅ 优势

1. **🎯 职责明确**：启动脚本 vs 辅助工具分离
2. **🚀 启动快速**：只执行必需的初始化
3. **🛠️ 灵活管理**：丰富的辅助工具集
4. **📁 结构清晰**：按用途组织文件
5. **🔧 易于维护**：相关脚本集中管理

## 🔄 迁移完成

- ✅ 启动脚本已移至 `scripts/start/`
- ✅ 辅助脚本已移至 `scripts/helper/`
- ✅ Docker Compose 配置已更新
- ✅ 原 `mysql/init/` 目录可以删除