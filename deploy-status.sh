#!/bin/bash

echo "=== AdminPlus 部署状态监控 ==="
echo ""

# 检查容器状态
echo "1. Docker 容器状态:"
docker ps | grep adminplus

echo ""

# 检查后端服务健康状态
echo "2. 后端服务健康检查:"
curl -s http://localhost:8081/api/actuator/health | jq . 2>/dev/null || echo "后端服务未启动或不可用"

echo ""

# 检查前端服务健康状态
echo "3. 前端服务健康检查:"
curl -s http://localhost/ | head -5 2>/dev/null || echo "前端服务未启动或不可用"

echo ""

# 检查数据库连接
echo "4. 数据库连接检查:"
docker exec adminplus-postgres pg_isready -U postgres 2>/dev/null && echo "✅ 数据库连接正常" || echo "❌ 数据库连接失败"

echo ""

# 检查Redis连接
echo "5. Redis连接检查:"
docker exec adminplus-redis redis-cli ping 2>/dev/null && echo "✅ Redis连接正常" || echo "❌ Redis连接失败"

echo ""
echo "=== 部署状态监控完成 ==="