# 火眼搜索 (Fiery Eye Search) - JavaScript 工具库

> "火眼金睛，搜真辨伪"

## 核心工具函数

以下函数可以直接在你的代码中使用，实现高级搜索功能。

---

## 1. 智能引擎选择

```javascript
/**
 * 根据查询内容自动选择最佳搜索引擎
 * @param {string} query - 搜索关键词
 * @param {Object} config - 配置对象
 * @returns {string} - 推荐的引擎 ID
 */
function selectBestEngine(query, config = {}) {
  const rules = [
    {
      pattern: /[\u4e00-\u9fa5]/,
      preferred: ['baidu', 'bing-cn'],
      reason: '中文查询'
    },
    {
      pattern: /(integrate|derivative|solve|calculate|convert|\d+\s*[+\-*/]\s*\d+)/i,
      preferred: ['wolframalpha'],
      reason: '数学/计算'
    },
    {
      pattern: /(privacy|security|password|encryption|anonymous)/i,
      preferred: ['brave', 'duckduckgo'],
      reason: '隐私相关'
    },
    {
      pattern: /(news|最新 | 报道|breaking|latest|update)/i,
      preferred: ['bing-int', 'baidu'],
      reason: '新闻'
    },
    {
      pattern: /(github|code|tutorial|documentation|API|example)/i,
      preferred: ['bing-int', 'duckduckgo'],
      reason: '技术/代码'
    }
  ];

  for (const rule of rules) {
    if (rule.pattern.test(query)) {
      console.log(`智能选择：${rule.preferred[0]} (${rule.reason})`);
      return config.fallback || rule.preferred[0];
    }
  }

  // 默认引擎
  return config.default || 'bing-int';
}

// 使用示例
selectBestEngine("美伊战争最新消息");  // baidu (中文)
selectBestEngine("integrate x^2 dx");  // wolframalpha (数学)
selectBestEngine("Python 教程");        // bing-int (技术)
```

---

## 2. 结果缓存

```javascript
/**
 * 简单的搜索结果缓存类
 */
class SearchCache {
  constructor(maxSize = 1000, ttl = 3600000) {
    this.cache = new Map();
    this.maxSize = maxSize;
    this.ttl = ttl;
  }

  /**
   * 获取缓存结果
   * @param {string} key - 缓存键
   * @returns {Object|null} - 缓存的结果或 null
   */
  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;

    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }

  /**
   * 设置缓存
   * @param {string} key - 缓存键
   * @param {Object} data - 缓存数据
   */
  set(key, data) {
    // 超出容量时删除最旧的
    if (this.cache.size >= this.maxSize) {
      const oldestKey = this.cache.keys().next().value;
      this.cache.delete(oldestKey);
    }

    this.cache.set(key, {
      data,
      timestamp: Date.now()
    });
  }

  /**
   * 清除所有缓存
   */
  clear() {
    this.cache.clear();
  }

  /**
   * 获取缓存统计
   * @returns {Object} - 统计信息
   */
  getStats() {
    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      ttl: this.ttl
    };
  }
}

// 使用示例
const cache = new SearchCache();
const query = "AI 新闻";
const cached = cache.get(query);

if (cached) {
  console.log("使用缓存结果");
} else {
  const result = web_fetch({"url": `https://www.baidu.com/s?wd=${query}`});
  cache.set(query, result);
}
```

---

## 3. 并行多引擎搜索

```javascript
/**
 * 并行搜索多个引擎
 * @param {string} query - 搜索关键词
 * @param {Array<string>} engines - 引擎列表
 * @param {Object} config - 配置
 * @returns {Promise<Object>} - 所有引擎的结果
 */
