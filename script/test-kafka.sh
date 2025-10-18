#!/bin/bash

echo "Testing Kafka deployment..."

# Create a test topic
echo "1. Creating test topic..."
docker exec -it kafka kafka-topics --create --topic kafka-test --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || echo "Topic may already exist"

# List topics
echo "2. Listing topics..."
docker exec -it kafka kafka-topics --list --bootstrap-server localhost:9092

echo ""
echo "3. Testing producer/consumer (this will send a test message)..."

# Send a test message
echo "Hello Kafka from Docker Desktop!" | docker exec -i kafka kafka-console-producer --topic kafka-test --bootstrap-server localhost:9092

# Read the message
echo "4. Reading messages from topic:"
timeout 5 docker exec -it kafka kafka-console-consumer --topic kafka-test --from-beginning --bootstrap-server localhost:9092 --max-messages 1

echo ""
echo "✅ Kafka deployment test completed!"
echo ""
echo "Access points:"
echo "- Kafka: localhost:9092"
echo "- ZooKeeper: localhost:2181"  
echo "- Kafka UI: http://localhost:8080"
echo ""
echo "Try opening http://localhost:8080 in your browser to access the Kafka UI!"