# 小图宝 - 部署指南

## 📋 部署前检查清单

- [ ] 所有依赖已安装：`npm install`
- [ ] 本地开发测试通过：`npm run dev`
- [ ] 生产构建成功：`npm run build`
- [ ] 代码已提交到 Git
- [ ] 环境变量已配置

## 🚀 部署步骤

### 1. 准备工作

```bash
# 克隆或进入项目目录
cd little-picture

# 安装依赖
npm install

# 本地测试
npm run dev

# 构建生产版本
npm run build
```

### 2. 部署到 Netlify

#### 方式 A：通过 GitHub（推荐）

1. **初始化 Git 仓库**（如果还没有）
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   ```

2. **推送到 GitHub**
   - 在 GitHub 创建新仓库
   - 添加远程仓库：`git remote add origin <your-repo-url>`
   - 推送代码：`git push -u origin main`

3. **连接 Netlify**
   - 访问 [Netlify](https://netlify.com)
   - 点击 "New site from Git"
   - 选择 GitHub 并授权
   - 选择你的仓库
   - 配置构建设置：
     - Build command: `npm run build`
     - Publish directory: `dist`
   - 点击 "Deploy site"

#### 方式 B：通过 Netlify CLI

```bash
# 全局安装 Netlify CLI
npm install -g netlify-cli

# 登录 Netlify
netlify login

# 部署到 Netlify
netlify deploy --prod
```

#### 方式 C：拖拽部署

1. 运行 `npm run build` 生成 `dist` 文件夹
2. 访问 [Netlify](https://netlify.com)
3. 将 `dist` 文件夹拖拽到部署区域
4. 等待部署完成

### 3. 自定义域名（可选）

1. 在 Netlify 项目设置中找到 "Domain management"
2. 点击 "Add custom domain"
3. 输入你的域名
4. 按照指示配置 DNS 记录

### 4. 配置 HTTPS（自动）

Netlify 会自动为你的网站配置 HTTPS 证书。

### 5. 环境变量配置（如需要）

1. 在 Netlify 项目设置中找到 "Build & deploy" > "Environment"
2. 添加环境变量
3. 重新部署

## 🔍 部署后检查

- [ ] 网站可以正常访问
- [ ] 所有功能正常工作
- [ ] 图片压缩功能正常
- [ ] 批量操作正常
- [ ] 移动端显示正常
- [ ] 没有控制台错误

## 📊 性能优化

### 已包含的优化

- ✅ Vite 自动代码分割
- ✅ CSS 压缩和优化
- ✅ 图片懒加载
- ✅ 浏览器缓存配置

### 进一步优化建议

1. **启用 Gzip 压缩**
   - Netlify 默认启用

2. **CDN 加速**
   - Netlify 全球 CDN 自动启用

3. **缓存策略**
   - 在 `netlify.toml` 中配置缓存头

## 🐛 故障排除

### 构建失败

```bash
# 清除缓存并重新构建
rm -rf node_modules dist
npm install
npm run build
```

### 部署后白屏

- 检查浏览器控制台错误
- 确保 `netlify.toml` 中的 `publish` 目录正确
- 检查 `vite.config.js` 中的 `base` 配置

### 路由问题

- 确保 `netlify.toml` 中有重定向规则
- 检查 `vite.config.js` 中的 `base` 配置

## 📈 监控和分析

### Netlify Analytics

1. 在 Netlify 项目设置中启用 Analytics
2. 查看访问统计和性能数据

### 自定义分析

可以集成 Google Analytics 或其他分析工具。

## 🔐 安全建议

- ✅ 启用 HTTPS（自动）
- ✅ 定期更新依赖：`npm update`
- ✅ 检查安全漏洞：`npm audit`
- ✅ 不要提交敏感信息到 Git

## 📝 更新部署

每次更新代码后：

```bash
# 提交更改
git add .
git commit -m "Update: description"
git push

# Netlify 会自动重新部署
```

## 💡 常见问题

**Q: 如何更改网站名称？**
A: 在 Netlify 项目设置中修改 "Site name"

**Q: 如何回滚到之前的版本？**
A: 在 Netlify "Deploys" 页面选择之前的部署并点击 "Restore"

**Q: 如何增加构建超时时间？**
A: 在 `netlify.toml` 中添加 `functions_dir = "functions"` 并配置超时

## 🎉 部署完成

恭喜！你的小图宝已经成功部署到 Netlify！

分享你的网站链接给朋友吧！

---

**需要帮助？** 访问 [Netlify 文档](https://docs.netlify.com)
