# 火眼搜索 (Fiery Eye Search)

> "火眼金睛，搜真辨伪"
> "悟空在手，搜索无忧"

基于《西游记》孙悟空**火眼金睛**的智能搜索引擎。在太上老君炼丹炉中炼就，能看透真假，识别真伪，洞察一切搜索结果的本质。

## 🐵 火眼金睛能力

| 悟空能力 | 搜索功能 | 说明 |
|---------|---------|------|
| 🔥 **火眼金睛** | 智能引擎选择 | 识别真假，选择最佳引擎 |
| 🔄 **七十二变** | 8 引擎切换 | 适应不同搜索场景 |
| ☁️ **筋斗云** | 快速搜索 | 一个跟头十万八千里 |
| 🪄 **金箍棒** | 灵活范围 | 可大可小，随心调整 |

## 📦 支持的引擎（8 个）

| 引擎 | 区域 | 特点 | 推荐场景 |
|------|------|------|---------|
| 百度 | 国内 | 中文优化 | 中文内容 |
| Bing 国内 | 国内 | 稳定快速 | 技术文档 |
| Bing 国际 | 国际 | 全球结果 | 国际新闻 |
| Brave | 国际 | 隐私保护 | 隐私搜索 |
| DuckDuckGo | 国际 | 隐私 + Bangs | 快速跳转 |
| WolframAlpha | 国际 | 计算知识 | 数学/转换 |
| Google HK | 国际 | 全球覆盖 | 高质量结果 |
| Startpage | 国际 | Google+ 隐私 | 隐私 + 质量 |

## 🚀 快速开始

### 基础搜索

```javascript
// 百度搜索
web_fetch({"url": "https://www.baidu.com/s?wd=火眼金睛"})

// Bing 国际搜索
web_fetch({"url": "https://www.bing.com/search?q=Fiery+Eye+Search"})

// Brave 搜索
web_fetch({"url": "https://search.brave.com/search?q=privacy+tools"})

// WolframAlpha 计算
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

### 高级搜索

```javascript
// 站点内搜索
web_fetch({"url": "https://www.bing.com/search?q=site:github.com+openclaw"})

// 文件类型搜索
web_fetch({"url": "https://www.bing.com/search?q=machine+learning+filetype:pdf"})

// 时间过滤（过去 1 周）
web_fetch({"url": "https://www.bing.com/search?q=AI+news&tbs=qdr:w"})

// DuckDuckGo Bangs
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!gh+openclaw"})
```

## 📚 文档

| 文件 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | 完整使用指南 |
| [EXAMPLES.md](EXAMPLES.md) | 实际示例 |
| [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md) | 高级功能详解 |
| [TOOLS.md](TOOLS.md) | JavaScript 工具库 |
| [REFERENCES.md](REFERENCES.md) | 参考文档 |
| [CHANGELOG.md](CHANGELOG.md) | 版本历史 |
| [config.json](config.json) | 配置文件 |

## ⚙️ 配置

编辑 `config.json` 修改默认引擎：

```json
{
  "defaultEngine": "bing-cn"
}
```

## 🌐 代理配置

自动继承 OpenClaw 的代理配置：

```bash
HTTP_PROXY=http://172.20.67.14:7890
HTTPS_PROXY=http://172.20.67.14:7890
```

## 📄 License

MIT
