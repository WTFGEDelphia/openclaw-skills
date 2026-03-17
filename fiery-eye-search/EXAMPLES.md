# 火眼搜索 (Fiery Eye Search) - 使用示例

> "火眼金睛，搜真辨伪"

## 基础搜索

### 1. 中文搜索（百度）

```javascript
// 搜索美伊战争
web_fetch({"url": "https://www.baidu.com/s?wd=美伊战争"})

// 搜索 Python 教程
web_fetch({"url": "https://www.baidu.com/s?wd=Python+教程"})
```

### 2. 英文搜索（Bing 国际）

```javascript
// 搜索 AI 新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news+2026"})

// 搜索技术文档
web_fetch({"url": "https://www.bing.com/search?q=python+async+programming"})
```

---

## 高级搜索

### 站点内搜索

```javascript
// GitHub 上的 OpenClaw 项目
web_fetch({"url": "https://www.bing.com/search?q=site:github.com+openclaw"})

// 知乎上的 AI 讨论
web_fetch({"url": "https://www.baidu.com/s?wd=site:zhihu.com+人工智能"})

// MDN 上的 JavaScript 文档
web_fetch({"url": "https://www.bing.com/search?q=site:developer.mozilla.org+async+await"})
```

### 文件类型搜索

```javascript
// PDF 格式的机器学习论文
web_fetch({"url": "https://www.bing.com/search?q=machine+learning+filetype:pdf"})

// PPT 格式的 Python 课程
web_fetch({"url": "https://www.baidu.com/s?wd=python+course+filetype:ppt"})

// Excel 数据文件
web_fetch({"url": "https://www.bing.com/search?q=sales+data+filetype:xlsx"})
```

### 精确匹配

```javascript
// 精确匹配短语
web_fetch({"url": "https://www.bing.com/search?q=%22machine+learning%22"})

// 排除特定关键词
web_fetch({"url": "https://www.bing.com/search?q=python+-snake+-jupyter"})
```

---

## 时间过滤

### 最新新闻（Bing）

```javascript
// 过去 1 小时的新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:h"})

// 过去 1 天的新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:d"})

// 过去 1 周的新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:w"})

// 过去 1 个月的新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:m"})

// 过去 1 年的新闻
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:y"})
```

---

## DuckDuckGo Bangs

### 快速跳转

```javascript
// GitHub 搜索
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!gh+tensorflow"})

// Wikipedia
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!w+artificial+intelligence"})

// YouTube 视频
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!yt+python+tutorial"})

// Stack Overflow
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!so+async+await"})

// npm 包
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!npm+express"})

// Amazon 商品
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!a+mechanical+keyboard"})
```

### 常用 Bangs 列表

| Bang | 目标站点 | 示例 |
|------|---------|------|
| `!g` | Google | `!g+python` |
| `!gh` | GitHub | `!gh+react` |
| `!w` | Wikipedia | `!w+AI` |
| `!yt` | YouTube | `!yt+tutorial` |
| `!so` | Stack Overflow | `!so+javascript` |
| `!npm` | npm | `!npm+express` |
| `!pypi` | PyPI | `!pypi+requests` |
| `!a` | Amazon | `a+keyboard` |
| `!wma` | WolframAlpha | `!wma+integral` |
| `!ddg` | DuckDuckGo | `!ddg+privacy` |

---

## WolframAlpha 计算

### 数学计算

```javascript
// 积分
web_fetch({"url": "https://www.wolframalpha.com/input?i=integrate+x%5E2+dx"})

// 方程求解
web_fetch({"url": "https://www.wolframalpha.com/input?i=solve+x%5E2+%2B+2x+%2B+1+%3D+0"})

// 矩阵运算
web_fetch({"url": "https://www.wolframalpha.com/input?i=inverse+of+%5B%5B1%2C2%5D%2C%5B3%2C4%5D%5D"})

// 微分
web_fetch({"url": "https://www.wolframalpha.com/input?i=derivative+of+x%5E3+%2B+2x%5E2"})
```

### 单位转换

```javascript
// 货币转换
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})

// 长度转换
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+km+to+miles"})

// 温度转换
web_fetch({"url": "https://www.wolframalpha.com/input?i=37+C+to+F"})

// 数据存储
web_fetch({"url": "https://www.wolframalpha.com/input?i=1+TB+to+GB"})
```

