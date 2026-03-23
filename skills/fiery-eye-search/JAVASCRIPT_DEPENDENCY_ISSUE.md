# JavaScript 依赖问题说明

## 问题概述

在使用 `web_fetch` 工具访问某些搜索引擎时，发现 **DuckDuckGo** 和 **WolframAlpha** 返回的页面不完整，需要 JavaScript 才能显示完整内容。

---

## 🔍 问题详情

### 1. DuckDuckGo Lite

#### 当前行为

```javascript
// 使用 web_fetch 访问 DuckDuckGo Lite
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=python+tutorial"})
```

**返回内容**：
```html
<!-- <!DOCTYPE HTML PUBLIC "-//W3C//W3C//DTD HTML 4.01 Transitional//EN"... -->
<!DOCTYPE html>
<html lang="en">
<head><title>duckduckgo.com</title></head>
<body>
  <!-- This is the Lite version. Get the full-JS version here. -->
  <!-- 搜索结果极少，功能受限 -->
</body>
</html>
```

#### 原因分析

- DuckDuckGo 提供两个版本：
  - **Lite 版**：纯 HTML，无 JavaScript，搜索结果少
  - **完整版**：需要 JavaScript 渲染，完整搜索结果和 Bangs 功能

- `web_fetch` 工具只能获取静态 HTML，无法执行 JavaScript

---

### 2. WolframAlpha

#### 当前行为

```javascript
// 使用 web_fetch 访问 WolframAlpha
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

**返回内容**：
```html
<html>
<head><title>WolframAlpha</title></head>
<body>
  <!-- 只显示页面框架，无实际计算结果 -->
  <!-- 计算结果由 JavaScript 动态加载 -->
</body>
</html>
```

#### 原因分析

- WolframAlpha 的计算结果由 JavaScript 动态渲染
- 静态 HTML 只包含页面框架，不包含实际数据
- 需要浏览器执行 JavaScript 才能显示完整结果

---

## 📊 引擎对比表

| 引擎 | 需要 JS | 返回内容 | 推荐度 | 适用场景 |
|------|--------|---------|--------|---------|
| **百度** | ❌ 否 | 完整结果 | ⭐⭐⭐⭐⭐ | 中文内容 |
| **Bing 国内** | ❌ 否 | 完整结果 | ⭐⭐⭐⭐⭐ | 技术文档 |
| **Bing 国际** | ❌ 否 | 完整结果 | ⭐⭐⭐⭐⭐ | 英文内容 |
| **Brave** | ❌ 否 | 完整结果 | ⭐⭐⭐⭐ | 隐私搜索 |
| **DuckDuckGo** | ⚠️ 是 | Lite 版（不完整） | ⭐⭐⭐ | 快速跳转 |
| **WolframAlpha** | ⚠️ 是 | 页面框架（无结果） | ⭐⭐⭐ | 计算查询 |
| **Google HK** | ⚠️ 是 | 可能触发验证 | ⭐⭐⭐ | 高质量结果 |
| **Startpage** | ⚠️ 是 | 可能触发验证 | ⭐⭐⭐ | Google+ 隐私 |

---

## 🛠️ 解决方案

### 方案 1：改用不需要 JS 的引擎（推荐）

#### 日常搜索

```javascript
// ✅ 推荐：使用不需要 JS 的引擎
web_fetch({"url": "https://www.bing.com/search?q=你的关键词"})
web_fetch({"url": "https://www.baidu.com/s?wd=你的关键词"})
web_fetch({"url": "https://search.brave.com/search?q=你的关键词"})
```

#### 计算查询替代方案

```javascript
// ❌ WolframAlpha（需要 JS）
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})

// ✅ 改用 Bing 搜索
web_fetch({"url": "https://www.bing.com/search?q=100+USD+to+CNY"})

// ✅ 或使用百度
web_fetch({"url": "https://www.baidu.com/s?wd=100 美元 人民币"})

// ✅ 数学计算
web_fetch({"url": "https://www.bing.com/search?q=integrate+x%5E2+dx"})
```

---

### 方案 2：使用 headless 浏览器（复杂，不推荐）

需要安装 Puppeteer/Selenium 等工具执行 JavaScript：

```bash
# 安装 Puppeteer
npm install puppeteer

# 创建脚本
cat > fetch-with-js.js << 'EOF'
const puppeteer = require('puppeteer');

