# H3z Examples

[![Zig](https://img.shields.io/badge/Zig-0.14+-orange.svg)](https://ziglang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)]()

全面的示例和演示，灵感来自 [H3z](https://github.com/Dg0230/h3z) HTTP 框架。本仓库展示了如何使用 Zig 构建快速、轻量且可组合的 HTTP 服务器，包含各种模式、中间件支持和生产级特性。

> **注意**：本项目包含一个简化的 H3z 兼容 API 实现，用于演示目的。当 H3z 变得稳定后，这些示例可以轻松迁移到官方 H3z 库。

## ✨ 你将学到什么

- **现代 Zig 开发**：探索 Zig 0.14+ 特性和最佳实践
- **H3z 框架精通**：使用 H3z HTTP 框架的完整示例
- **HTTP 服务器模式**：理解不同的服务器架构和模式
- **中间件系统**：了解如何为实际应用构建和链接中间件
- **API 开发**：学习构建具有适当错误处理的 RESTful API
- **安全最佳实践**：实现安全头、CORS 和身份验证

## 📚 包含的示例

本仓库包含多个全面的示例：

### 1. 基础服务器 (`basic_server.zig`)
- 简单的 HTTP 服务器设置
- 基本路由和处理程序
- 请求/响应处理
- HTML 和 JSON 响应

### 2. 多模式服务器 (`multi_mode_server.zig`)
- **基本模式**：开发的默认配置
- **安全模式**：具有安全特性的生产就绪配置
- **开发模式**：启用 CORS，宽松设置
- 命令行模式切换

### 3. 中间件示例 (`middleware_example.zig`)
- 自定义中间件实现
- 内置中间件使用
- 中间件链接
- 请求/响应修改

### 4. 高级路由 (`advanced_routing.zig`)
- 从 URL 提取参数
- 通配符路由
- 文件上传处理
- 身份验证中间件
- 错误处理模式

### 5. REST API (`rest_api.zig`)
- 完整的 CRUD 操作
- JSON 请求/响应处理
- 数据验证
- 错误响应
- API 版本控制

## 🚀 展示的特性

- **高性能架构** - 基于 H3z 的轻量快速核心
- **多种操作模式** - 基本、安全和开发配置
- **中间件系统** - 全局和路由特定的中间件支持
- **安全特性** - CORS、安全头、身份验证
- **现代 Zig 模式** - 类型安全、内存安全的实现

## 📦 安装和构建

### 前提条件

- Zig 0.14.0 或更高版本
- 网络连接（用于下载依赖项）

### 构建项目

```bash
# 克隆项目
git clone https://github.com/your-username/h3z-examples.git
cd h3z-examples

# 构建所有示例
zig build

# 运行测试
zig build test
```

## 🎯 运行示例

### 基础服务器
```bash
zig build basic
# 或者
zig build run
```
- 端口：3000
- 简单的路由和处理程序

### 多模式服务器
```bash
# 基本模式（默认）
zig build multi

# 安全模式
zig build multi -- --mode=secure

# 开发模式
zig build multi -- --mode=dev
```

### 中间件示例
```bash
zig build middleware
```

### 高级路由
```bash
zig build advanced
```

### REST API
```bash
zig build api
```

## 📚 API 端点

### 基础服务器端点

| 方法 | 路径 | 描述 |
|--------|------|-------------|
| GET | `/` | 带有 HTML 界面的主页 |
| GET | `/hello/:name` | 个性化问候 |
| POST | `/api/echo` | 回显请求体 |
| GET | `/api/status` | 服务器状态 |

### 多模式服务器端点

| 方法 | 路径 | 描述 |
|--------|------|-------------|
| GET | `/` | 模式特定的主页 |
| GET | `/api/status` | 带有模式信息的服务器状态 |
| POST | `/api/echo` | 回显请求体 |
| GET | `/users/:id` | 用户信息 |
| GET | `/health` | 健康检查（安全模式） |
| POST | `/upload` | 文件上传（安全模式） |
| GET | `/admin` | 管理面板（安全模式，需要认证） |

### REST API 端点

| 方法 | 路径 | 描述 |
|--------|------|-------------|
| GET | `/api/v1/users` | 列出所有用户 |
| GET | `/api/v1/users/:id` | 通过 ID 获取用户 |
| POST | `/api/v1/users` | 创建新用户 |
| PUT | `/api/v1/users/:id` | 更新用户 |
| DELETE | `/api/v1/users/:id` | 删除用户 |

## 🧪 测试示例

我们提供全面的测试脚本，帮助您探索和验证示例：

### 自动化测试脚本

```bash
# 测试基础服务器（确保它已经在运行）
./scripts/test_basic.sh

# 测试 REST API 服务器（确保它已经在运行）
./scripts/test_api.sh

# 运行性能基准测试
./scripts/benchmark.sh all
```

### 手动测试

#### 基础服务器测试
```bash
# 状态检查
curl http://127.0.0.1:3000/api/status

# 个性化问候
curl http://127.0.0.1:3000/hello/world

# 回显测试
curl -X POST -H "Content-Type: application/json" \
     -d '{"message":"Hello H3z!"}' \
     http://127.0.0.1:3000/api/echo

# 用户端点
curl http://127.0.0.1:3000/users/123

# 计算器端点
curl -X POST -H "Content-Type: application/json" \
     -d '{"a":10,"b":5,"op":"add"}' \
     http://127.0.0.1:3000/api/calculate
```

#### 多模式服务器测试
```bash
# 测试基本模式
curl http://127.0.0.1:3000/api/status

# 测试安全模式（不同端口）
curl http://127.0.0.1:3001/health
curl http://127.0.0.1:3001/config

# 测试开发模式
curl http://127.0.0.1:3002/debug
```

#### 高级路由测试
```bash
# 参数路由
curl http://127.0.0.1:3000/users/123
curl http://127.0.0.1:3000/users/123/posts/456

# 查询参数
curl "http://127.0.0.1:3000/search?q=test&page=1"

# 通配符路由
curl http://127.0.0.1:3000/static/css/style.css

# 文件上传
curl -X POST -F "file=@example.txt" http://127.0.0.1:3000/upload

# 需要身份验证
curl -H "Authorization: Bearer valid-token-123" \
     http://127.0.0.1:3000/protected
```

#### REST API 测试
```bash
# 用户 CRUD
curl http://127.0.0.1:3000/api/v1/users
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"John Doe","email":"john@example.com"}' \
     http://127.0.0.1:3000/api/v1/users
curl -X PUT -H "Content-Type: application/json" \
     -d '{"name":"John Updated"}' \
     http://127.0.0.1:3000/api/v1/users/1
curl -X DELETE http://127.0.0.1:3000/api/v1/users/1

# 产品 CRUD
curl http://127.0.0.1:3000/api/v1/products
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"Widget","price":29.99,"category":"tools"}' \
     http://127.0.0.1:3000/api/v1/products

# 订单 CRUD
curl http://127.0.0.1:3000/api/v1/orders
curl -X POST -H "Content-Type: application/json" \
     -d '{"user_id":1,"product_id":1,"quantity":2}' \
     http://127.0.0.1:3000/api/v1/orders

# 统计
curl http://127.0.0.1:3000/api/v1/stats
```

#### 中间件测试
```bash
# 测试中间件栈
curl -v http://127.0.0.1:3000/api/middleware-info

# 测试计时中间件
curl http://127.0.0.1:3000/api/timing

# 测试身份验证中间件
curl -H "Authorization: Bearer valid-token-123" \
     http://127.0.0.1:3000/auth-required

# 测试验证中间件
curl -X POST -H "Content-Type: application/json" \
     -d '{"test":"data"}' \
     http://127.0.0.1:3000/api/validated
```

## 🛡️ 安全特性

安全模式展示了：

- **CORS 保护**：可配置的跨源资源共享
- **安全头**：X-Frame-Options、X-Content-Type-Options 等
- **请求验证**：输入验证和净化
- **身份验证**：基本 HTTP 身份验证示例
- **速率限制**：请求速率限制（计划中）

## 🔧 中间件

示例展示了各种中间件：

- **日志中间件** - 请求/响应日志记录
- **CORS 中间件** - 跨源资源共享
- **安全头中间件** - 安全相关的 HTTP 头
- **身份验证中间件** - 用户身份验证
- **错误处理中间件** - 集中式错误处理
- **自定义中间件** - 构建您自己的中间件

## 📁 项目结构

```
h3z-examples/
├── build.zig              # 构建配置
├── build.zig.zon          # 依赖管理
├── src/
│   ├── basic_server.zig   # 基础服务器示例
│   ├── multi_mode_server.zig # 多模式服务器
│   ├── middleware_example.zig # 中间件演示
│   ├── advanced_routing.zig   # 高级路由功能
│   ├── rest_api.zig       # REST API 示例
│   └── tests.zig          # 单元测试
├── scripts/
│   ├── test_basic.sh      # 基础服务器测试脚本
│   ├── test_api.sh        # API 测试脚本
│   └── benchmark.sh       # 性能基准测试
├── LICENSE                # MIT 许可证
└── README.md              # 本文件
```

## 🤝 贡献

欢迎贡献！以下是您可以帮助的方式：

1. **Fork 仓库**
2. **创建功能分支**：`git checkout -b feature/amazing-feature`
3. **提交您的更改**：`git commit -m 'Add amazing feature'`
4. **推送到分支**：`git push origin feature/amazing-feature`
5. **打开拉取请求**

### 开发指南

- 遵循 Zig 编码约定
- 为新功能添加测试
- 根据需要更新文档
- 确保所有测试通过：`zig build test`

## 📄 许可证

本项目采用 MIT 许可证 - 详情请参阅 [LICENSE](LICENSE) 文件。

## 🌟 表达支持

如果这个项目帮助您学习了 Zig 或 H3z，请给一个 ⭐️！

## 📱 在线演示

我们提供了一个 GitHub Pages 网站，展示 H3z 框架的特性和示例：

- [H3z Examples 演示网站](https://dg0230.github.io/h3z-examples/) - 浏览框架特性、示例代码和 API 文档

在这个演示网站上，您可以：
- 了解 H3z 框架的核心特性
- 查看各种示例的代码片段
- 浏览 API 端点文档
- 获取安装和使用指南

## 🔗 相关链接

- [H3z](https://github.com/Dg0230/h3z) - 轻量、快速且可组合的 HTTP 框架
- [Zig](https://ziglang.org/) - Zig 编程语言
- [H3.js](https://h3.dev) - H3z 的灵感来源
