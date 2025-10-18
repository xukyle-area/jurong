#!/bin/bash

echo "🔴 测试 Redis 连接和功能"
echo "======================"

# 检查 Redis 是否运行
if ! docker exec redis redis-cli -a redispassword ping > /dev/null 2>&1; then
    echo "❌ Redis 未运行或连接失败"
    exit 1
fi

echo "✅ Redis 连接正常"

echo ""
echo "🧪 执行基本测试:"

# 设置测试数据
echo "1. 设置键值对..."
docker exec redis redis-cli -a redispassword set test:key "Hello Redis!" > /dev/null 2>&1
docker exec redis redis-cli -a redispassword set test:counter 0 > /dev/null 2>&1

# 读取数据
echo "2. 读取数据..."
value=$(docker exec redis redis-cli -a redispassword get test:key 2>/dev/null)
echo "   test:key = $value"

# 增量操作
echo "3. 测试计数器..."
docker exec redis redis-cli -a redispassword incr test:counter > /dev/null 2>&1
docker exec redis redis-cli -a redispassword incr test:counter > /dev/null 2>&1
counter=$(docker exec redis redis-cli -a redispassword get test:counter 2>/dev/null)
echo "   test:counter = $counter"

# 列表操作
echo "4. 测试列表..."
docker exec redis redis-cli -a redispassword lpush test:list "item1" "item2" "item3" > /dev/null 2>&1
list_length=$(docker exec redis redis-cli -a redispassword llen test:list 2>/dev/null)
echo "   test:list 长度 = $list_length"

# 哈希操作
echo "5. 测试哈希..."
docker exec redis redis-cli -a redispassword hset test:hash name "Redis" version "7.0" > /dev/null 2>&1
hash_name=$(docker exec redis redis-cli -a redispassword hget test:hash name 2>/dev/null)
echo "   test:hash.name = $hash_name"

# 过期时间
echo "6. 测试过期时间..."
docker exec redis redis-cli -a redispassword setex test:expire 10 "will expire in 10 seconds" > /dev/null 2>&1
ttl=$(docker exec redis redis-cli -a redispassword ttl test:expire 2>/dev/null)
echo "   test:expire TTL = ${ttl}s"

echo ""
echo "📊 Redis 信息:"
echo "=============="
docker exec redis redis-cli -a redispassword info server 2>/dev/null | grep -E "redis_version|os|arch|process_id"

echo ""
echo "🔑 当前键数量:"
key_count=$(docker exec redis redis-cli -a redispassword dbsize 2>/dev/null)
echo "   数据库中共有 $key_count 个键"

echo ""
echo "🌐 访问 Redis Commander: http://localhost:8082"
echo "🔌 Redis 连接信息: localhost:6379 (密码: redispassword)"

echo ""
echo "✅ Redis 测试完成!"