### 事实查询

```javascript
// 股票价格
web_fetch({"url": "https://www.wolframalpha.com/input?i=AAPL+stock"})

// 天气
web_fetch({"url": "https://www.wolframalpha.com/input?i=weather+in+Beijing"})

// 人口统计
web_fetch({"url": "https://www.wolframalpha.com/input?i=population+of+China"})

// 历史事件
web_fetch({"url": "https://www.wolframalpha.com/input?i=World+War+II+dates"})
```

---

## 实际应用场景

### 1. 研究美伊局势

```javascript
// 百度搜索中文报道
web_fetch({"url": "https://www.baidu.com/s?wd=美伊战争+2026"})

// Bing 国际搜索英文报道
web_fetch({"url": "https://www.bing.com/search?q=US+Iran+conflict+2026"})

// 时间过滤：过去 1 周
web_fetch({"url": "https://www.bing.com/search?q=US+Iran+conflict&tbs=qdr:w"})
```

### 2. 学习 Python 异步编程

```javascript
// MDN 官方文档
web_fetch({"url": "https://www.bing.com/search?q=site:developer.mozilla.org+async+await"})

// GitHub 示例代码
web_fetch({"url": "https://www.bing.com/search?q=site:github.com+python+async+example"})

// Stack Overflow 问答
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!so+python+async"})
```

### 3. 查找 PDF 论文

```javascript
// 机器学习论文
web_fetch({"url": "https://www.bing.com/search?q=machine+learning+survey+filetype:pdf"})

// 特定作者论文
web_fetch({"url": "https://www.bing.com/search?q=author:%22Yann+LeCun%22+deep+learning+filetype:pdf"})
```

### 4. 汇率和财经查询

```javascript
// 实时汇率
web_fetch({"url": "https://www.wolframalpha.com/input?i=CNY+to+USD"})

// 股票行情
web_fetch({"url": "https://www.wolframalpha.com/input?i=600519+SS+stock"})

// 加密货币价格
web_fetch({"url": "https://www.wolframalpha.com/input?i=BTC+to+USD"})
```

---

## 性能优化技巧

### 1. 选择最快的引擎

| 需求 | 推荐引擎 | 原因 |
|------|---------|------|
| 中文内容 | 百度 | 中文优化最好 |
| 技术文档 | Bing 国内 | 稳定快速 |
| 国际新闻 | Bing 国际 | 全球覆盖 |
| 隐私搜索 | Brave | 无跟踪 |
| 快速跳转 | DuckDuckGo | Bangs 功能 |
| 计算查询 | WolframAlpha | 专业计算 |

### 2. 避免反爬虫

```javascript
// ❌ 容易触发验证
web_fetch({"url": "https://www.google.com/search?q=test"})

// ✅ 更稳定
web_fetch({"url": "https://www.baidu.com/s?wd=test"})
web_fetch({"url": "https://search.brave.com/search?q=test"})
```

### 3. 使用文本模式

```javascript
// ✅ 推荐：文本模式更干净
web_fetch({
  "url": "https://www.baidu.com/s?wd=test",
  "extractMode": "text",
  "maxChars": 8000
})

// ❌ 不推荐：Markdown 模式可能包含多余格式
web_fetch({
  "url": "https://www.baidu.com/s?wd=test",
  "extractMode": "markdown"
})
```

---

## 常见问题

### Q: 为什么搜索结果很少？

A: 尝试更换引擎或简化搜索词：
```javascript
// 从复杂查询改为简单查询
web_fetch({"url": "https://www.baidu.com/s?wd=AI"})
```

### Q: 如何搜索特定网站的内容？

A: 使用 `site:` 操作符：
```javascript
web_fetch({"url": "https://www.bing.com/search?q=site:zhihu.com+人工智能"})
```

### Q: 如何排除某些关键词？

A: 使用 `-` 操作符：
```javascript
web_fetch({"url": "https://www.bing.com/search?q=python+-snake"})
```

### Q: 如何搜索 PDF 文件？

A: 使用 `filetype:` 操作符：
```javascript
web_fetch({"url": "https://www.bing.com/search?q=machine+learning+filetype:pdf"})
```

---

**提示**：根据实际需求选择合适的搜索引擎，可以获得更好的搜索结果！
