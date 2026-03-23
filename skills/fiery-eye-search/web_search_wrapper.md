# 火眼搜索 - web_search 集成指南

## 如何将火眼搜索集成到 OpenClaw 的 web_search 工具

### 方案 1：使用 web_search 工具（推荐）

火眼搜索技能可以调用 OpenClaw 的 `web_search` 核心工具：

```javascript
// 直接调用 web_search
web_search({
  "query": "火眼金睛",
  "count": 5
})
```

### 方案 2：配置默认引擎

在 `config.json` 中设置默认使用 web_search：

```json
{
  "name": "fiery-eye-search",
  "defaultMethod": "web_search",
  "engines": {
    "web_search": {
      "name": "Brave Search",
      "type": "api",
      "requiresApiKey": true
    }
  }
}
```

### 方案 3：创建 wrapper 技能

创建一个包装技能，统一使用 web_search：

```javascript
// 在技能中调用
function fierySearch(query) {
  return web_search({
    "query": query,
    "count": 10
  });
}
```

## 配置步骤

### 1. 配置 Brave API Key

```bash
openclaw configure --section web
```

或设置环境变量：

```bash
export BRAVE_API_KEY=你的 API_KEY
```

### 2. 修改技能配置

编辑 `config.json`：

```json
{
  "name": "fiery-eye-search",
  "version": "2.0.0",
  "defaultMethod": "web_search",
  "fallbackEngine": "bing-cn"
}
```

### 3. 测试集成

```javascript
// 测试 web_search
web_search({"query": "火眼金睛", "count": 5})

// 测试火眼搜索
web_fetch({"url": "https://www.baidu.com/s?wd=火眼金睛"})
```

## 优势对比

| 方案 | 优点 | 缺点 |
|------|------|------|
| **web_search** | 结果质量高，无需代理 | 需要 API key |
| **web_fetch** | 无需 API key，多引擎 | 需要代理，反爬虫 |
| **混合模式** | 灵活切换，最佳体验 | 配置复杂 |

## 推荐配置

```json
{
  "defaultMethod": "web_search",
  "fallbackEngine": "bing-cn",
  "engines": {
    "web_search": {
      "enabled": true,
      "priority": 1
    },
    "baidu": {
      "enabled": true,
      "priority": 2
    },
    "bing-int": {
      "enabled": true,
      "priority": 3
    }
  }
}
```