async function fetchWithJS(url) {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();
  await page.goto(url, {waitUntil: 'networkidle0'});
  const content = await page.content();
  await browser.close();
  return content;
}

// 使用示例
fetchWithJS('https://www.wolframalpha.com/input?i=100+USD+to+CNY')
  .then(result => console.log(result));
EOF

node fetch-with-js.js
```

**缺点**：
- ❌ 需要安装额外依赖（Node.js, Puppeteer）
- ❌ 消耗更多系统资源
- ❌ 配置复杂，启动慢
- ❌ 可能触发反爬虫机制

---

### 方案 3：使用官方 API（需要注册）

#### WolframAlpha API

```javascript
// 注册获取 API key: https://products.wolframalpha.com/api/

web_fetch({
  "url": "https://api.wolframalpha.com/v1/simple?appid=YOUR_APP_ID&i=100+USD+to+CNY"
})
```

#### DuckDuckGo 无官方 API

DuckDuckGo 不提供公开 API，只能使用网页爬取。

**缺点**：
- ❌ 需要注册 API key
- ❌ 有使用限制（免费额度）
- ❌ 部分功能需要付费

---

### 方案 4：智能降级（推荐实现）

在技能中实现自动降级逻辑：

```javascript
// 智能选择引擎，自动降级
function smartSearch(query) {
  // 中文查询 → 百度
  if (/[\u4e00-\u9fa5]/.test(query)) {
    return web_fetch({"url": `https://www.baidu.com/s?wd=${query}`});
  }
  
  // 计算查询 → Bing（降级）
  if (/integrate|derivative|solve|convert|\d+\s*[+\-*/]\s*\d+/i.test(query)) {
    return web_fetch({"url": `https://www.bing.com/search?q=${query}`});
  }
  
  // 默认 → Bing 国际
  return web_fetch({"url": `https://www.bing.com/search?q=${query}&ensearch=1`});
}
```

---

## 🚀 后续演进方向

### 1. 添加 headless 浏览器支持

**目标**：支持需要 JavaScript 的引擎

**实现**：
```javascript
// 在 config.json 中添加配置
{
  "javascriptSupport": {
    "enabled": false,  // 默认关闭
    "engine": "puppeteer",  // 或 "playwright"
    "timeout": 30000
  }
}
```

**优点**：
- ✅ 支持所有搜索引擎
- ✅ 获取完整结果

**缺点**：
- ❌ 需要额外依赖
- ❌ 性能开销大

---

### 2. 集成 API 服务

**目标**：使用官方 API 替代网页爬取

**实现**：
```javascript
// 支持多种 API
{
  "apiIntegration": {
    "wolframalpha": {
      "enabled": false,
      "apiKeyEnv": "WOLFRAM_APP_ID"
    },
    "brave": {
      "enabled": false,
      "apiKeyEnv": "BRAVE_API_KEY"
    }
  }
}
```

**优点**：
- ✅ 官方支持，稳定可靠
- ✅ 无需处理反爬虫

**缺点**：
- ❌ 需要 API key
- ❌ 有使用限制

---

### 3. 多引擎并行 + 结果融合

**目标**：同时使用多个引擎，融合结果

**实现**：
```javascript
async function multiEngineSearch(query) {
  const results = await Promise.all([
    web_fetch({"url": `https://www.bing.com/search?q=${query}`}),
    web_fetch({"url": `https://www.baidu.com/s?wd=${query}`}),
    web_fetch({"url": `https://search.brave.com/search?q=${query}`})
  ]);
  
  // 融合结果
  return mergeResults(results);
}
```

**优点**：
- ✅ 结果更全面
- ✅ 互相补充

**缺点**：
- ❌ 请求次数增加
- ❌ 需要结果去重

---

### 4. 结果缓存 + 智能降级

**目标**：减少重复请求，自动降级

**实现**：
```javascript
class SmartSearch {
  constructor() {
    this.cache = new Map();
    this.fallbackOrder = ['bing-int', 'baidu', 'brave'];
  }
  
