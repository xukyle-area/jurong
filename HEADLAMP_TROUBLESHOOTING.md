# Headlamp 故障排除指南

如果 Headlamp 显示 "There seems to be no clusters configured..." 错误，请按照以下步骤解决：

## 问题原因

Headlamp 容器内部无法访问 Docker Desktop 的 Kubernetes API Server，因为网络隔离的问题。

## 解决方案

### 方法 1：自动修复（推荐）

运行修复脚本：
```bash
./fix-headlamp.sh
```

### 方法 2：手动修复

1. **停止当前的 Headlamp 容器**
   ```bash
   docker-compose stop headlamp
   ```

2. **使用主机网络模式启动 Headlamp**
   ```bash
   docker run -d \
     --name headlamp-fixed \
     --restart unless-stopped \
     --network host \
     -v ~/.kube/config:/root/.kube/config:ro \
     -v headlamp-config:/headlamp-config \
     -e HEADLAMP_CONFIG_DIR=/headlamp-config \
     ghcr.io/kinvolk/headlamp:latest
   ```

3. **访问 Headlamp**
   ```
   http://localhost:4466
   ```

## 验证步骤

1. **确认 Kubernetes 集群运行**
   ```bash
   kubectl cluster-info
   kubectl get nodes
   ```

2. **检查 Headlamp 日志**
   ```bash
   docker logs headlamp-fixed
   ```

3. **访问 Web 界面**
   - 打开浏览器访问：http://localhost:4466
   - 应该能看到 `docker-desktop` 集群

## 如果仍然有问题

1. **重启 Docker Desktop**
   - 完全退出 Docker Desktop
   - 重新启动 Docker Desktop
   - 确保 Kubernetes 功能已启用

2. **检查防火墙设置**
   - 确保端口 4466 和 6443 未被阻止

3. **查看详细错误**
   ```bash
   docker logs headlamp-fixed --follow
   ```

## 清理

如果需要停止修复后的 Headlamp：
```bash
docker stop headlamp-fixed && docker rm headlamp-fixed
```

然后可以回到 docker-compose 方式：
```bash
docker-compose up -d headlamp
```