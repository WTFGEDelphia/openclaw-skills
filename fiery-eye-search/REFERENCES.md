# 火眼搜索 (Fiery Eye Search) - 参考文档

> "火眼金睛，搜真辨伪"

## 搜索引擎对比

### 国内搜索引擎

| 引擎 | URL | 优势 | 劣势 |
|------|-----|------|------|
| **百度** | `https://www.baidu.com/s?wd={query}` | 中文优化最好，国内资源多 | 广告较多，国际内容少 |
| **Bing 国内** | `https://cn.bing.com/search?q={query}&ensearch=0` | 稳定快速，界面简洁 | 中文内容略少于百度 |
| **360 搜索** | `https://www.so.com/s?q={query}` | 国内访问快 | 搜索结果质量一般 |
| **搜狗** | `https://sogou.com/web?query={query}` | 微信内容集成 | 广告较多 |
| **头条搜索** | `https://so.toutiao.com/search?keyword={query}` | 新闻资讯丰富 | 技术内容少 |

### 国际搜索引擎

| 引擎 | URL | 优势 | 劣势 |
|------|-----|------|------|
| **Bing 国际** | `https://www.bing.com/search?q={query}&ensearch=1` | 全球覆盖，稳定 | 需要代理 |
| **Brave** | `https://search.brave.com/search?q={query}` | 隐私保护，独立索引 | 中文支持一般 |
| **DuckDuckGo** | `https://lite.duckduckgo.com/lite/?q={query}` | 隐私保护，Bangs 功能 | 反爬虫严格 |
| **WolframAlpha** | `https://www.wolframalpha.com/input?i={query}` | 计算能力，知识查询 | 不适合一般搜索 |

---

## 高级搜索语法

### 通用操作符

| 操作符 | 说明 | 示例 | 支持引擎 |
|--------|------|------|---------|
| `site:` | 站点内搜索 | `site:github.com python` | 百度，Bing, Brave |
| `filetype:` | 文件类型 | `filetype:pdf machine learning` | 百度，Bing, Brave |
| `""` | 精确匹配 | `"machine learning"` | 所有引擎 |
| `-` | 排除关键词 | `python -snake` | 百度，Bing, Brave |
| `OR` | 或关系 | `cat OR dog` | Bing, Brave |
| `intitle:` | 标题搜索 | `intitle:python tutorial` | 百度，Bing |
| `inurl:` | URL 搜索 | `inurl:github.com` | 百度，Bing |

### 百度特有语法

| 语法 | 示例 | 说明 |
|------|------|------|
| `intitle:` | `intitle:python` | 标题中包含 |
| `inurl:` | `inurl:github.com` | URL 中包含 |
| `intext:` | `intext:教程` | 正文中包含 |
| `filetype:` | `filetype:pdf` | 文件类型 |
| `site:` | `site:zhihu.com` | 站点搜索 |
| `related:` | `related:zhihu.com` | 相关站点 |

### DuckDuckGo Bangs

| Bang | 目标 | 示例 |
|------|------|------|
| `!g` | Google | `!g+python` |
| `!gh` | GitHub | `!gh+tensorflow` |
| `!w` | Wikipedia | `!w+AI` |
| `!yt` | YouTube | `!yt+tutorial` |
| `!so` | Stack Overflow | `!so+javascript` |
| `!npm` | npm | `!npm+express` |
| `!pypi` | PyPI | `!pypi+requests` |
| `!a` | Amazon | `!a+keyboard` |
| `!wma` | WolframAlpha | `!wma+integral` |
| `!ddg` | DuckDuckGo | `!ddg+privacy` |
| `!r` | Reddit | `!r+python` |
| `!t` | Twitter | `!t+AI` |
| `!m` | Maps | `!m+Beijing` |
| `!i` | Images | `!i+cat` |
| `!wca` | Wolfram Cloud | `!wca+integral` |

### 时间过滤（Bing）

| 参数 | 说明 | 示例 |
|------|------|------|
| `qdr:h` | 过去 1 小时 | `&tbs=qdr:h` |
| `qdr:d` | 过去 1 天 | `&tbs=qdr:d` |
| `qdr:w` | 过去 1 周 | `&tbs=qdr:w` |
| `qdr:m` | 过去 1 月 | `&tbs=qdr:m` |
| `qdr:y` | 过去 1 年 | `&tbs=qdr:y` |

