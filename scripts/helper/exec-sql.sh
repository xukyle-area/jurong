#!/bin/bash

echo "🚀 执行 MySQL SQL 文件"
echo "===================="

if [ $# -eq 0 ]; then
    echo "用法: $0 <sql文件路径> [数据库名]"
    echo ""
    echo "示例:"
    echo "  $0 ./mysql/scripts/create-project-db.sql"
    echo "  $0 ./my-script.sql projects"
    echo ""
    echo "📁 可用的 SQL 脚本:"
    find ./mysql -name "*.sql" 2>/dev/null || echo "  (未找到 SQL 文件)"
    exit 1
fi

sql_file="$1"
database="$2"

# 检查文件是否存在
if [ ! -f "$sql_file" ]; then
    echo "❌ 文件不存在: $sql_file"
    exit 1
fi

# 检查 MySQL 是否运行
if ! docker exec mysql mysqladmin ping -h localhost --silent; then
    echo "❌ MySQL 未运行，请先启动服务: docker-compose up -d mysql"
    exit 1
fi

echo "📄 执行 SQL 文件: $sql_file"
if [ -n "$database" ]; then
    echo "🗄️ 目标数据库: $database"
    docker exec -i mysql mysql -u root -prootpassword "$database" < "$sql_file"
else
    echo "🗄️ 使用默认连接"
    docker exec -i mysql mysql -u root -prootpassword < "$sql_file"
fi

if [ $? -eq 0 ]; then
    echo "✅ SQL 执行完成!"
else
    echo "❌ SQL 执行失败"
    exit 1
fi