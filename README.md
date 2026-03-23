# OpenClaw Skills

我的自定义 OpenClaw 技能集合。

## 📦 技能列表

| 技能 | 描述 | 版本 | 状态 |
|------|------|------|------|
| [火眼搜索](skills/fiery-eye-search/) | 基于《西游记》孙悟空火眼金睛的智能搜索引擎 | v2.0.0 | ✅ |
| [update-openclaw-danghuangshang](skills/update-openclaw-danghuangshang/) | AI 朝廷项目集成/更新/版本管理工具 | v7.2 | ✅ |
| [weather-notify](skills/weather-notify/) | 定时天气推送技能（双模式发送） | v1.3.0 | ✅ |

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

- [SKILL.md](skills/fiery-eye-search/SKILL.md) - 完整使用指南
- [EXAMPLES.md](skills/fiery-eye-search/EXAMPLES.md) - 实际示例
- [ADVANCED_FEATURES.md](skills/fiery-eye-search/ADVANCED_FEATURES.md) - 高级功能
- [TOOLS.md](skills/fiery-eye-search/TOOLS.md) - JavaScript 工具库

## 📚 安装

```bash
# 克隆所有技能
git clone https://github.com/WTFGEDelphia/openclaw-skills.git

# 复制特定技能到 OpenClaw
cp -r openclaw-skills/skills/fiery-eye-search ~/.openclaw/workspace/skills/
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

---

## 🌤️ Weather-Notify (天气推送技能)

> "每日天气播报，穿衣指南贴心"

定时推送天气到 Discord 频道的智能工具，支持双模式发送和自动降级机制。

### 核心功能

| 功能 | 说明 |
|------|------|
| **双模式发送** | OpenClaw message 工具 + Discord Webhook，自动降级 |
| **天气数据** | Open-Meteo API（免费，无需 Key） |
| **穿衣推荐** | 7 个温度区间 + 5 种特殊天气推荐 |
| **温馨提示** | 8 种提示类型（雨天、雾天、温差、高温等） |
| **推送历史** | 自动记录最近 100 条推送记录 |
| **环境变量** | 5 个环境变量支持，便于部署 |
| **单元测试** | 113+ 测试用例，核心功能覆盖 |

### 快速开始

```bash
# 1. 复制配置示例
cd skills/weather-notify/
cp config.example.json config.json
cp .env.example .env

# 2. 编辑配置
# 编辑 .env 文件，填入你的 Discord 配置

# 3. 安装依赖
pip install -r requirements.txt

# 4. 测试运行
python main.py morning
python main.py evening
```

### 配置示例

```json
{
  "discord": {
    "channel_id": "${DISCORD_CHANNEL_ID}",
    "notify_user_id": "${DISCORD_NOTIFY_USER_ID}",
    "webhook_url": "${DISCORD_WEBHOOK_URL}",
    "send_mode": "auto"
  },
  "city": {
    "name": "杭州",
    "latitude": 30.2741,
    "longitude": 120.1551
  }
}
```

### 环境变量

| 变量 | 说明 |
|------|------|
| DISCORD_CHANNEL_ID | Discord 频道 ID |
| DISCORD_NOTIFY_USER_ID | 通知用户 ID |
| DISCORD_WEBHOOK_URL | Webhook URL（可选） |
| SEND_MODE | 发送模式 (auto/message/webhook) |
| LOG_LEVEL | 日志级别 |

### 文档

- [SKILL.md](skills/weather-notify/SKILL.md) - 完整使用指南
- [README.md](skills/weather-notify/README.md) - 快速上手
- [CONFIG.md](skills/weather-notify/CONFIG.md) - 详细配置

---

## 🏛️ Update-OpenClaw-Danghuangshang (AI 朝廷集成工具)

> "一键集成，版本管理，智能配置"

AI 朝廷（danghuangshang）项目集成/更新/版本管理工具。一键集成到已安装的 OpenClaw，支持首次安装、增量更新、版本快照、一键回滚和智能配置。

### 核心功能

| 功能 | 说明 |
|------|------|
| **首次集成** | 克隆 + 配置 + 工作区 + Skills |
| **增量更新** | 备份 + git pull + 同步 + 重启 |
| **版本快照** | 自动创建，保留历史 |
| **一键回滚** | 回退到任意历史版本 |
| **配置合并** | 保留现有配置，不覆盖 |
| **现有 Agent 处理** | 自动检测并跳过已存在 Agent，仅更新模型配置 |
| **Discord 机器人不足** | 提供 3 种方案：共用/混合/新创建 |
| **多模型推荐配置** | 智能排序 + 3 种配置方式（推荐/单一/自定义） |

### 主菜单

```
请选择操作:
  1) 更新到最新版本（默认）
  2) 查看版本快照列表
  3) 回滚到历史版本
  4) 创建当前版本快照
  5) 配置平台机器人（添加飞书/Discord）
  6) 配置 Agent 模型映射
  7) 退出
```

### 三大优化场景（v7.2）

#### 1. 现有 Agent 处理
- ✅ 自动检测已存在的 Agent，跳过添加
- ✅ 如果模型配置不同，自动更新模型映射
- ✅ 保留现有 Discord 账户和绑定关系

#### 2. Discord 机器人不足
- ✅ 机器人数量为 0：提供创建 1 个或 9 个的选项
- ✅ 机器人数量 1-8：提供共用/混合/新创建三种方案
- ✅ 首次只需配置司礼监，其他 Agent 可后续添加

#### 3. 多模型配置
- ✅ 自动检测模型并按上下文大小排序
- ✅ 推荐配置：强力/快速/通用三类模型
- ✅ 单一模型：所有 Agent 共用
- ✅ 自定义映射：每个 Agent 单独配置

### 快速开始

```bash
# 方式一：直接运行
/home/openclaw/.openclaw/workspace/skills/update-openclaw-danghuangshang/update.sh

# 方式二：通过 Agent 调用
# 在飞书/Discord @司礼监：请帮我集成/更新 AI 朝廷
```

### 辅助工具

| 工具 | 功能 |
|------|------|
| `update.sh` | 主脚本（集成/更新/版本管理） |
| `snapshot.sh` | 版本快照工具 |
| `rollback.sh` | 版本回滚工具 |
| `config-platform.sh` | 平台配置工具（添加飞书/Discord 机器人） |
| `config-agents.sh` | Agent 模型映射配置工具 |

### 支持的 Agent（9 个核心部门）

| Agent | 名称 | 职责 |
|-------|------|------|
| silijian | 司礼监 | 总管调度 |
| neige | 内阁 | Prompt 优化 |
| duchayuan | 都察院 | 代码审查 |
| bingbu | 兵部 | 编码开发 |
| hubu | 户部 | 财务分析 |
| libu | 礼部 | 品牌营销 |
| gongbu | 工部 | DevOps |
| libu2 | 吏部 | 项目管理 |
| xingbu | 刑部 | 法务合规 |

### 文档

- [SKILL.md](skills/update-openclaw-danghuangshang/SKILL.md) - 完整使用指南
- [README.md](skills/update-openclaw-danghuangshang/README.md) - 简化说明
- [CHANGES_v7.2.md](skills/update-openclaw-danghuangshang/CHANGES_v7.2.md) - 更新日志
