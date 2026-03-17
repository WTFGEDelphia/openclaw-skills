# 火眼搜索 (Fiery Eye Search) - 高级功能

> "火眼金睛，搜真辨伪"

## 🚀 新增功能

### 1. 智能引擎选择

根据查询类型自动选择最佳搜索引擎：

```javascript
// 自动选择引擎
function smartSearch(query) {
  // 中文内容 → 百度
  if (/[\u4e00-\u9fa5]/.test(query)) {
    return "baidu";
  }
  // 数学/计算 → WolframAlpha
  if (/[\d+\-*/=]|integrate|derivative|convert/.test(query)) {
    return "wolframalpha";
  }
  // 隐私敏感 → Brave
  if (/privacy|security|password/.test(query)) {
    return "brave";
  }
  // 默认 → Bing 国际
  return "bing-int";
}

// 使用
const engine = smartSearch("美伊战争");
web_fetch({"url": `https://www.baidu.com/s?wd=${engine}`});
```

---

### 2. 结果缓存

避免重复搜索，提高性能：

```javascript
// 简单缓存实现
const searchCache = new Map();
const CACHE_TTL = 3600000; // 1 小时

function cachedSearch(query, engine = "bing-int") {
  const cacheKey = `${engine}:${query}`;
  const cached = searchCache.get(cacheKey);
  
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    console.log("使用缓存结果");
    return cached.result;
  }
  
  // 执行搜索
  const url = getEngineUrl(engine, query);
  const result = web_fetch({"url": url});
  
  // 更新缓存
  searchCache.set(cacheKey, {
    result,
    timestamp: Date.now()
  });
  
  return result;
}

// 使用
cachedSearch("AI 新闻", "bing-int");
```

---

### 3. 并行多引擎搜索

同时搜索多个引擎，聚合结果：

```javascript
// 并行搜索
async function multiEngineSearch(query, engines = ["baidu", "bing-int", "brave"]) {
  const promises = engines.map(engine => {
    const url = getEngineUrl(engine, query);
    return web_fetch({"url": url})
      .then(result => ({ engine, result }))
      .catch(error => ({ engine, error }));
  });
  
  const results = await Promise.all(promises);
  
  // 聚合结果
  return {
    query,
    timestamp: new Date().toISOString(),
    engines: results.reduce((acc, { engine, result, error }) => {
      acc[engine] = error || result;
      return acc;
    }, {})
  };
}

// 使用
multiEngineSearch("Python 教程", ["baidu", "bing-int"]);
```

---

### 4. 结构化结果提取

从搜索结果中提取结构化数据：

```javascript
// 提取搜索结果
function parseSearchResults(html) {
  const results = [];
  
  // 提取标题和链接
  const titleRegex = /<h2[^>]*><a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a><\/h2>/g;
  let match;
  
  while ((match = titleRegex.exec(html)) !== null) {
    results.push({
      url: match[1],
      title: match[2].trim()
    });
  }
  
  return results;
}

