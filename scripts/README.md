# Scripts 目录

这个目录包含了本项目的所有脚本文件，用于部署和管理 Kafka 和 Headlamp 服务。

## 📁 脚本分类

### Kafka 相关脚本
- **`test-kafka.sh`** - 测试 Kafka 部署和功能

### Headlamp 相关脚本
- **`deploy-headlamp-k8s.sh`** - 在 Kubernetes 中部署 Headlamp
- **`start-headlamp.sh`** - 使用 Docker Compose 启动 Headlamp
- **`verify-headlamp.sh`** - 验证 Headlamp 部署状态
- **`fix-headlamp.sh`** - 修复 Headlamp 网络连接问题
- **`final-headlamp-fix.sh`** - 最终解决方案脚本
- **`test-headlamp-connection.sh`** - 测试 Headlamp 连接
- **`headlamp-access-options.sh`** - 展示所有 Headlamp 访问方式

### Token 相关脚本
- **`get-headlamp-token.sh`** - 获取 Headlamp 登录令牌
- **`generate-clean-token.sh`** - 生成干净的管理员令牌
- **`clean-token.sh`** - 生成绝对干净的令牌

## 🚀 使用方法

所有脚本都可以直接执行：

```bash
# 例如，测试 Kafka
./scripts/test-kafka.sh

# 部署 Headlamp
./scripts/deploy-headlamp-k8s.sh

# 获取登录令牌
./scripts/generate-clean-token.sh
```

## 💡 提示

- 所有脚本都有执行权限
- 脚本会提供详细的输出和说明
- 如果遇到权限问题，使用 `chmod +x scripts/*.sh` 重新设置权限