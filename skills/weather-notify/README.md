# weather-notify - 天气通知技能

> 定时推送天气通知，支持多城市、多 API 源、自定义模板

**功能特性**：
- 🌤️ 定时推送：支持早上和晚上两次推送
- 🎨 精美 Embed：Discord Embed 格式，支持天气图标和动态颜色
- 👔 穿衣推荐：根据温度和天气动态生成穿衣建议
- 💡 温馨提示：个性化天气提示（雨天、雾天、温差等）
- 🏙️ 多城市支持：可配置多个城市
- 🔌 多 API 源：支持 Open-Meteo 等免费 API
- 🔄 错误重试：API 失败自动重试
- 📝 推送记录：自动保存推送历史
- 🔄 **双模式发送**：支持 OpenClaw message 工具和 Discord Webhook

## 快速开始

### 1. 安装依赖

```bash
cd skills/weather-notify/
pip install -r requirements.txt
```

### 2. 配置环境

**方式一：使用环境变量（推荐）**

复制环境变量示例文件并配置：

```bash
cp .env.example .env
# 编辑 .env 文件，填入你的配置
```

**方式二：使用配置文件**

复制配置示例文件并配置：

```bash
cp config.example.json config.json
# 编辑 config.json 文件，填入你的配置
```

### 3. 测试运行

```bash
# 测试早上推送
python main.py morning

# 测试晚上推送
python main.py evening
```

### 4. 配置定时任务（可选）

```bash
# 早上 8:30 推送
openclaw cron add --name "天气推送 - 早上" \
  --schedule "30 8 * * *" \
  --command "cd $(pwd) && python main.py morning"

# 晚上 23:00 推送
openclaw cron add --name "天气推送 - 晚上" \
  --schedule "0 23 * * *" \
  --command "cd $(pwd) && python main.py evening"
```

## 配置说明

### 环境变量优先级

环境变量优先级 **高于** 配置文件。配置顺序：

1. 环境变量（最高优先级）
2. config.json 配置文件
3. 默认值（最低优先级）

### 可用环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `DISCORD_CHANNEL_ID` | Discord 频道 ID | `123456789012345678` |
| `DISCORD_NOTIFY_USER_ID` | 通知用户 ID | `987654321098765432` |
| `DISCORD_WEBHOOK_URL` | Discord Webhook URL（可选） | `https://discord.com/api/webhooks/...` |
| `SEND_MODE` | 发送模式 | `auto` / `message` / `webhook` |
| `LOG_LEVEL` | 日志级别 | `INFO` / `DEBUG` / `WARNING` |
| `CITY_NAME` | 城市名称 | `杭州` |
| `CITY_LATITUDE` | 纬度 | `30.2741` |
| `CITY_LONGITUDE` | 经度 | `120.1551` |

### 发送模式说明

| send_mode | 行为 |
|-----------|------|
| `auto`（默认） | 有 webhook_url 则用 webhook，否则用 message 工具 |
| `message` | 强制使用 OpenClaw message 工具 |
| `webhook` | 强制使用 Discord Webhook |

**自动降级机制**：
- `auto` 模式下，Webhook 失败时自动降级到 message 工具
- 两种都失败时记录完整错误信息

### config.json 配置项

```json
{
  "discord": {
    "channel_id": "your_channel_id",
    "notify_user_id": "your_user_id",
    "webhook_url": "",
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

## 城市坐标参考

| 城市 | 纬度 | 经度 |
|------|------|------|
| 北京 | 39.9042 | 116.4074 |
| 上海 | 31.2304 | 121.4737 |
| 广州 | 23.1291 | 113.2644 |
| 深圳 | 22.5431 | 114.0579 |
| 杭州 | 30.2741 | 120.1551 |
| 成都 | 30.5728 | 104.0668 |

## 目录结构

```
weather-notify/
├── main.py                 # 主程序
├── config.example.json     # 配置示例（⚠️不要提交 config.json）
├── .env.example           # 环境变量示例（⚠️不要提交 .env）
├── requirements.txt       # Python 依赖
├── README.md             # 本文件
├── SKILL.md              # 技能文档
├── CONFIG.md             # 详细配置说明
├── templates/            # 消息模板
├── tests/               # 测试文件
├── scripts/             # 辅助脚本
├── references/          # 参考文档
├── logs/               # 日志目录（自动生成）
└── memory/             # 技能记忆（自动生成）
```

## 安全注意事项

⚠️ **重要**：请勿将以下文件提交到 Git：

- `config.json` - 包含个人配置
- `.env` - 包含敏感环境变量

这些文件已添加到 `.gitignore`，但仍请小心处理。

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
A: 修改 `config.json` 中的 `city.latitude` 和 `city.longitude`，参考上方城市坐标表。

## 日志查看

```bash
# 查看实时日志
tail -f logs/weather-notify.log

# 查看推送历史
cat memory/push_history.json
```

## 许可证

MIT License