async function parallelSearch(query, engines = ['baidu', 'bing-int'], config = {}) {
  const engineUrls = {
    'baidu': `https://www.baidu.com/s?wd=${encodeURIComponent(query)}`,
    'bing-cn': `https://cn.bing.com/search?q=${encodeURIComponent(query)}&ensearch=0`,
    'bing-int': `https://www.bing.com/search?q=${encodeURIComponent(query)}&ensearch=1`,
    'brave': `https://search.brave.com/search?q=${encodeURIComponent(query)}`,
    'duckduckgo': `https://lite.duckduckgo.com/lite/?q=${encodeURIComponent(query)}`,
    'wolframalpha': `https://www.wolframalpha.com/input?i=${encodeURIComponent(query)}`
  };

  const delay = config.delay || 500; // 请求间隔（毫秒）
  const results = {};

  for (let i = 0; i < engines.length; i++) {
    const engine = engines[i];
    const url = engineUrls[engine];

    if (!url) {
      results[engine] = { error: 'Unknown engine' };
      continue;
    }

    try {
      // 添加延迟避免过快请求
      if (i > 0) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }

      results[engine] = await web_fetch({"url": url});
    } catch (error) {
      results[engine] = { error: error.message };
    }
  }

  return {
    query,
    timestamp: new Date().toISOString(),
    engines: results
  };
}

// 使用示例
const results = await parallelSearch("Python 教程", ['baidu', 'bing-int', 'brave']);
console.log(results);
```

---

## 4. 批量搜索

```javascript
/**
 * 批量搜索多个关键词
 * @param {Array<string>} queries - 关键词列表
 * @param {string} engine - 使用的引擎
 * @param {Object} config - 配置
 * @returns {Promise<Object>} - 所有查询的结果
 */
async function batchSearch(queries, engine = 'bing-int', config = {}) {
  const results = {};
  const delay = config.delay || 1000;

  for (const query of queries) {
    console.log(`搜索：${query}`);

    try {
      const url = getEngineUrl(engine, query);
      results[query] = await web_fetch({"url": url});

      // 避免过快请求
      await new Promise(resolve => setTimeout(resolve, delay));
    } catch (error) {
      results[query] = { error: error.message };
    }
  }

  return results;
}

// 使用示例
const queries = [
  "美伊战争 最新消息",
  "美伊战争 历史背景",
  "美伊战争 影响分析"
];

const results = await batchSearch(queries);
```

---

## 5. 结构化结果提取

```javascript
/**
 * 从搜索结果 HTML 中提取结构化数据
 * @param {string} html - 搜索结果 HTML
 * @param {string} engine - 引擎类型
 * @returns {Array<Object>} - 结构化的搜索结果
 */
function extractSearchResults(html, engine = 'bing') {
  const results = [];

  if (engine === 'baidu') {
    // 百度结果解析
    const regex = /<h3[^>]*><a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a><\/h3>/g;
    let match;

    while ((match = regex.exec(html)) !== null) {
      results.push({
        url: match[1],
        title: match[2].trim(),
        engine: 'baidu'
      });
    }
  } else {
    // Bing/通用结果解析
    const regex = /<h2[^>]*><a[^>]*href="([^"]*)"[^>]*>([^<]*)<\/a><\/h2>/g;
    let match;

    while ((match = regex.exec(html)) !== null) {
      results.push({
        url: match[1],
        title: match[2].trim(),
        engine: engine
      });
    }
  }

  return results;
}

// 使用示例
const html = web_fetch({"url": "https://www.baidu.com/s?wd=test"});
const structured = extractSearchResults(html, 'baidu');
console.log(structured);
// [
//   { url: "https://...", title: "结果 1", engine: "baidu" },
//   { url: "https://...", title: "结果 2", engine: "baidu" }
// ]
```

---

## 6. 搜索建议

```javascript
/**
 * 获取百度搜索建议
 * @param {string} query - 搜索关键词
 * @returns {Promise<Array<string>>} - 建议列表
 */
async function getBaiduSuggestions(query) {
  const url = `https://suggestion.baidu.com/su?wd=${encodeURIComponent(query)}`;
  const html = await web_fetch({"url": url});

  // 解析建议列表（需要进一步解析 JavaScript 代码）
  const suggestions = [];
  const regex = /s\[(\d+)\]=([^;]+)/g;
  let match;

  while ((match = regex.exec(html)) !== null) {
    try {
      const content = match[2].match(/content:"([^"]*)"/);
      if (content) {
        suggestions.push(content[1]);
      }
    } catch (e) {
      // 忽略解析错误
    }
  }

  return suggestions;
}

