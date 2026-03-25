# 🚀 小图宝 - 快速开始指南

## 📋 前置要求

- Node.js 16+ （[下载](https://nodejs.org)）
- npm 7+ 或 yarn
- 现代浏览器（Chrome、Firefox、Safari、Edge）

## ⚡ 快速启动（3 步）

### 1️⃣ 安装依赖

```bash
npm install
```

### 2️⃣ 启动开发服务器

**Windows:**
```bash
start.bat
```

**macOS/Linux:**
```bash
chmod +x start.sh
./start.sh
```

**或直接运行:**
```bash
npm run dev
```

### 3️⃣ 打开浏览器

访问 `http://localhost:5173`

## 📦 构建生产版本

```bash
npm run build
```

生成的文件在 `dist` 文件夹中。

## 🌐 部署到 Netlify

### 方式 1：自动部署（推荐）

1. 推送代码到 GitHub
2. 在 [Netlify](https://netlify.com) 连接 GitHub 仓库
3. 自动部署完成！

### 方式 2：手动部署

```bash
npm install -g netlify-cli
netlify login
netlify deploy --prod
```

### 方式 3：拖拽部署

1. 运行 `npm run build`
2. 将 `dist` 文件夹拖拽到 [Netlify](https://netlify.com)

## 📁 项目结构

```
little-picture/
├── src/
│   ├── App.vue          # 主应用（所有功能）
│   ├── main.js          # 入口
│   └── style.css        # 全局样式
├── public/
│   └── favicon.svg      # 网站图标
├── index.html           # HTML 模板
├── vite.config.js       # Vite 配置
├── netlify.toml         # Netlify 配置
├── package.json         # 依赖
├── start.bat            # Windows 启动脚本
├── start.sh             # macOS/Linux 启动脚本
├── README.md            # 项目文档
├── DEPLOY.md            # 部署指南
└── QUICKSTART.md        # 本文件
```

## 🎨 功能一览

✅ 拖拽上传  
✅ 批量处理  
✅ 质量控制  
✅ 尺寸优化  
✅ 实时预估  
✅ 本地处理  
✅ 响应式设计  
✅ 科技美学  

## 🔧 常用命令

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动开发服务器 |
| `npm run build` | 构建生产版本 |
| `npm run preview` | 预览生产构建 |
| `npm install` | 安装依赖 |
| `npm update` | 更新依赖 |

## 🐛 常见问题

**Q: 启动时出现 "command not found"**  
A: 确保已安装 Node.js，运行 `node --version` 检查

**Q: 端口 5173 已被占用**  
A: Vite 会自动使用下一个可用端口

**Q: 构建失败**  
A: 运行 `npm install` 重新安装依赖

**Q: 如何修改端口？**  
A: 编辑 `vite.config.js` 中的 `server.port`

## 📚 更多资源

- [Vue 3 文档](https://vuejs.org)
- [Vite 文档](https://vitejs.dev)
- [Netlify 文档](https://docs.netlify.com)
- [browser-image-compression](https://github.com/Donaldcwl/browser-image-compression)

## 💡 开发提示

### 热更新
修改代码后会自动刷新浏览器（HMR）

### 调试
打开浏览器开发者工具（F12）查看控制台

### 性能
使用 Chrome DevTools 的 Performance 标签分析性能

## 🎯 下一步

1. ✅ 本地开发和测试
2. ✅ 自定义配置（如需要）
3. ✅ 构建生产版本
4. ✅ 部署到 Netlify
5. ✅ 分享给朋友！

## 🎉 完成！

你已经准备好开始使用小图宝了！

有问题？查看 [README.md](./README.md) 或 [DEPLOY.md](./DEPLOY.md)

---

**小图宝** - 让图片压缩变得简单、快速、安全 ✨
