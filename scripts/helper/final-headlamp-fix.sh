#!/bin/bash

echo "🔄 Headlamp 集群连接最终解决方案"
echo ""

# 检查当前状态
echo "1. 检查 Headlamp 运行状态..."
if kubectl get pods -n infra -l app=headlamp | grep Running > /dev/null; then
    echo "✅ Headlamp pod 正在运行"
    kubectl get pods -n infra -l app=headlamp
else
    echo "❌ Headlamp pod 未运行，请重新部署"
    exit 1
fi

echo ""
echo "2. 检查 API 连接..."
kubectl logs -n infra deployment/headlamp --tail 5 | grep "Requesting"
if [ $? -eq 0 ]; then
    echo "✅ Headlamp 正在与 Kubernetes API 通信"
else
    echo "⚠️  未检测到 API 请求"
fi

echo ""
echo "3. 测试 Web 服务..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:30466)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Headlamp Web 服务响应正常"
else
    echo "❌ Headlamp Web 服务异常 (HTTP $HTTP_CODE)"
fi

echo ""
echo "🌐 现在请按照以下步骤操作："
echo ""
echo "1. 在浏览器中访问: http://localhost:30466"
echo "   (已为你在 Simple Browser 中打开)"
echo ""
echo "2. 页面加载后，等待 10-15 秒让 Headlamp 发现集群"
echo ""
echo "3. 如果仍显示 'Choose a cluster'，请尝试："
echo "   - 刷新浏览器页面 (F5 或 Cmd+R)"
echo "   - 清除浏览器缓存"
echo "   - 等待更长时间（有时需要 1-2 分钟）"
echo ""
echo "4. 正常情况下，应该会自动检测到集群并显示 Kubernetes 仪表板"
echo ""

# 提供端口转发备选方案
echo "📡 备选方案 - 端口转发："
echo "如果 NodePort 方式不工作，请在新终端中运行："
echo "kubectl port-forward -n infra service/headlamp 4466:4466"
echo "然后访问: http://localhost:4466"
echo ""

echo "🔍 故障排除："
echo "- 查看实时日志: kubectl logs -n infra deployment/headlamp -f"
echo "- 重启 Headlamp: kubectl rollout restart -n infra deployment/headlamp"
echo "- 检查权限: kubectl auth can-i '*' '*' --as=system:serviceaccount:infra:headlamp"
echo ""

# 自动打开浏览器
echo "🌐 正在为你打开 Headlamp..."
if command -v open >/dev/null 2>&1; then
    open http://localhost:30466
elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open http://localhost:30466
fi

echo ""
echo "💡 提示: Headlamp 在集群内部运行时会自动使用 ServiceAccount 认证"
echo "    这比外部 kubeconfig 方式更安全和可靠"