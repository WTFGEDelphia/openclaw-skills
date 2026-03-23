# 火眼搜索 - Web Search 集成使用指南

## 🎯 快速开始

### 方式 1：使用 web_search 工具（推荐）

```javascript
// 直接调用 web_search（需要配置 Brave API Key）
web_search({
  "query": "火眼金睛",
  "count": 10
})
```

### 方式 2：使用火眼搜索技能

```javascript
// 使用默认引擎（Bing 国内）
web_fetch({"url": "https://cn.bing.com/search?q=你的关键词&ensearch=0"})

// 指定引擎
web_fetch({"url": "https://www.baidu.com/s?wd=火眼金睛"})
web_fetch({"url": "https://www.bing.com/search?q=Fiery+Eye+Search"})
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

---

## 🔧 配置 Brave API Key

### 1. 获取 API Key

访问 https://brave.com/search/api/ 注册并获取 API Key

### 2. 设置环境变量

**方式 A：临时设置**

```bash
export BRAVE_API_KEY="你的_API_KEY"
```

**方式 B：永久设置**

编辑 `~/.bashrc` 或 `~/.zshrc`：

```bash
echo 'export BRAVE_API_KEY="你的_API_KEY"' >> ~/.bashrc
source ~/.bashrc
```

**方式 C：使用 OpenClaw 配置**

```bash
openclaw configure --section web
```

### 3. 验证配置

```bash
# 测试 API
curl -H "X-Subscription-Token: $BRAVE_API_KEY" \
     "https://api.brave.com/search/v1/query?q=test"
```

---

## 📊 两种搜索方式对比

| 特性 | web_search | 火眼搜索 |
|------|-----------|---------|
| **API Key** | 需要 | 不需要 |
| **代理** | 不需要 | 推荐配置 |
| **结果质量** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **引擎选择** | 单一 (Brave) | 8 个引擎 |
| **反爬虫** | 无 | 部分引擎有 |
| **速度** | 快 | 中等 |
| **推荐场景** | 日常搜索 | 多引擎对比 |

---

## 🚀 高级用法

### 智能引擎选择

```javascript
// 根据查询类型自动选择
function smartSearch(query) {
  // 中文 → 百度
  if (/[\u4e00-\u9fa5]/.test(query)) {
    return web_fetch({"url": `https://www.baidu.com/s?wd=${query}`});
  }
  // 英文 → web_search
  return web_search({"query": query, "count": 10});
}
```

### 混合搜索

```javascript
// 同时使用多个引擎
async function mixedSearch(query) {
  const results = {
    brave: await web_search({"query": query, "count": 5}),
    baidu: await web_fetch({"url": `https://www.baidu.com/s?wd=${query}`}),
    bing: await web_fetch({"url": `https://www.bing.com/search?q=${query}`})
  };
  return results;
}
```

### 时间过滤

```javascript
// 过去 1 周的新闻
web_fetch({
  "url": "https://www.bing.com/search?q=AI+news&tbs=qdr:w"
})
```

### 站点内搜索

```javascript
// GitHub 上的项目
web_fetch({
  "url": "https://www.bing.com/search?q=site:github.com+openclaw"
})
```

---

## 📝 配置文件

### config.json 关键配置

```json
{
  "name": "fiery-eye-search",
  "version": "2.1.0",
  "defaultMethod": "web_fetch",
  "fallbackEngine": "bing-cn",
  "webSearchIntegration": {
    "enabled": true,
    "requiresApiKey": true,
    "apiKeyEnv": "BRAVE_API_KEY",
    "priority": 1
  },
  "engines": {
    "web_search": {
      "name": "Brave Search",
      "type": "api",
      "requiresApiKey": true
    },
    "baidu": {
      "name": "百度",
      "url": "https://www.baidu.com/s?wd={query}",
      "region": "CN"
    },
    "bing-cn": {
      "name": "Bing 国内",
      "url": "https://cn.bing.com/search?q={query}&ensearch=0",
      "region": "CN"
    },
    "bing-int": {
      "name": "Bing 国际",
      "url": "https://www.bing.com/search?q={query}&ensearch=1",
      "region": "INT"
    }
  }
}
```

---

## 🛠️ 故障排查

### 问题 1：web_search 未配置

**错误**：`web_search requires API key`

**解决**：
```bash
export BRAVE_API_KEY="你的_API_KEY"
```

### 问题 2：代理连接失败

**错误**：`Connection timeout`

**解决**：
```bash
export HTTP_PROXY=http://172.20.67.14:7890
export HTTPS_PROXY=http://172.20.67.14:7890
```

### 问题 3：搜索引擎反爬虫

**错误**：`CAPTCHA detected`

**解决**：
- 改用百度或 Bing 国内
- 降低请求频率
- 使用 web_search（无限制）

---

## 📚 参考文档

- [OpenClaw 文档](https://docs.openclaw.ai)
- [Brave Search API](https://brave.com/search/api/)
- [火眼搜索 SKILL.md](SKILL.md)
- [火眼搜索 EXAMPLES.md](EXAMPLES.md)

---

## ✅ 总结

| 使用场景 | 推荐方法 |
|---------|---------|
| **日常搜索** | web_search (配置 API key) |
| **中文内容** | 百度 |
| **技术文档** | Bing 国内 |
| **国际新闻** | Bing 国际 |
| **隐私搜索** | Brave / DuckDuckGo |
| **计算查询** | WolframAlpha |

**推荐配置**：同时配置 web_search 和火眼搜索，根据场景灵活切换！
