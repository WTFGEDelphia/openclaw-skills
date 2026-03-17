# 火眼搜索 (Fiery Eye Search)

> "火眼金睛，搜真辨伪"
> "悟空在手，搜索无忧"

基于《西游记》孙悟空**火眼金睛**的智能搜索引擎。在太上老君炼丹炉中炼就，能看透真假，识别真伪，洞察一切。

## 快速开始

### 1. 选择默认引擎

编辑 `config.json`：

```json
{
  "defaultEngine": "bing-cn"
}
```

### 2. 开始搜索

```javascript
// 使用默认引擎
web_fetch({"url": "https://cn.bing.com/search?q=你的关键词&ensearch=0"})

// 或使用特定引擎
web_fetch({"url": "https://www.baidu.com/s?wd=美伊战争"})
web_fetch({"url": "https://search.brave.com/search?q=privacy+tools"})
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

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

## 🔥 高级功能

### 火眼金睛能力
- 🔥 **火眼金睛** - 智能引擎选择（自动选择最佳引擎）
- 🔄 **七十二变** - 8 引擎灵活切换
- ☁️ **筋斗云** - 快速搜索，低延迟
- 🪄 **金箍棒** - 灵活调整搜索范围

### 基础功能
- ✅ 站点内搜索 (`site:`)
- ✅ 文件类型搜索 (`filetype:`)
- ✅ 精确匹配 (`"..."`)
- ✅ 排除关键词 (`-`)
- ✅ 时间过滤 (`tbs=qdr:w`)
- ✅ DuckDuckGo Bangs (`!gh`, `!w`, `!yt`)
- ✅ WolframAlpha 计算

### 新增高级功能
- 🚀 结果缓存（避免重复搜索）
- 🚀 并行多引擎搜索
- 🚀 批量搜索
- 🚀 搜索建议/自动补全
- 🚀 图像/视频搜索
- 🚀 搜索历史管理
- 🚀 结果对比分析
- 🚀 搜索模板（预设场景）

## 文档

| 文件 | 说明 |
|------|------|
| [SKILL.md](SKILL.md) | 完整使用指南 |
| [EXAMPLES.md](EXAMPLES.md) | 实际示例 |
| [REFERENCES.md](REFERENCES.md) | 参考文档 |
| [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md) | 高级功能详解 |
| [TOOLS.md](TOOLS.md) | JavaScript 工具库 |

## 代理配置

自动继承 OpenClaw 代理配置：

```bash
HTTP_PROXY=http://172.20.67.14:7890
HTTPS_PROXY=http://172.20.67.14:7890
```

无需额外配置！

## License

MIT
