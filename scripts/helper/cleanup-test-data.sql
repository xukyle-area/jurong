-- 清理测试数据脚本
-- 谨慎使用：会删除测试数据

USE projects;

-- 清理用户活动日志
DELETE FROM user_activities WHERE user_id IN (
    SELECT id FROM users WHERE username LIKE 'test_%'
);

-- 清理测试订单
DELETE FROM orders WHERE user_id IN (
    SELECT id FROM users WHERE username LIKE 'test_%'
);

-- 清理测试用户
DELETE FROM users WHERE username LIKE 'test_%';

-- 清理测试产品
DELETE FROM products WHERE name LIKE 'TEST_%';

-- 重置 Kafka 消息状态（保留主题配置）
DELETE FROM kafka_message_status WHERE status = 'failed';

-- 显示清理结果
SELECT 'Test data cleanup completed' as message;
SELECT 'Remaining users:' as info;
SELECT COUNT(*) as user_count FROM users;
SELECT 'Remaining products:' as info;
SELECT COUNT(*) as product_count FROM products;
SELECT 'Remaining orders:' as info;
SELECT COUNT(*) as order_count FROM orders;