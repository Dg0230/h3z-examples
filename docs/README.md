# H3z Examples GitHub Pages

这是 H3z Examples 项目的 GitHub Pages 网站，展示了 H3z HTTP 框架的示例和功能。

## 网站内容

该网站包含以下内容：

- 项目概述和主要特性
- 详细的示例展示（基础服务器、多模式服务器、中间件、高级路由、REST API）
- 安装和构建指南
- API 端点文档

## 本地开发

如果你想在本地开发和预览这个网站，可以按照以下步骤操作：

1. 克隆仓库：
   ```bash
   git clone https://github.com/Dg0230/h3z-examples.git
   cd h3z-examples
   ```

2. 切换到 gh-pages 分支：
   ```bash
   git checkout gh-pages
   ```

3. 使用任何静态文件服务器来提供网站内容，例如：
   ```bash
   # 如果你安装了 Python
   python -m http.server
   
   # 或者使用 Node.js 的 http-server
   npx http-server
   ```

4. 在浏览器中访问 `http://localhost:8000` 或服务器提供的 URL。

## 贡献

欢迎对网站进行改进！请提交 Pull Request 到 gh-pages 分支。