// 使用示例
const suggestions = await getBaiduSuggestions("Python");
console.log(suggestions);
// ["Python 教程", "Python 入门", "Python 下载", ...]
```

---

## 7. 高级过滤组合

```javascript
/**
 * 构建高级搜索 URL
 * @param {string} query - 基础查询
 * @param {Object} filters - 过滤条件
 * @param {string} engine - 引擎类型
 * @returns {string} - 完整的搜索 URL
 */
function buildAdvancedSearchUrl(query, filters = {}, engine = 'bing-int') {
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
    if (Array.isArray(filters.exclude)) {
      q += ` -${filters.exclude.join(' -')}`;
    } else {
      q += ` -${filters.exclude}`;
    }
  }

  // 精确匹配
  if (filters.exact) {
    q = `"${q}"`;
  }

  // 标题搜索
  if (filters.intitle) {
    q = `intitle:"${filters.intitle}" ${q}`;
  }

  // 构建 URL
  const encodedQuery = encodeURIComponent(q);

  const urls = {
    'baidu': `https://www.baidu.com/s?wd=${encodedQuery}`,
    'bing-cn': `https://cn.bing.com/search?q=${encodedQuery}&ensearch=0`,
    'bing-int': `https://www.bing.com/search?q=${encodedQuery}&ensearch=1`,
    'brave': `https://search.brave.com/search?q=${encodedQuery}`,
    'duckduckgo': `https://lite.duckduckgo.com/lite/?q=${encodedQuery}`
  };

  let url = urls[engine] || urls['bing-int'];

  // 时间过滤（仅 Bing 支持）
  if (filters.time && (engine.includes('bing'))) {
    url += `&tbs=qdr:${filters.time}`;
  }

  return url;
}

// 使用示例
const url = buildAdvancedSearchUrl("machine learning", {
  site: "github.com",
  filetype: "pdf",
  exclude: ["tutorial", "beginner"],
  time: "w"
}, 'bing-int');

console.log(url);
// https://www.bing.com/search?q=machine+learning+site:github.com+filetype:pdf+-tutorial+-beginner&tbs=qdr:w
```

---

## 8. 搜索历史管理

```javascript
/**
 * 搜索历史管理类
 */
class SearchHistory {
  constructor(maxSize = 100) {
    this.history = [];
    this.maxSize = maxSize;
    this.load();
  }

  /**
   * 添加搜索记录
   * @param {string} query - 搜索关键词
   * @param {string} engine - 使用的引擎
   * @param {Object} result - 搜索结果
   */
  add(query, engine, result) {
    const record = {
      id: Date.now(),
      timestamp: new Date().toISOString(),
      query,
      engine,
      resultPreview: typeof result === 'string' ? result.substring(0, 200) : '[Object]'
    };

    this.history.unshift(record);

    // 限制大小
    if (this.history.length > this.maxSize) {
      this.history = this.history.slice(0, this.maxSize);
    }

    this.save();
  }

  /**
   * 获取最近的搜索
   * @param {number} count - 数量
   * @returns {Array} - 搜索记录
   */
  getRecent(count = 10) {
    return this.history.slice(0, count);
  }

  /**
   * 按关键词搜索历史
   * @param {string} keyword - 关键词
   * @returns {Array} - 匹配的记录
   */
  searchByKeyword(keyword) {
    const lower = keyword.toLowerCase();
    return this.history.filter(item =>
      item.query.toLowerCase().includes(lower)
    );
  }

  /**
   * 按引擎过滤
   * @param {string} engine - 引擎 ID
   * @returns {Array} - 匹配的记录
   */
  getByEngine(engine) {
    return this.history.filter(item => item.engine === engine);
  }

  /**
   * 清除历史
   */
  clear() {
    this.history = [];
    this.save();
  }

  /**
   * 保存历史到文件
   */
  save() {
    // 实现保存到文件
    console.log('Saving search history...');
  }

  /**
   * 从文件加载历史
   */
  load() {
    // 实现从文件加载
    console.log('Loading search history...');
  }
}

// 使用示例
const history = new SearchHistory();
history.add("AI 新闻", "bing-int", "搜索结果...");
history.getRecent(5);
```

---

## 9. 结果质量评分

```javascript
/**
 * 评估搜索结果质量
 * @param {Object} result - 搜索结果
 * @param {string} query - 原始查询
 * @returns {number} - 质量分数 (0-100)
 */
