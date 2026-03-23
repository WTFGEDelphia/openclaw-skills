---
name: fiery-eye-search
displayName: 火眼搜索
displayNameEn: Fiery Eye Search
description: 基于《西游记》孙悟空火眼金睛的智能搜索引擎。8 引擎聚合，智能选择，搜真辨伪。完全独立，无需 API key。
---

# 火眼搜索 (Fiery Eye Search)

> "火眼金睛，搜真辨伪"
> "悟空在手，搜索无忧"

基于《西游记》孙悟空**火眼金睛**的智能搜索引擎。在太上老君炼丹炉中炼就，能看透真假，识别真伪，洞察一切搜索结果的本质。

**特点**：
- 🔥 **火眼金睛** - 智能引擎选择，识别最佳结果
- 👁️ **七十二变** - 8 引擎灵活切换，适应不同场景
- ☁️ **筋斗云** - 快速搜索，低延迟响应
- 🪄 **金箍棒** - 灵活调整搜索范围，可大可小
- ✅ **完全独立** - 无需 API key，无需额外配置
- ✅ **自动代理** - 继承 OpenClaw 代理配置
- ✅ **支持高级搜索语法**

---

## 📦 支持的搜索引擎

| 引擎 | 区域 | 特点 | 适用场景 |
|------|------|------|---------|
| **百度** | 国内 | 中文优化 | 中文内容、国内资源 |
| **Bing 国内** | 国内 | 稳定快速 | 通用搜索、技术文档 |
| **Bing 国际** | 国际 | 全球结果 | 英文内容、国际新闻 |
| **Brave** | 国际 | 隐私保护 | 无跟踪搜索 |
| **DuckDuckGo** | 国际 | 隐私 + Bangs | 快速搜索、站点跳转 |
| **WolframAlpha** | 国际 | 计算知识 | 数学、转换、事实查询 |

---

## 🚀 快速开始

### 方式 1：使用默认引擎

```javascript
// 直接搜索（使用配置的默认引擎）
web_fetch({"url": "https://cn.bing.com/search?q=你的关键词&ensearch=0"})
```

### 方式 2：指定引擎

```javascript
// 百度搜索
web_fetch({"url": "https://www.baidu.com/s?wd=美伊战争"})

// Bing 国际搜索
web_fetch({"url": "https://www.bing.com/search?q=US+Iran+conflict"})

// Brave 搜索
web_fetch({"url": "https://search.brave.com/search?q=privacy+tools"})

// DuckDuckGo 搜索
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=python+tutorial"})

// WolframAlpha 查询
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

---

## ⚙️ 配置默认引擎

编辑 `config.json` 修改默认引擎：

```json
{
  "defaultEngine": "bing-int"
}
```

**可选值**：
- `"baidu"` - 百度
- `"bing-cn"` - Bing 国内
- `"bing-int"` - Bing 国际
- `"brave"` - Brave Search
- `"duckduckgo"` - DuckDuckGo
- `"wolframalpha"` - WolframAlpha

---

## 📝 高级搜索语法

### 站点内搜索

```javascript
// GitHub 上的 Python 项目
web_fetch({"url": "https://cn.bing.com/search?q=site:github.com+python+tutorial"})

// 百度站内搜索
web_fetch({"url": "https://www.baidu.com/s?wd=site:zhihu.com+人工智能"})
```

### 文件类型搜索

```javascript
// PDF 文档
web_fetch({"url": "https://cn.bing.com/search?q=machine+learning+filetype:pdf"})

// PPT 演示文稿
web_fetch({"url": "https://www.baidu.com/s?wd=python+course+filetype:ppt"})
```

### 精确匹配

```javascript
// 精确短语
web_fetch({"url": "https://cn.bing.com/search?q=%22machine+learning%22"})

// 排除关键词
web_fetch({"url": "https://cn.bing.com/search?q=python+-snake"})
```

### 时间过滤（Bing）

```javascript
// 过去 1 小时
web_fetch({"url": "https://cn.bing.com/search?q=AI+news&tbs=qdr:h"})

// 过去 1 天
web_fetch({"url": "https://cn.bing.com/search?q=AI+news&tbs=qdr:d"})

// 过去 1 周
web_fetch({"url": "https://cn.bing.com/search?q=AI+news&tbs=qdr:w"})

// 过去 1 月
web_fetch({"url": "https://cn.bing.com/search?q=AI+news&tbs=qdr:m"})

// 过去 1 年
web_fetch({"url": "https://cn.bing.com/search?q=AI+news&tbs=qdr:y"})
```

---

## 🔧 引擎特定功能

### 百度特有语法

```javascript
// 标题搜索
web_fetch({"url": "https://www.baidu.com/s?wd=intitle:python+tutorial"})

// 链接搜索
web_fetch({"url": "https://www.baidu.com/s?wd=inurl:github.com+python"})
```

### DuckDuckGo Bangs

```javascript
// GitHub 搜索
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!gh+tensorflow"})

