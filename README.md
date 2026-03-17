# OpenClaw Skills

我的自定义 OpenClaw 技能集合。

## 📦 技能列表

| 技能 | 描述 | 版本 | 状态 |
|------|------|------|------|
| [火眼搜索](fiery-eye-search/) | 基于《西游记》孙悟空火眼金睛的智能搜索引擎 | v2.0.0 | ✅ |

## 🔥 火眼搜索 (Fiery Eye Search)

> "火眼金睛，搜真辨伪"
> "悟空在手，搜索无忧"

基于《西游记》孙悟空**火眼金睛**的智能搜索引擎。在太上老君炼丹炉中炼就，能看透真假，识别真伪，洞察一切。

### 特点

- 🔥 **火眼金睛** - 智能引擎选择，识别最佳结果
- 👁️ **七十二变** - 8 引擎灵活切换，适应不同场景
- ☁️ **筋斗云** - 快速搜索，低延迟响应
- 🪄 **金箍棒** - 灵活调整搜索范围，可大可小

### 支持的引擎

| 引擎 | 区域 | 特点 |
|------|------|------|
| 百度 | 国内 | 中文优化 |
| Bing 国内 | 国内 | 稳定快速 |
| Bing 国际 | 国际 | 全球结果 |
| Brave | 国际 | 隐私保护 |
| DuckDuckGo | 国际 | 隐私 + Bangs |
| WolframAlpha | 国际 | 计算知识 |
| Google HK | 国际 | 全球覆盖 |
| Startpage | 国际 | Google+ 隐私 |

### 快速开始

```javascript
// 百度搜索
web_fetch({"url": "https://www.baidu.com/s?wd=火眼金睛"})

// Bing 国际搜索
web_fetch({"url": "https://www.bing.com/search?q=Fiery+Eye+Search"})

// WolframAlpha 计算
web_fetch({"url": "https://www.wolframalpha.com/input?i=100+USD+to+CNY"})
```

### 文档

- [SKILL.md](fiery-eye-search/SKILL.md) - 完整使用指南
- [EXAMPLES.md](fiery-eye-search/EXAMPLES.md) - 实际示例
- [ADVANCED_FEATURES.md](fiery-eye-search/ADVANCED_FEATURES.md) - 高级功能
- [TOOLS.md](fiery-eye-search/TOOLS.md) - JavaScript 工具库

## 📚 安装

```bash
# 克隆所有技能
git clone https://github.com/WTFGEDelphia/openclaw-skills.git

# 复制特定技能到 OpenClaw
cp -r openclaw-skills/fiery-eye-search ~/.openclaw/workspace/skills/
```

## 🛠️ 开发

```bash
# 本地开发
cd ~/.openclaw/workspace/skills/

# 修改后提交
git add .
git commit -m "feat: 更新技能"
git push cloud main
```

## 📄 License

MIT

## 👤 作者

- GitHub: [@WTFGEDelphia](https://github.com/WTFGEDelphia)
