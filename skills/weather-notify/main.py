#!/usr/bin/env python3
"""
weather-notify - 天气推送技能
定时推送天气到 Discord 频道，支持双模式发送：
1. OpenClaw message 工具（默认，内置方式）
2. Discord Webhook（可选，备用方式）

优化记录 (2026-03-23):
- 修复日志路径问题（使用绝对路径）
- 修复日期计算 bug（使用 timedelta）
- 实现 API 重试机制（retry 装饰器）
- 补全天气代码映射（80-82 阵雨，85-86 阵雪）
- 改进消息发送方式（移除 subprocess，使用 message 工具）

第二阶段增强 (2026-03-24):
- 添加推送历史记录（memory/push_history.json）
- 支持环境变量配置（DISCORD_CHANNEL_ID, DISCORD_NOTIFY_USER_ID, DISCORD_WEBHOOK_URL, SEND_MODE）
- 添加单元测试（tests/test_weather_notify.py）
"""

import json
import requests
import logging
import os
import time
import functools
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, Callable

# 获取脚本所在目录
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# 配置日志（任务 1：使用绝对路径）
log_dir = os.path.join(SCRIPT_DIR, 'logs')
os.makedirs(log_dir, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(log_dir, 'weather-notify.log'), encoding='utf-8'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# 推送历史记录文件路径
MEMORY_DIR = os.path.join(SCRIPT_DIR, 'memory')
os.makedirs(MEMORY_DIR, exist_ok=True)
PUSH_HISTORY_FILE = os.path.join(MEMORY_DIR, 'push_history.json')
MAX_HISTORY_RECORDS = 100

# 任务 4：补全天气代码映射
WEATHER_CODES = {
    0: ("晴天", "☀️"),
    1: ("多云", "⛅"),
    2: ("多云", "⛅"),
    3: ("多云", "⛅"),
    45: ("雾", "🌫️"),
    48: ("雾", "🌫️"),
    51: ("小雨", "🌧️"),
    53: ("小雨", "🌧️"),
    55: ("小雨", "🌧️"),
    61: ("小雨", "🌧️"),
    63: ("中雨", "🌧️"),
    65: ("大雨", "🌧️"),
    71: ("小雪", "❄️"),
    73: ("中雪", "❄️"),
    75: ("大雪", "❄️"),
    80: ("阵雨", "🌧️"),  # 新增
    81: ("阵雨", "🌧️"),  # 新增
    82: ("阵雨", "🌧️"),  # 新增
    85: ("阵雪", "❄️"),  # 新增
    86: ("阵雪", "❄️"),  # 新增
    95: ("雷雨", "⛈️"),
}


# ============== 推送历史记录管理（任务 1）=============
def load_push_history():
    """加载推送历史记录"""
    try:
        if os.path.exists(PUSH_HISTORY_FILE):
            with open(PUSH_HISTORY_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        return []
    except Exception as e:
        logger.error(f"加载推送历史失败：{e}")
        return []


def save_push_history(history):
    """保存推送历史记录，只保留最近 100 条"""
    try:
        # 只保留最近 100 条
        if len(history) > MAX_HISTORY_RECORDS:
            history = history[-MAX_HISTORY_RECORDS:]
        
        with open(PUSH_HISTORY_FILE, 'w', encoding='utf-8') as f:
            json.dump(history, f, ensure_ascii=False, indent=2)
        logger.debug(f"推送历史已保存，共 {len(history)} 条记录")
    except Exception as e:
        logger.error(f"保存推送历史失败：{e}")


def record_push(city_name: str, mode: str, weather_data: dict, success: bool):
    """记录推送历史"""
    history = load_push_history()
    
    daily = weather_data.get("daily", {})
    date_idx = 0
    weather_code = daily.get("weathercode", [0])[date_idx] if date_idx < len(daily.get("weathercode", [])) else 0
    temp_max = daily.get("temperature_2m_max", [0])[date_idx] if date_idx < len(daily.get("temperature_2m_max", [])) else 0
    temp_min = daily.get("temperature_2m_min", [0])[date_idx] if date_idx < len(daily.get("temperature_2m_min", [])) else 0
    
    record = {
        "timestamp": datetime.now().isoformat(),
        "city": city_name,
        "mode": mode,
        "weather_code": weather_code,
        "temperature": {"min": temp_min, "max": temp_max},
        "status": "success" if success else "failure"
    }
    
    history.append(record)
    save_push_history(history)
    logger.info(f"推送记录已保存：{city_name} {mode} {'成功' if success else '失败'}")

# 任务 3：实现 API 重试机制
def retry(max_attempts: int = 3, backoff_factor: float = 2.0):
    """
    重试装饰器，支持指数退避
    
    Args:
        max_attempts: 最大重试次数
        backoff_factor: 退避因子（秒）
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_attempts:
                        wait_time = backoff_factor ** (attempt - 1)
                        logger.warning(f"第 {attempt} 次失败，{wait_time}秒后重试... ({e})")
                        time.sleep(wait_time)
                    else:
                        logger.error(f"第 {attempt} 次失败，不再重试：{e}")
            raise last_exception
        return wrapper
    return decorator

def load_config():
    """加载配置文件（任务 1：使用绝对路径）"""
    config_path = os.path.join(SCRIPT_DIR, 'config.json')
    with open(config_path, "r", encoding="utf-8") as f:
        config = json.load(f)
    
    # 任务 2：环境变量支持（优先级高于配置文件）
    # DISCORD_CHANNEL_ID - Discord 频道 ID
    if os.environ.get('DISCORD_CHANNEL_ID'):
        config['discord']['channel_id'] = os.environ.get('DISCORD_CHANNEL_ID')
    
    # DISCORD_NOTIFY_USER_ID - 通知用户 ID
    if os.environ.get('DISCORD_NOTIFY_USER_ID'):
        config['discord']['notify_user_id'] = os.environ.get('DISCORD_NOTIFY_USER_ID')
    
    # DISCORD_WEBHOOK_URL - Webhook URL
    if os.environ.get('DISCORD_WEBHOOK_URL'):
        config['discord']['webhook_url'] = os.environ.get('DISCORD_WEBHOOK_URL')
    
    # SEND_MODE - 发送模式
    if os.environ.get('SEND_MODE'):
        config['discord']['send_mode'] = os.environ.get('SEND_MODE')
    
    # LOG_LEVEL - 日志级别
    if os.environ.get('LOG_LEVEL'):
        log_level = getattr(logging, os.environ.get('LOG_LEVEL').upper(), logging.INFO)
        logging.getLogger().setLevel(log_level)
    
    return config

@retry(max_attempts=3, backoff_factor=2.0)  # 任务 3：添加重试装饰器
def fetch_weather_data(latitude, longitude, timeout=10):
    """获取天气数据（Open-Meteo API）"""
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "daily": "weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max,windspeed_10m_max",
        "timezone": "Asia/Shanghai"
    }
    
    response = requests.get(url, params=params, timeout=timeout)
    response.raise_for_status()
    return response.json()

def get_weather_info(weather_code):
    """根据天气代码获取天气信息"""
    for code, (weather, icon) in WEATHER_CODES.items():
        if weather_code == code or (isinstance(code, range) and weather_code in code):
            return weather, icon
    return "未知", "❓"

def get_clothing_recommendation(temp_min, temp_max, weather_code):
    """根据温度和天气生成穿衣推荐"""
    avg_temp = (temp_min + temp_max) / 2
    
    if avg_temp < 5:
        base = "厚羽绒服 + 保暖内衣 + 围巾 + 手套"
    elif avg_temp < 10:
        base = "厚外套 + 毛衣 + 保暖内衣"
    elif avg_temp < 15:
        base = "长袖 + 薄外套 + 毛衣"
    elif avg_temp < 20:
        base = "长袖 + 薄外套"
    elif avg_temp < 25:
        base = "短袖 + 薄外套 (早晚)"
    elif avg_temp < 30:
        base = "短袖 + 防晒"
    else:
        base = "短袖 + 防晒衣 + 多喝水"
    
    # 特殊天气
    special = ""
    if weather_code in [51, 53, 55, 61, 63, 65, 80, 81, 82]:  # 雨天
        special = "⚠️ 雨天：防水外套 + 携带雨具 + 防水鞋"
    elif weather_code in [45, 48]:  # 雾天
        special = "⚠️ 雾天：佩戴口罩 + 注意交通安全"
    elif weather_code in [71, 73, 75, 85, 86]:  # 雪天
        special = "⚠️ 雪天：防滑鞋 + 保暖 + 注意路滑"
    elif temp_max - temp_min > 10:
        special = "⚠️ 温差大：建议洋葱式穿衣"
    
    return f"👔 穿衣：{base}\n{special}" if special else f"👔 穿衣：{base}"

def get_weather_tip(weather_code, temp_min, temp_max, precip_prob, humidity=None, wind_speed=None):
    """生成温馨提示"""
    tips = []
    
    if precip_prob > 70:
        tips.append("大雨，务必带伞！")
    elif precip_prob > 40:
        tips.append("可能有雨，建议带伞！")
    if weather_code in [45, 48]:
        tips.append("雾霾较重，敏感人群减少户外活动！")
    if temp_max - temp_min > 10:
        tips.append(f"温差达 {temp_max - temp_min}°C，注意增减衣物！")
    if temp_min < 5:
        tips.append(f"早晨低温 {temp_min}°C，注意保暖！")
    if temp_max > 30:
        tips.append(f"高温 {temp_max}°C，注意防暑降温！")
    if wind_speed and wind_speed > 30:
        tips.append(f"风力较大 ({wind_speed}km/h)，注意防风！")
    
    if tips:
        return "💡 温馨提示：" + " ".join(tips)
    return "💡 今日天气宜人！"

def create_weather_embed(city_name, date_str, day_of_week, weather_data, is_morning=True):
    """创建 Discord Embed 消息"""
    daily = weather_data["daily"]
    
    # 获取日期索引
    date_idx = 0 if is_morning else 1
    if date_idx >= len(daily["time"]):
        date_idx = 0
    
    # 提取数据
    date = daily["time"][date_idx]
    weather_code = daily["weathercode"][date_idx]
    temp_max = daily["temperature_2m_max"][date_idx]
    temp_min = daily["temperature_2m_min"][date_idx]
    precip_prob = daily["precipitation_probability_max"][date_idx]
    wind_speed = daily["windspeed_10m_max"][date_idx]
    
    # 天气信息
    weather, icon = get_weather_info(weather_code)
    
    # 穿衣推荐
    clothing = get_clothing_recommendation(temp_min, temp_max, weather_code)
    
    # 温馨提示
    tip = get_weather_tip(weather_code, temp_min, temp_max, precip_prob, wind_speed=wind_speed)
    
    # 标题
    title = f"🌅 杭州今日天气播报" if is_morning else f"🌙 杭州明日天气预报"
    
    # Embed 结构
    embed = {
        "title": title,
        "description": f"{date} | {day_of_week}",
        "color": 3447003,  # 蓝色
        "fields": [
            {"name": f"{icon} 天气", "value": weather, "inline": True},
            {"name": "🌡️ 温度", "value": f"{temp_min}°C ~ {temp_max}°C", "inline": True},
            {"name": "💨 风速", "value": f"{wind_speed} km/h", "inline": True},
            {"name": "🌧️ 降水概率", "value": f"{precip_prob}%", "inline": True},
        ],
        "footer": {"text": clothing + "\n" + tip}
    }
    
    return embed

def send_via_webhook(webhook_url: str, embed: Dict[str, Any], user_id: str) -> bool:
    """
    通过 Discord Webhook 发送消息
    
    Args:
        webhook_url: Webhook URL
        embed: Embed 消息内容
        user_id: 通知用户 ID
    
    Returns:
        bool: 发送是否成功
    """
    try:
        # 构建 Webhook  payload
        # Webhook 不支持直接 @用户，需要在 content 中提及
        content = f"<@{user_id}>"
        
        payload = {
            "content": content,
            "embeds": [embed]
        }
        
        response = requests.post(
            webhook_url,
            json=payload,
            timeout=10
        )
        
        if response.status_code in [200, 204]:
            logger.info("Webhook 消息发送成功")
            return True
        else:
            logger.error(f"Webhook 发送失败：HTTP {response.status_code}, {response.text}")
            return False
            
    except requests.exceptions.RequestException as e:
        logger.error(f"Webhook 请求异常：{e}")
        return False
    except Exception as e:
        logger.error(f"Webhook 发送异常：{e}")
        return False

def send_via_message(channel_id: str, embed: Dict[str, Any], user_id: str) -> bool:
    """
    通过 OpenClaw message 工具发送消息（任务 5：改进发送方式，使用 subprocess 调用 message 命令）
    
    Args:
        channel_id: Discord 频道 ID
        embed: Embed 消息内容
        user_id: 通知用户 ID
    
    Returns:
        bool: 发送是否成功
    """
    
    try:
        # 构建消息内容
        # 将 embed 转换为可读文本格式
        title = embed.get("title", "")
        description = embed.get("description", "")
        fields = embed.get("fields", [])
        footer_text = embed.get("footer", {}).get("text", "")
        
        # 构建消息正文
        message_parts = [
            f"**{title}**",
            description,
            ""
        ]
        
        for field in fields:
            message_parts.append(f"**{field['name']}**: {field['value']}")
        
        message_parts.append("")
        message_parts.append(f"<@{user_id}> {footer_text}")
        
        message = "\n".join(message_parts)
        
        # 使用 message 命令发送（任务 5：使用标准的 message 命令调用方式）
        import subprocess
        cmd = [
            'message', 'send',
            '--channel', 'discord',
            '--target', channel_id,
            '--message', message
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=15)
        
        if result.returncode == 0 or 'sent' in result.stdout.lower() or 'success' in result.stdout.lower():
            logger.info("Message 工具发送成功")
            return True
        else:
            logger.error(f"Message 工具发送失败：{result.stderr}")
            return False
            
    except FileNotFoundError:
        logger.error("message 命令不存在，无法发送消息")
        return False
    except subprocess.TimeoutExpired:
        logger.error("Message 工具调用超时")
        return False
    except Exception as e:
        logger.error(f"Message 工具调用异常：{e}")
        return False

def send_message(channel_id: str, user_id: str, embed: Dict[str, Any], 
                 send_mode: str = "auto", webhook_url: Optional[str] = None) -> bool:
    """
    发送消息，自动选择发送方式
    
    Args:
        channel_id: Discord 频道 ID
        user_id: 通知用户 ID
        embed: Embed 消息内容
        send_mode: 发送模式 (auto/message/webhook)
        webhook_url: Webhook URL（可选）
    
    Returns:
        bool: 发送是否成功
    """
    logger.info(f"发送消息，模式：{send_mode}, webhook_url 配置：{'有' if webhook_url else '无'}")
    
    # 1. 判断发送方式
    if send_mode == "webhook" or (send_mode == "auto" and webhook_url):
        # 优先使用 Webhook
        logger.info("使用 Webhook 模式发送")
        success = send_via_webhook(webhook_url, embed, user_id)
        
        if not success and send_mode == "auto":
            # Webhook 失败，自动降级到 message 工具
            logger.warning("Webhook 失败，降级到 Message 工具")
            success = send_via_message(channel_id, embed, user_id)
        
        return success
        
    elif send_mode == "message":
        # 强制使用 Message 工具
        logger.info("使用 Message 工具模式发送")
        return send_via_message(channel_id, embed, user_id)
        
    else:
        # 默认使用 Message 工具
        logger.info("使用默认 Message 工具模式发送")
        return send_via_message(channel_id, embed, user_id)

def main(mode="evening"):
    """主函数"""
    config = load_config()
    
    # 获取配置
    discord_config = config["discord"]
    channel_id = discord_config["channel_id"]
    user_id = discord_config["notify_user_id"]
    webhook_url = discord_config.get("webhook_url", "")
    send_mode = discord_config.get("send_mode", "auto")
    
    city = config["city"]
    api_config = config["api"]
    
    logger.info(f"开始运行天气推送，模式：{mode}")
    logger.info(f"发送配置：channel={channel_id}, user={user_id}, mode={send_mode}, webhook={'有' if webhook_url else '无'}")
    
    # 获取天气数据
    try:
        weather_data = fetch_weather_data(
            city["latitude"],
            city["longitude"],
            timeout=api_config["timeout"]
        )
    except Exception as e:
        logger.error(f"获取天气数据失败：{e}")
        # 记录失败历史
        record_push(city["name"], mode, {}, False)
        return
    
    # 获取日期信息（任务 2：修复日期计算 bug，使用 timedelta）
    now = datetime.now()
    if mode == "morning":
        date = now.strftime("%Y 年%m 月%d 日")
        day_of_week = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"][now.weekday()]
    else:
        # 使用 timedelta 替代 replace(day=...)，正确处理月末边界
        tomorrow = now + timedelta(days=1)
        date = tomorrow.strftime("%Y 年%m 月%d 日")
        day_of_week = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"][tomorrow.weekday()]
    
    # 创建 Embed
    embed = create_weather_embed(
        city["name"],
        date,
        day_of_week,
        weather_data,
        is_morning=(mode == "morning")
    )
    
    # 添加用户通知
    embed["footer"]["text"] = f"<@{user_id}> " + embed["footer"]["text"]
    
    # 发送消息
    success = send_message(
        channel_id=channel_id,
        user_id=user_id,
        embed=embed,
        send_mode=send_mode,
        webhook_url=webhook_url if webhook_url else None
    )
    
    # 记录推送历史（任务 1）
    record_push(city["name"], mode, weather_data, success)
    
    if success:
        logger.info("天气推送完成！")
    else:
        logger.error("天气推送失败！")

if __name__ == "__main__":
    import sys
    mode = sys.argv[1] if len(sys.argv) > 1 else "evening"
    main(mode)
