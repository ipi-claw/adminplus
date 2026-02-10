#!/bin/bash

# 检查应用启动日志和数据初始化状态

echo "=========================================="
echo "检查 AdminPlus 启动日志"
echo "=========================================="

# 检查容器状态
echo ""
echo "容器状态:"
docker-compose ps

# 检查后端应用日志
echo ""
echo "后端应用日志（最后50行）:"
docker-compose logs --tail=50 backend

# 检查数据初始化相关日志
echo ""
echo "数据初始化相关日志:"
docker-compose logs backend | grep -i "初始化\|initialization\|data" | tail -20

# 检查健康状态
echo ""
echo "应用健康状态:"
curl -s http://localhost:8081/api/actuator/health | jq . 2>/dev/null || curl -s http://localhost:8081/api/actuator/health

echo ""
echo "=========================================="
echo "检查完成"
echo "=========================================="