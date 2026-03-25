@echo off
REM 小图宝 - 快速启动脚本

echo.
echo ╔════════════════════════════════════════╗
echo ║     小图宝 - 智能图片压缩工具          ║
echo ║     Little Picture - Image Compressor  ║
echo ╚════════════════════════════════════════╝
echo.

REM 检查 Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 Node.js
    echo 请先安装 Node.js: https://nodejs.org
    pause
    exit /b 1
)

echo ✅ Node.js 已安装
node --version
echo.

REM 检查 npm
where npm >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未找到 npm
    pause
    exit /b 1
)

echo ✅ npm 已安装
npm --version
echo.

REM 检查 node_modules
if not exist "node_modules" (
    echo 📦 正在安装依赖...
    call npm install
    if %errorlevel% neq 0 (
        echo ❌ 依赖安装失败
        pause
        exit /b 1
    )
    echo ✅ 依赖安装完成
) else (
    echo ✅ 依赖已安装
)

echo.
echo 🚀 启动开发服务器...
echo 📍 访问地址: http://localhost:5173
echo.
echo 按 Ctrl+C 停止服务器
echo.

call npm run dev

pause