// Wikipedia
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!w+artificial+intelligence"})

// YouTube
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!yt+python+tutorial"})

// Stack Overflow
web_fetch({"url": "https://lite.duckduckgo.com/lite/?q=!so+async+await"})
```

### WolframAlpha 查询

```javascript
// 数学计算
web_fetch({"url": "https://www.wolframalpha.com/input?i=integrate+x%5E2+dx"})

// 单位转换
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})

// 股票查询
web_fetch({"url": "https://www.wolframalpha.com/input?i=AAPL+stock"})

// 天气
web_fetch({"url": "https://www.wolframalpha.com/input?i=weather+in+Beijing"})

// 复杂计算
web_fetch({"url": "https://www.wolframalpha.com/input?i=solve+x%5E2+%2B+2x+%2B+1+%3D+0"})
```

---

## 📊 使用场景推荐

| 场景 | 推荐引擎 | 示例 |
|------|---------|------|
| **中文内容** | 百度 | `wd=人工智能 最新进展` |
| **技术文档** | Bing 国内 | `q=python+async+await` |
| **国际新闻** | Bing 国际 | `q=US+Iran+conflict` |
| **隐私搜索** | Brave | `q=privacy+tools+2026` |
| **快速跳转** | DuckDuckGo | `q=!gh+openclaw` |
| **计算/知识** | WolframAlpha | `i=100+USD+to+CNY` |

---

## 🌐 代理配置

本技能自动继承 OpenClaw 的代理配置：

```bash
# 已配置
HTTP_PROXY=http://172.20.67.14:7890
HTTPS_PROXY=http://172.20.67.14:7890
```

**无需额外配置**，所有请求自动通过代理。

---

## 📈 性能对比

| 引擎 | 速度 | 稳定性 | 中文支持 | 推荐度 |
|------|------|--------|---------|--------|
| 百度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Bing 国内 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Bing 国际 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| Brave | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| DuckDuckGo | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| WolframAlpha | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐⭐ |

---

## 🛠️ 故障排查

### 问题 1：搜索结果为空

**原因**：搜索引擎反爬虫机制

**解决**：
```javascript
// 改用其他引擎
web_fetch({"url": "https://www.baidu.com/s?wd=你的关键词"})
```

### 问题 2：连接超时

**原因**：代理配置问题

**解决**：
```bash
# 检查代理状态
export HTTP_PROXY=http://172.20.67.14:7890
export HTTPS_PROXY=http://172.20.67.14:7890

# 重启 Gateway
systemctl --user restart openclaw-gateway.service
```

### 问题 3：验证码/拦截

**原因**：搜索引擎检测到自动化访问

**解决**：
```javascript
// 改用更友好的引擎
// DuckDuckGo Lite → 百度 → Bing
web_fetch({"url": "https://www.baidu.com/s?wd=你的关键词"})
```

---

## 🚀 高级功能

| 功能 | 说明 | 文档 |
|------|------|------|
| **智能引擎选择** | 根据查询类型自动选择最佳引擎 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#1-智能引擎选择) |
| **结果缓存** | 避免重复搜索，提高性能 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#2-结果缓存) |
| **并行多引擎搜索** | 同时搜索多个引擎，聚合结果 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#3-并行多引擎搜索) |
| **结构化结果提取** | 从搜索结果中提取结构化数据 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#4-结构化结果提取) |
| **批量搜索** | 一次搜索多个关键词 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#5-批量搜索) |
| **搜索建议** | 获取自动补全建议 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#6-搜索建议自动补全) |
| **图像/视频搜索** | 扩展搜索类型 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#7-图像视频搜索) |
| **高级过滤组合** | 组合多个过滤条件 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#8-高级过滤组合) |
| **搜索历史** | 记录和管理搜索历史 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#9-搜索历史) |
| **结果对比分析** | 对比不同引擎的搜索结果 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#10-结果对比分析) |
| **搜索结果排名** | 根据多个指标评估结果质量 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#11-搜索结果排名) |
| **搜索模板** | 预设常用搜索场景 | [ADVANCED_FEATURES.md](ADVANCED_FEATURES.md#12-搜索模板) |

## 📚 参考文档

- [Bing 高级搜索语法](https://help.bing.microsoft.com/#apex/bing/zh-CHS/10001/-1)
- [百度搜索语法](https://baike.baidu.com/item/百度搜索语法)
- [DuckDuckGo Bangs](https://duckduckgo.com/bangs)
- [WolframAlpha 示例](https://www.wolframalpha.com/examples)
- [高级功能详解](ADVANCED_FEATURES.md)

---

## 📝 版本历史

### v1.0.0 (2026-03-17)

- 初始版本
- 支持 6 个搜索引擎
- 配置化默认引擎
- 代理自动配置

---

## 📄 License

MIT

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

**提示**：这是 `web_fetch` 的封装技能，不是独立工具。所有搜索最终通过 `web_fetch` 执行。
