# weather-notify 技能

## 功能描述
定时推送天气到 Discord 频道，支持多城市、多 API 源、自定义模板。

**核心功能**：
- 🌤️ 定时推送：每天早上 8:30 和晚上 23:00 自动推送天气
- 🎨 精美 Embed：Discord Embed 格式，支持天气图标和动态颜色
- 👔 穿衣推荐：根据温度和天气动态生成穿衣建议
- 💡 温馨提示：个性化天气提示（雨天、雾天、温差、大风等）
- 🏙️ 多城市支持：可配置多个城市
- 🔌 多 API 源：支持 Open-Meteo 等免费 API
- 🔄 错误重试：API 失败自动重试 3 次
- 📝 推送记录：自动保存推送历史
- 🔄 **双模式发送**：支持 OpenClaw message 工具和 Discord Webhook

## GitHub 适配说明

本技能已适配 GitHub 项目，支持通用化配置和环境变量管理。

### 项目位置

```
/home/openclaw/wtf_workspace/github/openclaw-skills/skills/weather-notify/
```

### 快速上手

1. **复制配置文件**
   ```bash
   cp config.example.json config.json
   cp .env.example .env
   ```

2. **编辑配置**
   - 编辑 `config.json` 或 `.env`，填入你的 Discord 配置
   - 参考 [CONFIG.md](CONFIG.md) 了解详细配置

3. **安装依赖**
   ```bash
   pip install -r requirements.txt
   ```

4. **测试运行**
   ```bash
   python main.py morning
   python main.py evening
   ```

### 配置方式

**推荐：使用环境变量**

编辑 `.env` 文件：
```env
DISCORD_CHANNEL_ID=your_channel_id
DISCORD_NOTIFY_USER_ID=your_user_id
SEND_MODE=auto
```

**可选：使用配置文件**

编辑 `config.json` 文件：
```json
{
  "discord": {
    "channel_id": "your_channel_id",
    "notify_user_id": "your_user_id",
    "send_mode": "auto"
  }
}
```

### 环境变量优先级

环境变量 > 配置文件 > 默认值

## 使用场景

### 典型场景
- 每天早上 8:30 推送当天天气（帮助规划一天行程）
- 每天晚上 23:00 推送第二天天气（提前准备）
- 支持自定义频道和通知对象
- 支持自定义天气 API 源

### 适用人群
- 需要每日天气提醒的用户
- 关注穿衣建议的用户
- 需要多城市天气对比的用户

## 快速开始

### 1. 安装依赖

```bash
cd /path/to/weather-notify/
pip install -r requirements.txt
```

### 2. 配置发送方式

**支持两种发送方式**：

#### 方式一：OpenClaw message 工具（推荐，默认）

无需 Webhook！使用 OpenClaw 的 message 工具直接发送。

编辑 `config.json` 或 `.env`：

```json
{
  "discord": {
    "channel_id": "your_channel_id",
    "notify_user_id": "your_user_id",
    "webhook_url": "",
    "send_mode": "auto"
  }
}
```

#### 方式二：Discord Webhook（可选，备用）

需要创建 Webhook URL 并配置：

```json
{
  "discord": {
    "channel_id": "your_channel_id",
    "notify_user_id": "your_user_id",
    "webhook_url": "https://discord.com/api/webhooks/xxxxx/xxxxx",
    "send_mode": "auto"
  }
}
```

### 3. 发送模式说明

| send_mode | 行为 |
|-----------|------|
| `auto`（默认） | 有 webhook_url 则用 webhook，否则用 message 工具 |
| `message` | 强制使用 OpenClaw message 工具 |
| `webhook` | 强制使用 Discord Webhook |

**自动降级机制**：
- `auto` 模式下，Webhook 失败时自动降级到 message 工具
- 两种都失败时记录完整错误信息

### 4. 测试运行

```bash
# 测试早上推送
python main.py morning

# 测试晚上推送
python main.py evening
```

### 5. 配置定时任务

```bash
# 早上 8:30 推送
openclaw cron add --name "天气推送 - 早上" \
  --schedule "30 8 * * *" \
  --command "cd /path/to/weather-notify && python main.py morning"

# 晚上 23:00 推送
openclaw cron add --name "天气推送 - 晚上" \
  --schedule "0 23 * * *" \
  --command "cd /path/to/weather-notify && python main.py evening"
```

