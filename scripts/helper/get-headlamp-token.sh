#!/bin/bash

echo "🔐 Headlamp 登录令牌获取指南"
echo ""

echo "方法 1: 使用现有的 default ServiceAccount (推荐)"
echo "================================================"

# 创建一个临时 token
echo "正在为 default ServiceAccount 创建临时令牌..."
TOKEN=$(kubectl create token default --duration=24h 2>/dev/null)

if [ -n "$TOKEN" ]; then
    echo "✅ 令牌创建成功!"
    echo ""
    echo "🔑 复制以下令牌用于 Headlamp 登录:"
    echo "================================================"
    echo "$TOKEN"
    echo "================================================"
    echo ""
else
    echo "⚠️  方法 1 失败，尝试方法 2..."
fi

echo "方法 2: 获取集群管理员令牌"
echo "==============================="

# 创建一个管理员用户
cat << EOF | kubectl apply -f - 2>/dev/null
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF

sleep 2

# 创建令牌
ADMIN_TOKEN=$(kubectl create token admin-user -n kube-system --duration=24h 2>/dev/null)

if [ -n "$ADMIN_TOKEN" ]; then
    echo "✅ 管理员令牌创建成功!"
    echo ""
    echo "🔑 复制以下管理员令牌用于 Headlamp 登录:"
    echo "================================================"
    echo "$ADMIN_TOKEN"
    echo "================================================"
    echo ""
else
    echo "❌ 令牌创建失败"
fi

echo "📋 使用说明:"
echo "============"
echo "1. 复制上面的令牌"
echo "2. 在 Headlamp 登录页面，选择 'Token' 认证方式"
echo "3. 粘贴令牌到输入框中"
echo "4. 点击登录"
echo ""

echo "🌐 Headlamp 访问地址:"
echo "- NodePort: http://localhost:30466"
echo "- 端口转发: http://localhost:4466"
echo ""

echo "💡 提示:"
echo "- 令牌有效期为 24 小时"
echo "- 如果令牌过期，重新运行此脚本获取新令牌"
echo "- 使用管理员令牌可以访问所有集群资源"
echo ""

echo "🔍 如果仍然有问题:"
echo "- 确保 Headlamp 服务正在运行: kubectl get pods -n infra"
echo "- 查看 Headlamp 日志: kubectl logs -n infra deployment/headlamp"
echo "- 重启 Headlamp: kubectl rollout restart -n infra deployment/headlamp"