// 使用
const html = web_fetch({"url": "https://www.baidu.com/s?wd=test"});
const structured = parseSearchResults(html);
console.log(structured);
// [
//   { url: "https://...", title: "结果 1" },
//   { url: "https://...", title: "结果 2" }
// ]
```

---

### 5. 批量搜索

一次搜索多个关键词：

```javascript
// 批量搜索
async function batchSearch(queries, engine = "bing-int") {
  const results = {};
  
  for (const query of queries) {
    console.log(`搜索：${query}`);
    const url = getEngineUrl(engine, query);
    results[query] = web_fetch({"url": url});
    
    // 避免过快请求
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  return results;
}

// 使用
batchSearch([
  "美伊战争 最新消息",
  "美伊战争 历史背景",
  "美伊战争 影响分析"
]);
```

---

### 6. 搜索建议/自动补全

获取搜索建议：

```javascript
// 百度自动补全
async function getSuggestions(query) {
  const url = `https://suggestion.baidu.com/su?wd=${query}`;
  const html = web_fetch({"url": url});
  
  // 解析建议列表
  const suggestions = [];
  const regex = /<li[^>]*>([^<]*)<\/li>/g;
  let match;
  
  while ((match = regex.exec(html)) !== null) {
    suggestions.push(match[1].trim());
  }
  
  return suggestions;
}

// 使用
getSuggestions("Python");
// ["Python 教程", "Python 入门", "Python 下载", ...]
```

---

### 7. 图像/视频搜索

扩展搜索类型：

```javascript
// 图片搜索
function imageSearch(query) {
  return web_fetch({
    "url": `https://www.baidu.com/sf/vsearch?pd=image&wd=${query}`,
    "extractMode": "text"
  });
}

// 视频搜索
function videoSearch(query) {
  return web_fetch({
    "url": `https://www.baidu.com/sf/vsearch?pd=video&wd=${query}`,
    "extractMode": "text"
  });
}

// 使用
imageSearch("AI 机器人");
videoSearch("Python 教程");
```

---

### 8. 高级过滤组合

组合多个过滤条件：

```javascript
// 高级过滤搜索
function advancedSearch(query, filters = {}) {
  let url = "https://www.bing.com/search?q=";
  
  // 基础查询
  let q = query;
  
  // 站点过滤
  if (filters.site) {
    q += ` site:${filters.site}`;
  }
  
  // 文件类型
  if (filters.filetype) {
    q += ` filetype:${filters.filetype}`;
  }
  
  // 排除关键词
  if (filters.exclude) {
    q += ` -${filters.exclude}`;
  }
  
  // 时间过滤
  if (filters.time) {
    url += encodeURIComponent(q) + `&tbs=qdr:${filters.time}`;
  } else {
    url += encodeURIComponent(q);
  }
  
  return web_fetch({"url": url});
}

// 使用
advancedSearch("machine learning", {
  site: "github.com",
  filetype: "pdf",
  time: "w"  // 过去 1 周
});
```

---

### 9. 搜索历史

记录和管理搜索历史：

```javascript
// 搜索历史管理
class SearchHistory {
  constructor(maxSize = 100) {
    this.history = [];
    this.maxSize = maxSize;
  }
  
  add(query, engine, result) {
    this.history.unshift({
      timestamp: new Date().toISOString(),
      query,
      engine,
      resultPreview: result.substring(0, 100)
    });
    
    // 限制大小
    if (this.history.length > this.maxSize) {
      this.history = this.history.slice(0, this.maxSize);
    }
  }
  
  getRecent(count = 10) {
    return this.history.slice(0, count);
  }
  
  searchByKeyword(keyword) {
    return this.history.filter(item => 
      item.query.toLowerCase().includes(keyword.toLowerCase())
    );
  }
  
  clear() {
    this.history = [];
  }
}

// 使用
const history = new SearchHistory();
history.add("AI 新闻", "bing-int", "搜索结果...");
history.getRecent(5);
```

---

### 10. 结果对比分析

对比不同引擎的搜索结果：

```javascript
// 结果对比
async function compareEngines(query, engines = ["baidu", "bing-int", "brave"]) {
  const results = {};
  
  for (const engine of engines) {
    const url = getEngineUrl(engine, query);
    const html = web_fetch({"url": url});
    
    // 统计结果数量
    const resultCount = (html.match(/<h2/g) || []).length;
    
    results[engine] = {
      resultCount,
      topResult: extractTopResult(html),
      hasAds: html.includes("广告") || html.includes("Sponsored")
    };
  }
  
  return results;
}

// 使用
compareEngines("Python 教程");
// {
//   baidu: { resultCount: 50, topResult: {...}, hasAds: true },
//   bing-int: { resultCount: 45, topResult: {...}, hasAds: false },
//   ...
// }
```

---

### 11. 搜索结果排名

根据多个指标评估结果质量：

```javascript
// 结果质量评分
function scoreResults(results) {
  return results.map(result => {
    let score = 0;
    
    // 域名权威性
    const authoritativeDomains = [
      'gov', 'edu', 'org', 'github.com', 'medium.com'
    ];
    if (authoritativeDomains.some(d => result.url.includes(d))) {
      score += 30;
    }
    
    // 内容长度
    if (result.snippet && result.snippet.length > 200) {
      score += 20;
    }
    
    // 日期新鲜度
    if (result.date && isNewWithin(result.date, 7)) {
      score += 25;
    }
    
    // 关键词匹配
    if (result.title.includes(searchQuery)) {
      score += 25;
    }
    
    return { ...result, score };
  }).sort((a, b) => b.score - a.score);
}

// 使用
const scored = scoreResults(searchResults);
```

---

### 12. 搜索模板

预设常用搜索场景：

```javascript
// 搜索模板
const searchTemplates = {
  // 技术研究
  techResearch: (topic) => ({
    engines: ["bing-int", "github", "arxiv"],
    filters: {
      site: "github.com OR arxiv.org",
      time: "m"
    },
    query: `${topic} tutorial OR documentation`
  }),
  
  // 新闻追踪
  newsTracking: (topic) => ({
    engines: ["bing-int", "baidu"],
    filters: {
      time: "d"
    },
    query: topic
  }),
  
  // 学术搜索
  academicSearch: (topic) => ({
    engines: ["google-scholar", "arxiv"],
    filters: {
      filetype: "pdf"
    },
    query: topic
  }),
  
  // 代码搜索
  codeSearch: (language, topic) => ({
    engines: ["github", "stackoverflow"],
    filters: {
      site: `github.com OR stackoverflow.com`
    },
    query: `${language} ${topic}`
  })
};

// 使用
const template = searchTemplates.techResearch("machine learning");
web_fetch({"url": getEngineUrl(template.engines[0], template.query)});
```

---

## 📚 使用建议

### 性能优化

1. **使用缓存** - 避免重复搜索相同内容
2. **限制并发** - 同时搜索不超过 3 个引擎
3. **设置超时** - 每个请求不超过 30 秒
4. **批量处理** - 多个关键词一起搜索

### 结果质量

1. **多引擎对比** - 验证结果一致性
2. **时间过滤** - 获取最新信息
3. **站点限制** - 提高结果相关性
4. **评分排序** - 优先高质量来源

### 错误处理

```javascript
// 带重试的搜索
async function searchWithRetry(query, engine, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const url = getEngineUrl(engine, query);
      return web_fetch({"url": url});
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

---

## 🔧 扩展开发

### 添加新引擎

```javascript
// 在 config.json 中添加
{
  "engines": {
    "your-engine": {
      "name": "引擎名称",
      "url": "https://example.com/search?q={query}",
      "region": "INT",
      "supports": ["site", "filetype"]
    }
  }
}
```

### 自定义解析器

```javascript
// 为特定引擎创建解析器
function parseEngineResult(engine, html) {
  switch (engine) {
    case "baidu":
      return parseBaiduResults(html);
    case "bing":
      return parseBingResults(html);
    case "brave":
      return parseBraveResults(html);
    default:
      return parseGenericResults(html);
  }
}
```

---

**提示**：这些高级功能需要额外的代码实现。可以根据实际需求选择性地集成到工作流中。