function scoreResult(result, query) {
  let score = 0;

  // 域名权威性 (0-30 分)
  const authoritativeDomains = [
    'gov.cn', 'gov', 'edu.cn', 'edu', '.org',
    'github.com', 'medium.com', 'zhihu.com', 'csdn.net'
  ];
  for (const domain of authoritativeDomains) {
    if (result.url.includes(domain)) {
      score += 30;
      break;
    }
  }

  // 内容长度 (0-20 分)
  const snippetLength = (result.snippet || '').length;
  if (snippetLength > 300) score += 20;
  else if (snippetLength > 150) score += 15;
  else if (snippetLength > 50) score += 10;

  // 日期新鲜度 (0-25 分)
  if (result.date) {
    const daysOld = getDaysOld(result.date);
    if (daysOld <= 7) score += 25;
    else if (daysOld <= 30) score += 20;
    else if (daysOld <= 90) score += 10;
  }

  // 关键词匹配 (0-25 分)
  const title = (result.title || '').toLowerCase();
  const queryLower = query.toLowerCase();
  if (title.includes(queryLower)) score += 25;
  else if (title.includes(queryLower.split(' ')[0])) score += 15;

  return Math.min(score, 100);
}

/**
 * 获取日期距今的天数
 */
function getDaysOld(dateString) {
  const date = new Date(dateString);
  const now = new Date();
  return Math.floor((now - date) / (1000 * 60 * 60 * 24));
}

// 使用示例
const results = [
  { url: "https://github.com/...", title: "AI 项目", snippet: "..." },
  { url: "https://blog.example.com/...", title: "AI 教程", snippet: "..." }
];

const scored = results.map(r => ({
  ...r,
  score: scoreResult(r, "AI")
})).sort((a, b) => b.score - a.score);
```

---

## 10. 搜索模板

```javascript
/**
 * 搜索模板库
 */
const searchTemplates = {
  // 技术研究
  techResearch: (topic) => ({
    name: "技术研究",
    engines: ['bing-int', 'duckduckgo'],
    filters: {
      time: 'm',
      site: 'github.com OR medium.com'
    },
    query: `${topic} tutorial OR documentation OR guide`
  }),

  // 新闻追踪
  newsTracking: (topic) => ({
    name: "新闻追踪",
    engines: ['bing-int', 'baidu'],
    filters: {
      time: 'd'
    },
    query: topic
  }),

  // 学术搜索
  academicSearch: (topic) => ({
    name: "学术搜索",
    engines: ['bing-int'],
    filters: {
      filetype: 'pdf',
      site: 'edu OR org'
    },
    query: topic
  }),

  // 代码搜索
  codeSearch: (language, topic) => ({
    name: "代码搜索",
    engines: ['duckduckgo'],
    filters: {},
    query: `!gh ${language} ${topic}`
  }),

  // 竞品分析
  competitorAnalysis: (company) => ({
    name: "竞品分析",
    engines: ['bing-int', 'baidu'],
    filters: {
      time: 'm'
    },
    query: `${company} review OR analysis OR comparison`
  })
};

// 使用示例
const template = searchTemplates.techResearch("machine learning");
const url = buildAdvancedSearchUrl(
  template.query,
  template.filters,
  template.engines[0]
);
web_fetch({"url": url});
```

---

## 工具函数汇总

| 函数 | 说明 | 使用场景 |
|------|------|---------|
| `selectBestEngine()` | 智能选择引擎 | 自动优化搜索 |
| `SearchCache` | 结果缓存 | 避免重复搜索 |
| `parallelSearch()` | 并行搜索 | 多引擎对比 |
| `batchSearch()` | 批量搜索 | 多个关键词 |
| `extractSearchResults()` | 提取结果 | 结构化数据 |
| `getBaiduSuggestions()` | 搜索建议 | 自动补全 |
| `buildAdvancedSearchUrl()` | 高级过滤 | 精确搜索 |
| `SearchHistory` | 历史管理 | 记录追踪 |
| `scoreResult()` | 质量评分 | 结果排序 |
| `searchTemplates` | 搜索模板 | 预设场景 |

---

**提示**：这些工具函数可以根据实际需求进行定制和扩展！
