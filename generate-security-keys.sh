#!/bin/bash
# AdminPlus Security Key Generation Script
# 用于生成 JWT 和前端加密所需的安全密钥

set -e

echo "=========================================="
echo "AdminPlus 安全密钥生成工具"
echo "=========================================="
echo ""

# 检查是否安装了 OpenSSL
if ! command -v openssl &> /dev/null; then
    echo "错误：未找到 OpenSSL，请先安装 OpenSSL"
    echo "  Ubuntu/Debian: sudo apt-get install openssl"
    echo "  CentOS/RHEL: sudo yum install openssl"
    echo "  macOS: brew install openssl"
    exit 1
fi

# 生成前端加密密钥
echo "1. 生成前端加密密钥（32 字节，Base64 编码）"
echo "   用途：前端敏感数据加密"
echo ""
ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "生成的密钥："
echo "$ENCRYPTION_KEY"
echo ""
echo "请将以下配置添加到前端 .env.production 文件："
echo "VITE_ENCRYPTION_KEY=$ENCRYPTION_KEY"
echo ""
read -p "按 Enter 继续..."
echo ""

# 生成 JWT RSA 密钥对
echo "2. 生成 JWT RSA 密钥对（2048 位）"
echo "   用途：JWT Token 签名和验证"
echo ""

# 生成私钥
echo "生成 RSA 私钥..."
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out jwt_private.pem 2>/dev/null
echo "私钥已保存到：jwt_private.pem"

# 生成公钥
echo "生成 RSA 公钥..."
openssl rsa -in jwt_private.pem -pubout -out jwt_public.pem 2>/dev/null
echo "公钥已保存到：jwt_public.pem"

# 转换为 JWK 格式（需要 Java 环境）
echo ""
echo "3. 转换为 JWK 格式（可选）"
echo "   用途：Spring Security OAuth2 JWT 配置"
echo ""

if command -v java &> /dev/null; then
    echo "检测到 Java 环境，正在转换..."
    # 这里需要实际运行 Java 代码来转换，暂时跳过
    echo "注意：完整的 JWK 转换需要 JOSE 库支持"
    echo "请参考 SECURITY_FIXES.md 中的说明手动转换"
else
    echo "未检测到 Java 环境，跳过 JWK 转换"
    echo "请参考 SECURITY_FIXES.md 中的说明手动转换"
fi

echo ""
echo "=========================================="
echo "生成完成！"
echo "=========================================="
echo ""
echo "已生成的文件："
echo "  - jwt_private.pem  (JWT 私钥，保密！)"
echo "  - jwt_public.pem   (JWT 公钥，可公开)"
echo ""
echo "下一步："
echo "1. 将前端加密密钥添加到 frontend/.env.production"
echo "2. 将 JWT 密钥配置为环境变量 JWT_SECRET"
echo "3. 配置 CORS_ALLOWED_ORIGINS 环境变量"
echo ""
echo "详细说明请参考：SECURITY_FIXES.md"
echo ""
echo "安全提示："
echo "  - jwt_private.pem 必须妥善保管，不可泄露"
echo "  - 定期轮换密钥（建议每 6-12 个月）"
echo "  - 不要将密钥提交到版本控制系统"
echo ""

# 清理确认
read -p "是否删除生成的密钥文件？(y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f jwt_private.pem jwt_public.pem
    echo "密钥文件已删除"
else
    echo "密钥文件保留在当前目录"
    echo "  - jwt_private.pem"
    echo "  - jwt_public.pem"
fi

echo ""
echo "完成！"