## 配置说明

### 环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `DISCORD_CHANNEL_ID` | Discord 频道 ID | `123456789012345678` |
| `DISCORD_NOTIFY_USER_ID` | 通知用户 ID | `987654321098765432` |
| `DISCORD_WEBHOOK_URL` | Discord Webhook URL | `https://discord.com/api/webhooks/...` |
| `SEND_MODE` | 发送模式 | `auto` / `message` / `webhook` |
| `LOG_LEVEL` | 日志级别 | `INFO` / `DEBUG` |

### config.json

```json
{
  "discord": {
    "channel_id": "your_channel_id",
    "notify_user_id": "your_user_id",
    "webhook_url": "${DISCORD_WEBHOOK_URL}",
    "send_mode": "auto"
  },
  "city": {
    "name": "杭州",
    "latitude": 30.2741,
    "longitude": 120.1551
  },
  "schedule": {
    "morning": "30 8 * * *",
    "evening": "0 23 * * *"
  },
  "api": {
    "provider": "open-meteo",
    "timeout": 10,
    "retry_times": 3
  }
}
```

### 配置项说明

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| discord.channel_id | Discord 频道 ID | 必需 |
| discord.notify_user_id | 通知用户 ID | 必需 |
| discord.webhook_url | Discord Webhook URL | 可选 |
| city.name | 城市名称 | 杭州 |
| city.latitude | 纬度 | 30.2741 |
| city.longitude | 经度 | 120.1551 |
| api.timeout | API 超时时间 (秒) | 10 |
| api.retry_times | 重试次数 | 3 |

## 消息示例

### 早上推送

```
🌅 杭州今日天气播报
2026 年 3 月 24 日 | 周二

🌤️ 天气状况 晴朗
🌡️ 温度范围 8°C ~ 15°C
💧 相对湿度 63%
💨 最大风速 12 km/h
🌧️ 降水概率 10%
☀️ 紫外线指数 5 (中等)

👔 穿衣指南
穿衣：长袖 + 薄外套
⚠️ 温差大：建议洋葱式穿衣

@username 💡 今日天气舒适，祝您心情愉快！
```

## 目录结构

```
weather-notify/
├── main.py              # 主程序
├── config.example.json  # 配置示例（⚠️不要提交 config.json）
├── .env.example         # 环境变量示例（⚠️不要提交 .env）
├── requirements.txt     # Python 依赖
├── README.md           # 快速上手指南
├── SKILL.md            # 技能文档（本文件）
├── CONFIG.md           # 详细配置说明
├── .gitignore          # Git 忽略规则
├── memory/             # 技能记忆
│   └── push_history.json  # 推送历史
├── logs/               # 日志目录
│   └── weather-notify.log
├── tests/              # 测试目录
├── templates/          # 消息模板
├── scripts/            # 辅助脚本
└── references/         # 参考文档
```

## 常见问题

### Q: 消息未发送？
A: 检查 `DISCORD_CHANNEL_ID` 或 `DISCORD_NOTIFY_USER_ID` 是否配置正确，检查 Discord 频道权限。

### Q: API 调用失败？
A: 检查网络连接，程序会自动重试 3 次。

### Q: 定时任务未执行？
A: 运行 `openclaw cron status` 检查定时任务状态。

### Q: 如何修改推送时间？
A: 修改 `config.json` 中的 `schedule.morning` 和 `schedule.evening`，然后更新定时任务。

### Q: 如何添加其他城市？
A: 修改 `config.json` 中的 `city.latitude` 和 `city.longitude`，参考：
- 北京：39.9042, 116.4074
- 上海：31.2304, 121.4737
- 广州：23.1291, 113.2644

## 日志查看

```bash
# 查看实时日志
tail -f logs/weather-notify.log

# 查看推送历史
cat memory/push_history.json
```

## 安全注意事项

⚠️ **重要**：请勿将以下文件提交到 Git：

- `config.json` - 包含个人配置
- `.env` - 包含敏感环境变量

这些文件已添加到 `.gitignore`，但仍请小心处理。

## 文档链接

- [README.md](README.md) - 快速上手指南
- [CONFIG.md](CONFIG.md) - 详细配置说明
- [config.example.json](config.example.json) - 配置示例
- [.env.example](.env.example) - 环境变量示例

## 许可证

MIT License
