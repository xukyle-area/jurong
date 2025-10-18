#!/bin/bash

echo "🗄️ MySQL 数据库管理工具"
echo "========================"

# 检查 MySQL 是否运行
if ! docker exec mysql mysqladmin ping -h localhost --silent; then
    echo "❌ MySQL 未运行，请先启动服务"
    exit 1
fi

echo "📋 选择操作:"
echo "1. 创建新数据库"
echo "2. 创建新表"
echo "3. 查看所有数据库"
echo "4. 查看指定数据库的表"
echo "5. 执行自定义 SQL"
echo "6. 进入 MySQL 交互模式"

read -p "请选择 (1-6): " choice

case $choice in
    1)
        read -p "输入新数据库名: " dbname
        docker exec mysql mysql -u root -prootpassword -e "CREATE DATABASE $dbname;"
        echo "✅ 数据库 '$dbname' 创建成功"
        ;;
    2)
        read -p "输入数据库名: " dbname
        read -p "输入表名: " tablename
        echo "请输入表结构 (例: id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(50)):"
        read -p "字段定义: " fields
        docker exec mysql mysql -u root -prootpassword -e "USE $dbname; CREATE TABLE $tablename ($fields);"
        echo "✅ 表 '$tablename' 在数据库 '$dbname' 中创建成功"
        ;;
    3)
        echo "📚 所有数据库:"
        docker exec mysql mysql -u root -prootpassword -e "SHOW DATABASES;"
        ;;
    4)
        read -p "输入数据库名: " dbname
        echo "📋 数据库 '$dbname' 中的表:"
        docker exec mysql mysql -u root -prootpassword -e "USE $dbname; SHOW TABLES;"
        ;;
    5)
        read -p "输入数据库名 (可选): " dbname
        echo "请输入 SQL 语句:"
        read -p "SQL: " sql
        if [ -z "$dbname" ]; then
            docker exec mysql mysql -u root -prootpassword -e "$sql"
        else
            docker exec mysql mysql -u root -prootpassword -e "USE $dbname; $sql"
        fi
        ;;
    6)
        echo "🚀 进入 MySQL 交互模式 (输入 'exit' 退出):"
        docker exec -it mysql mysql -u root -prootpassword
        ;;
    *)
        echo "❌ 无效选择"
        ;;
esac