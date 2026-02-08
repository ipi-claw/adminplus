#!/bin/bash

# AdminPlus Dashboard 修复部署脚本
# 自动化重新编译和部署修复后的代码

echo "========================================="
echo "AdminPlus Dashboard 修复部署脚本"
echo "========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 进入项目目录
cd /root/.openclaw/workspace/AdminPlus

# 检查 Docker 是否运行
echo "检查 Docker 服务状态..."
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}✗${NC} Docker 服务未运行，请先启动 Docker"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker 服务运行正常"
echo ""

# 1. 重新编译前端
echo "========================================="
echo "1. 重新编译前端"
echo "========================================="
cd frontend

echo "清理前端构建缓存..."
rm -rf dist node_modules/.vite

echo "安装依赖..."
if npm install; then
    echo -e "${GREEN}✓${NC} 依赖安装成功"
else
    echo -e "${RED}✗${NC} 依赖安装失败"
    exit 1
fi

echo "构建前端生产版本..."
if npm run build; then
    echo -e "${GREEN}✓${NC} 前端构建成功"
else
    echo -e "${RED}✗${NC} 前端构建失败"
    exit 1
fi

echo "检查构建产物..."
if [ -d "dist" ] && [ -f "dist/index.html" ]; then
    echo -e "${GREEN}✓${NC} 构建产物检查通过"
else
    echo -e "${RED}✗${NC} 构建产物检查失败"
    exit 1
fi

cd ..
echo ""

# 2. 重新构建后端
echo "========================================="
echo "2. 重新构建后端"
echo "========================================="
cd backend

echo "清理后端构建缓存..."
mvn clean

echo "构建后端 JAR 包..."
if mvn package -DskipTests; then
    echo -e "${GREEN}✓${NC} 后端构建成功"
else
    echo -e "${RED}✗${NC} 后端构建失败"
    exit 1
fi

echo "检查构建产物..."
if [ -f "target/adminplus-1.0.0.jar" ]; then
    echo -e "${GREEN}✓${NC} 构建产物检查通过"
else
    echo -e "${RED}✗${NC} 构建产物检查失败"
    exit 1
fi

cd ..
echo ""

# 3. 重启服务
echo "========================================="
echo "3. 重启服务"
echo "========================================="

# 检查 docker-compose 是否存在
if [ -f "docker-compose.yml" ]; then
    echo "使用 Docker Compose 重启服务..."

    # 停止服务
    echo "停止服务..."
    if docker-compose down; then
        echo -e "${GREEN}✓${NC} 服务停止成功"
    else
        echo -e "${RED}✗${NC} 服务停止失败"
        exit 1
    fi

    # 构建并启动服务
    echo "构建并启动服务..."
    if docker-compose up -d --build; then
        echo -e "${GREEN}✓${NC} 服务启动成功"
    else
        echo -e "${RED}✗${NC} 服务启动失败"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠${NC} 未找到 docker-compose.yml 文件"
    echo "请手动重启服务"
fi

echo ""

# 4. 验证服务状态
echo "========================================="
echo "4. 验证服务状态"
echo "========================================="
echo "等待服务启动..."
sleep 10

echo "检查容器状态..."
docker ps --filter "name=adminplus" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "检查后端日志（最近 20 行）..."
docker logs --tail 20 adminplus-backend 2>/dev/null || echo -e "${YELLOW}⚠${NC} 无法获取后端日志"

echo ""
echo "检查前端日志（最近 20 行）..."
docker logs --tail 20 adminplus-frontend 2>/dev/null || echo -e "${YELLOW}⚠${NC} 无法获取前端日志"

echo ""
echo "========================================="
echo "部署完成"
echo "========================================="
echo ""
echo "下一步验证步骤："
echo ""
echo "1. 打开浏览器访问 Dashboard 页面"
echo "   URL: http://localhost / http://your-server-ip"
echo ""
echo "2. 清除浏览器缓存"
echo "   - 打开开发者工具（F12）"
echo "   - 右键点击刷新按钮"
echo "   - 选择"清空缓存并硬性重新加载""
echo "   - 或使用快捷键: Ctrl + Shift + R (Windows) / Cmd + Shift + R (Mac)"
echo ""
echo "3. 查看浏览器控制台日志"
echo "   - 打开开发者工具（F12）"
echo "   - 切换到 Console 标签"
echo "   - 查看 [Dashboard]、[API Dashboard]、[Request] 日志"
echo ""
echo "4. 查看网络请求"
echo "   - 打开开发者工具（F12）"
echo "   - 切换到 Network 标签"
echo "   - 刷新页面，查看 API 请求状态"
echo ""
echo "5. 查看后端日志"
echo "   - 运行: docker logs -f adminplus-backend"
echo "   - 查找 Dashboard 相关日志"
echo ""
echo "6. 如果仍然有问题，请查看详细的修复报告："
echo "   - 文件: DASHBOARD_FIX_REPORT.md"
echo ""
echo "调试日志说明："
echo "  [Dashboard] - Dashboard 组件内部日志"
echo "  [API Dashboard] - API 调用日志"
echo "  [Request] - HTTP 请求/响应日志"
echo ""
echo "常见问题排查："
echo "  - 接口返回 404: 检查 Nginx 代理配置"
echo "  - 接口返回 500: 查看后端日志中的错误堆栈"
echo "  - 显示"暂无数据": 检查数据库中是否有数据"
echo "  - 图表不显示: 检查浏览器控制台是否有错误"
echo ""