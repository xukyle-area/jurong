#!/bin/bash

echo "🌊 测试 Flink 集群状态"
echo "==================="

# 检查 Flink 是否运行
if ! curl -f http://localhost:8083/ > /dev/null 2>&1; then
    echo "❌ Flink Dashboard 无法访问"
    exit 1
fi

echo "✅ Flink Dashboard 可访问"

echo ""
echo "📊 Flink 集群信息:"
echo "=================="

# 获取集群概览
echo "🔍 获取集群概览..."
curl -s http://localhost:8083/overview | python3 -m json.tool 2>/dev/null || echo "  (需要安装 python3 查看 JSON)"

echo ""
echo "👥 TaskManager 信息:"
echo "==================="

# 获取 TaskManager 列表
curl -s http://localhost:8083/taskmanagers | python3 -m json.tool 2>/dev/null || echo "  (需要安装 python3 查看 JSON)"

echo ""
echo "📋 作业列表:"
echo "==========="

# 获取作业列表  
curl -s http://localhost:8083/jobs | python3 -m json.tool 2>/dev/null || echo "  (需要安装 python3 查看 JSON)"

echo ""
echo "🔧 Flink 配置信息:"
echo "================="

# 获取配置信息
curl -s http://localhost:8083/config | python3 -m json.tool 2>/dev/null | head -20 || echo "  (需要安装 python3 查看 JSON)"

echo ""
echo "🌐 Flink Web UI: http://localhost:8083"
echo "📚 Flink 文档: https://flink.apache.org/"

echo ""
echo "💡 常用操作:"
echo "==========="
echo "  1. 提交作业: curl -X POST -H 'Content-Type: application/json' http://localhost:8083/jars/upload"
echo "  2. 查看作业: curl http://localhost:8083/jobs"
echo "  3. 取消作业: curl -X PATCH http://localhost:8083/jobs/{job-id}"

echo ""
echo "✅ Flink 测试完成!"