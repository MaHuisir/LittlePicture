#!/bin/bash

# 小图宝 - 快速启动脚本

echo ""
echo "╔════════════════════════════════════════╗"
echo "║     小图宝 - 智能图片压缩工具          ║"
echo "║     Little Picture - Image Compressor  ║"
echo "╚════════════════════════════════════════╝"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未找到 Node.js"
    echo "请先安装 Node.js: https://nodejs.org"
    exit 1
fi

echo "✅ Node.js 已安装"
node --version
echo ""

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未找到 npm"
    exit 1
fi

echo "✅ npm 已安装"
npm --version
echo ""

# 检查 node_modules
if [ ! -d "node_modules" ]; then
    echo "📦 正在安装依赖..."
    npm install
    if [ $? -ne 0 ]; then
        echo "❌ 依赖安装失败"
        exit 1
    fi
    echo "✅ 依赖安装完成"
else
    echo "✅ 依赖已安装"
fi

echo ""
echo "🚀 启动开发服务器..."
echo "📍 访问地址: http://localhost:5173"
echo ""
echo "按 Ctrl+C 停止服务器"
echo ""

npm run dev