---

## URL 编码参考

### 常用字符编码

| 字符 | URL 编码 | 说明 |
|------|---------|------|
| 空格 | `+` 或 `%20` | 搜索词分隔 |
| `"` | `%22` | 双引号 |
| `#` | `%23` | 井号 |
| `%` | `%25` | 百分号 |
| `&` | `%26` | 和号 |
| `=` | `%3D` | 等号 |
| `?` | `%3F` | 问号 |
| `:` | `%3A` | 冒号 |
| `/` | `%2F` | 斜杠 |

### 中文编码示例

```
美伊战争 → %E7%BE%8E%E4%BC%8A%E6%88%98%E4%BA%89
人工智能 → %E4%BA%BA%E5%B7%A5%E6%99%BA%E8%83%BD
Python 教程 → Python+%E6%95%99%E7%A8%8B
```

---

## 故障排查

### 连接问题

| 问题 | 原因 | 解决方法 |
|------|------|---------|
| 连接超时 | 代理配置问题 | 检查 `HTTP_PROXY` 环境变量 |
| SSL 错误 | TLS 版本不兼容 | 使用 `--insecure` 或更新代理 |
| 403 Forbidden | 反爬虫机制 | 更换搜索引擎 |
| CAPTCHA | 触发验证 | 降低请求频率或换引擎 |

### 搜索质量问题

| 问题 | 原因 | 解决方法 |
|------|------|---------|
| 结果太少 | 关键词太具体 | 简化搜索词 |
| 广告太多 | 引擎广告策略 | 使用 Brave 或 DDG |
| 内容不相关 | 关键词模糊 | 添加限定词 |
| 中文结果少 | 国际引擎 | 改用百度 |

---

## 性能优化

### 请求频率

| 引擎 | 推荐频率 | 说明 |
|------|---------|------|
| 百度 | 10 次/分钟 | 国内引擎较宽松 |
| Bing | 15 次/分钟 | 国际引擎较稳定 |
| Brave | 10 次/分钟 | 隐私引擎有限制 |
| DDG | 5 次/分钟 | 反爬虫严格 |
| WolframAlpha | 5 次/分钟 | 计算资源有限 |

### 缓存策略

```javascript
// 对相同查询使用缓存
const cache = new Map();

function search(query) {
  if (cache.has(query)) {
    return cache.get(query);
  }
  const result = web_fetch({"url": `https://www.baidu.com/s?wd=${query}`});
  cache.set(query, result);
  return result;
}
```

---

## 最佳实践

### 1. 根据场景选择引擎

```javascript
// 中文内容 → 百度
web_fetch({"url": "https://www.baidu.com/s?wd=人工智能"})

// 技术文档 → Bing 国内
web_fetch({"url": "https://cn.bing.com/search?q=python+async"})

// 国际新闻 → Bing 国际
web_fetch({"url": "https://www.bing.com/search?q=US+Iran+conflict"})

// 隐私搜索 → Brave
web_fetch({"url": "https://search.brave.com/search?q=privacy+tools"})

// 快速跳转 → DuckDuckGo
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!gh+openclaw"})

// 计算查询 → WolframAlpha
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

### 2. 组合使用多个引擎

```javascript
// 全面研究：先用百度，再用 Bing 国际
const cnResults = web_fetch({"url": "https://www.baidu.com/s?wd=美伊战争"});
const enResults = web_fetch({"url": "https://www.bing.com/search?q=US+Iran+conflict"});
```

### 3. 使用高级语法提高精度

```javascript
// 精确匹配 + 站点限制 + 文件类型
web_fetch({
  "url": "https://www.bing.com/search?q=site:github.com+python+filetype:pdf"
})
```

---

## 相关资源

### 官方文档

- [百度搜索语法](https://baike.baidu.com/item/百度搜索语法)
- [Bing 高级搜索](https://help.bing.microsoft.com/#apex/bing/zh-CHS/10001/-1)
- [DuckDuckGo Bangs](https://duckduckgo.com/bangs)
- [WolframAlpha 示例](https://www.wolframalpha.com/examples)

### 工具推荐

- [URL 编码工具](https://www.urlencoder.org/)
- [搜索引擎对比](https://alternativeto.net/)
- [隐私搜索引擎列表](https://privacytools.io/)

---

**提示**：定期更新此文档以反映搜索引擎的变更和新功能！
