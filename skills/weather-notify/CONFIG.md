# weather-notify 详细配置说明

## 配置方式

本技能支持两种配置方式，优先级如下：

1. **环境变量**（最高优先级）
2. **config.json 配置文件**
3. **默认值**（最低优先级）

## 环境变量配置

### 必需变量

| 变量名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `DISCORD_CHANNEL_ID` | string | Discord 频道 ID | `123456789012345678` |
| `DISCORD_NOTIFY_USER_ID` | string | 通知用户 ID | `987654321098765432` |

### 可选变量

| 变量名 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `DISCORD_WEBHOOK_URL` | string | Discord Webhook URL | 空 |
| `SEND_MODE` | string | 发送模式 | `auto` |
| `LOG_LEVEL` | string | 日志级别 | `INFO` |
| `CITY_NAME` | string | 城市名称 | `杭州` |
| `CITY_LATITUDE` | float | 纬度 | `30.2741` |
| `CITY_LONGITUDE` | float | 经度 | `120.1551` |
| `API_TIMEOUT` | int | API 超时时间（秒） | `10` |
| `API_RETRY_TIMES` | int | 重试次数 | `3` |

### 环境变量优先级说明

当同时存在环境变量和配置文件时：

```python
# 优先级顺序
最终值 = 环境变量 or 配置文件 or 默认值
```

例如：
- 如果设置了 `DISCORD_CHANNEL_ID=123456`，则使用 `123456`
- 如果未设置环境变量，但 `config.json` 中有 `channel_id: "789012"`，则使用 `789012`
- 如果都没有，则使用默认值

## 配置文件说明

### config.json 完整结构

```json
{
  "name": "weather-notify",
  "displayName": "天气通知",
  "version": "1.0.0",
  "description": "定时推送天气通知",
  
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

### 配置项详解

#### discord 配置

| 配置项 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `channel_id` | string | Discord 频道 ID | 必需 |
| `notify_user_id` | string | 通知用户 ID | 必需 |
| `webhook_url` | string | Discord Webhook URL | 空 |
| `send_mode` | string | 发送模式 | `auto` |

#### city 配置

| 配置项 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `name` | string | 城市名称 | `杭州` |
| `latitude` | float | 纬度 | `30.2741` |
| `longitude` | float | 经度 | `120.1551` |

#### schedule 配置（Cron 格式）

| 配置项 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `morning` | string | 早上推送时间 | `30 8 * * *` |
| `evening` | string | 晚上推送时间 | `0 23 * * *` |

Cron 格式：`分钟 小时 日 月 星期`

示例：
- `30 8 * * *` - 每天早上 8:30
- `0 23 * * *` - 每天晚上 23:00
- `0 12 * * 1-5` - 工作日中午 12:00

#### api 配置

| 配置项 | 类型 | 说明 | 默认值 |
|--------|------|------|--------|
| `provider` | string | API 提供商 | `open-meteo` |
| `timeout` | int | 超时时间（秒） | `10` |
| `retry_times` | int | 重试次数 | `3` |

## 发送模式详解

### auto（默认）

自动选择发送方式：
1. 如果配置了 `webhook_url`，优先使用 Webhook
2. 如果 Webhook 失败或未配置，降级使用 message 工具

### message

强制使用 OpenClaw message 工具发送。优点：
- 无需创建 Webhook
- 更安全（无需暴露 Webhook URL）
- 支持更多 Discord 功能

### webhook

强制使用 Discord Webhook 发送。优点：
- 不依赖 OpenClaw 环境
- 可直接从外部调用

## 安全建议

1. **不要提交敏感文件**
   - `config.json` - 包含个人配置
   - `.env` - 包含环境变量

2. **使用环境变量存储敏感信息**
   ```bash
   export DISCORD_CHANNEL_ID=your_channel_id
   export DISCORD_NOTIFY_USER_ID=your_user_id
   ```

3. **限制 Webhook 权限**
   - 创建专用 Webhook，仅允许发送消息
   - 定期更换 Webhook URL

4. **日志脱敏**
   - 日志中不会记录敏感信息
   - 但请定期检查日志内容

## 故障排查

### 检查配置是否生效

```bash
# 查看环境变量
env | grep DISCORD
env | grep SEND_MODE

# 查看配置文件
cat config.json | jq
```

### 测试配置

```bash
# 测试早上推送
python main.py morning

# 测试晚上推送
python main.py evening

# 查看详细日志
python main.py morning --verbose
```

### 常见错误

| 错误 | 原因 | 解决方法 |
|------|------|----------|
| `Channel not found` | channel_id 错误 | 检查频道 ID 是否正确 |
| `User not found` | notify_user_id 错误 | 检查用户 ID 是否正确 |
| `API timeout` | 网络问题 | 检查网络连接，增加 timeout |
| `Invalid webhook` | webhook_url 错误 | 检查 Webhook URL 是否有效 |
