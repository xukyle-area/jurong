#!/bin/bash

echo "🔐 生成完整的 Headlamp 管理员令牌"
echo "=================================="

# 生成令牌并去除换行符
TOKEN=$(kubectl create token headlamp-admin -n kube-system --duration=8760h | tr -d '\n')

echo ""
echo "✅ 新的管理员令牌已生成！"
echo ""
echo "🔑 请复制以下完整令牌（一行）："
echo "=============================================="
echo "$TOKEN"
echo "=============================================="
echo ""

# 验证令牌
echo "🧪 验证令牌权限..."
if kubectl --token="$TOKEN" get pods --all-namespaces >/dev/null 2>&1; then
    echo "✅ 令牌验证成功！可以列出所有 pods"
else
    echo "❌ 令牌验证失败"
fi

echo ""
echo "📋 使用说明："
echo "1. 复制上面的完整令牌（从 eyJ 开始到末尾）"
echo "2. 在 Headlamp 中选择 Token 认证"
echo "3. 粘贴令牌并登录"
echo ""
echo "🌐 Headlamp 访问地址："
echo "- http://localhost:30466"
echo "- http://localhost:4466 (如果端口转发在运行)"
echo ""

# 保存令牌到文件
echo "$TOKEN" > /tmp/headlamp-token.txt
echo "💾 令牌已保存到: /tmp/headlamp-token.txt"