  async search(query, engine = 'default') {
    const cacheKey = `${engine}:${query}`;
    
    // 检查缓存
    if (this.cache.has(cacheKey)) {
      return this.cache.get(cacheKey);
    }
    
    // 尝试主引擎
    try {
      const result = await this.tryEngine(engine, query);
      this.cache.set(cacheKey, result);
      return result;
    } catch (e) {
      // 降级到备用引擎
      for (const fallback of this.fallbackOrder) {
        try {
          const result = await this.tryEngine(fallback, query);
          this.cache.set(cacheKey, result);
          return result;
        } catch (e) {
          continue;
        }
      }
      throw new Error('所有引擎都失败');
    }
  }
}
```

**优点**：
- ✅ 减少重复请求
- ✅ 自动降级
- ✅ 提高成功率

---

## 📋 当前推荐配置

### config.json 更新

```json
{
  "name": "fiery-eye-search",
  "version": "2.3.0",
  "defaultEngine": "bing-int",
  "fallbackEngine": "baidu",
  "engines": {
    "baidu": {
      "name": "百度",
      "url": "https://www.baidu.com/s?wd={query}",
      "requiresJS": false,
      "priority": 1,
      "recommended": true
    },
    "bing-cn": {
      "name": "Bing 国内",
      "url": "https://cn.bing.com/search?q={query}&ensearch=0",
      "requiresJS": false,
      "priority": 1,
      "recommended": true
    },
    "bing-int": {
      "name": "Bing 国际",
      "url": "https://www.bing.com/search?q={query}&ensearch=1",
      "requiresJS": false,
      "priority": 1,
      "recommended": true
    },
    "brave": {
      "name": "Brave Search",
      "url": "https://search.brave.com/search?q={query}",
      "requiresJS": false,
      "priority": 2,
      "recommended": true
    },
    "duckduckgo": {
      "name": "DuckDuckGo",
      "url": "https://lite.duckduckgo.com/lite/?q={query}",
      "requiresJS": true,
      "priority": 3,
      "recommended": false,
      "limitations": [
        "Lite 版本，搜索结果较少",
        "完整版需要 JavaScript",
        "反爬虫机制严格"
      ],
      "alternative": "brave"
    },
    "wolframalpha": {
      "name": "WolframAlpha",
      "url": "https://www.wolframalpha.com/input?i={query}",
      "requiresJS": true,
      "priority": 3,
      "recommended": false,
      "limitations": [
        "需要 JavaScript 才能显示计算结果",
        "静态 HTML 只包含页面框架"
      ],
      "alternative": "bing-int"
    }
  },
  "smartSelection": {
    "enabled": true,
    "rules": [
      {
        "condition": "chinese",
        "pattern": "[\\u4e00-\\u9fa5]",
        "preferred": ["baidu", "bing-cn"],
        "description": "中文查询优先使用国内引擎"
      },
      {
        "condition": "math",
        "pattern": "[\\d+\\-*/=]|integrate|derivative|convert|calculate",
        "preferred": ["bing-int", "baidu"],
        "description": "数学/计算查询使用不需要 JS 的引擎"
      },
      {
        "condition": "privacy",
        "pattern": "privacy|security|password|encryption",
        "preferred": ["brave"],
        "description": "隐私相关查询使用隐私引擎"
      }
    ]
  }
}
```

---

## ✅ 最佳实践总结

### 推荐引擎选择

| 场景 | 推荐引擎 | 原因 |
|------|---------|------|
| **中文内容** | 百度 | 无需 JS，中文优化 |
| **技术文档** | Bing 国内 | 无需 JS，稳定快速 |
| **英文内容** | Bing 国际 | 无需 JS，全球覆盖 |
| **隐私搜索** | Brave | 无需 JS，独立索引 |
| **计算查询** | Bing | 无需 JS，替代 WolframAlpha |

### 避免的陷阱

| ❌ 避免 | ✅ 替代 |
|--------|--------|
| DuckDuckGo Lite | Brave / Bing |
| WolframAlpha 网页 | Bing 搜索 |
| Google（可能触发验证） | Bing / Brave |
| Startpage（可能触发验证） | Brave |

---

## 📚 参考文档

- [Web Scraping Best Practices](https://www.scrapingbee.com/blog/web-scraping-best-practices/)
- [Headless Browsers Comparison](https://www.browserstack.com/guide/headless-browsers)
- [WolframAlpha API Documentation](https://products.wolframalpha.com/api/documentation)

---

## 📝 版本历史

### v2.3.0 (计划)

- 添加 `requiresJS` 字段标记引擎
- 实现智能降级逻辑
- 更新文档说明 JS 依赖问题

### v2.2.0 (当前)

- 基础版本，支持 8 个引擎
- 发现 JS 依赖问题

---

**最后更新**: 2026-03-17
**维护者**: @WTFGEDelphia
