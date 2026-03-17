# Changelog

All notable changes to 火眼搜索 (Fiery Eye Search) will be documented in this file.

## [2.0.0] - 2026-03-17

### 🐵 重大更新

- **重命名**：从 default-search 改为 火眼搜索 (Fiery Eye Search)
- **主题**：基于《西游记》孙悟空火眼金睛
- **Slogan**： "火眼金睛，搜真辨伪"

### Added

- **新引擎**:
  - Google HK
  - Startpage
- **高级功能**:
  - 智能引擎选择（火眼金睛）
  - 结果缓存
  - 并行多引擎搜索（七十二变）
  - 批量搜索（筋斗云）
  - 搜索建议/自动补全
  - 图像/视频搜索
  - 搜索历史管理
  - 结果对比分析
  - 搜索模板（预设场景）
- **增强配置**:
  - 引擎优先级设置
  - 智能选择规则
  - 缓存配置
  - 模板定义
- **新文档**:
  - ADVANCED_FEATURES.md - 高级功能详解
  - TOOLS.md - JavaScript 工具库

### Changed

- 版本升级到 2.0.0
- 添加 2 个新引擎
- 增强 config.json 智能选择规则
- 改进文档结构

### Features

- Smart engine selection based on query type (Chinese, Math, Privacy, News, Code)
- Configurable caching with TTL and max size
- Concurrent search limit for performance
- Retry logic with exponential backoff
- Search templates for common scenarios

---

## [1.0.0] - 2026-03-17

### Added

- 初始版本（default-search）
- 支持 6 个搜索引擎
- 可配置默认引擎
- 高级搜索语法支持
- 时间过滤
- DuckDuckGo Bangs
- WolframAlpha 计算
- 自动代理配置
- 完整文档

### Features

- 无需 API key
- 使用内置 web_fetch 工具
- 自动代理继承
- 区域特定搜索选项
- 隐私保护替代方案

### Known Limitations

- 部分引擎可能触发验证
- 时间过滤仅限 Bing
- DuckDuckGo Lite 有反爬虫
- 国际引擎需要代理
