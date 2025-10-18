#!/bin/bash

echo "🔐 生成绝对干净的 Headlamp 令牌"
echo "================================"

# 生成令牌并确保完全干净
TOKEN=$(kubectl create token headlamp-admin -n kube-system --duration=8760h)

# 移除所有可能的换行符和空格
CLEAN_TOKEN=$(echo "$TOKEN" | tr -d '\n\r\t ' | sed 's/[[:space:]]//g')

echo ""
echo "✅ 干净的管理员令牌："
echo "=================================================="
echo "$CLEAN_TOKEN"
echo "=================================================="
echo ""

# 保存到文件以便复制
echo "$CLEAN_TOKEN" > /tmp/clean-token.txt
echo "💾 已保存到 /tmp/clean-token.txt"

# 验证令牌长度和格式
echo ""
echo "🔍 令牌信息："
echo "- 长度: $(echo -n "$CLEAN_TOKEN" | wc -c) 字符"
echo "- 开始: $(echo "$CLEAN_TOKEN" | cut -c1-20)..."
echo "- 结尾: ...$(echo "$CLEAN_TOKEN" | tail -c20)"

echo ""
echo "📋 现在你可以："
echo "1. 复制上面的完整令牌"
echo "2. 或者从文件复制: cat /tmp/clean-token.txt"
echo "3. 在 Headlamp 中使用 Token 认证方式登录"