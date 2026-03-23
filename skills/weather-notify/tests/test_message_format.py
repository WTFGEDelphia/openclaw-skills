#!/usr/bin/env python3
"""消息格式单元测试"""

import unittest
import json
from datetime import datetime, timezone
from main import create_weather_embed, send_discord_message


class TestMessageFormat(unittest.TestCase):
    """测试 Discord Embed 消息格式"""
    
    def setUp(self):
        """测试前准备"""
        self.weather_data = {
            "daily": {
                "time": ["2026-03-24", "2026-03-25"],
                "weathercode": [61, 0],
                "temperature_2m_max": [15, 18],
                "temperature_2m_min": [8, 10],
                "precipitation_probability_max": [60, 10],
                "windspeed_10m_max": [12, 8],
                "relativehumidity_2m_max": [75, 60]
            }
        }
        self.city_name = "杭州"
        self.notify_user = "987654321098765432"
    
    def test_embed_structure(self):
        """测试 Embed 基本结构"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        
        # 验证基本结构
        self.assertIn("embeds", payload)
        self.assertIsInstance(payload["embeds"], list)
        self.assertEqual(len(payload["embeds"]), 1)
        
        embed = payload["embeds"][0]
        
        # 验证必填字段
        self.assertIn("title", embed)
        self.assertIn("description", embed)
        self.assertIn("color", embed)
        self.assertIn("fields", embed)
        self.assertIn("footer", embed)
        self.assertIn("timestamp", embed)
    
    def test_morning_embed_title(self):
        """测试早上推送标题"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        self.assertIn("今日", embed["title"])
        self.assertIn("🌅", embed["title"])
    
    def test_evening_embed_title(self):
        """测试晚上推送标题"""
        payload = create_weather_embed(
            self.weather_data, 1, self.city_name, self.notify_user, is_morning=False
        )
        embed = payload["embeds"][0]
        self.assertIn("明日", embed["title"])
        self.assertIn("🌙", embed["title"])
    
    def test_embed_fields(self):
        """测试 Embed 字段内容"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        
        # 验证字段数量
        self.assertGreaterEqual(len(embed["fields"]), 6)
        
        # 验证字段名称
        field_names = [f["name"] for f in embed["fields"]]
        self.assertIn("天气状况", field_names[0])
        self.assertIn("温度范围", field_names[1])
        self.assertIn("相对湿度", field_names[2])
        self.assertIn("穿衣指南", field_names[-1])  # 最后一个字段是穿衣指南
    
    def test_embed_color_by_weather(self):
        """测试根据天气设置颜色"""
        # 晴天 - 橙色
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        self.assertEqual(embed["color"], 5814783)  # 橙色
    
    def test_embed_footer_format(self):
        """测试 Footer 格式"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        
        # 验证 footer 包含用户 ID
        self.assertIn(f"<@{self.notify_user}>", embed["footer"]["text"])
    
    def test_embed_clothing_recommendation(self):
        """测试穿衣推荐内容"""
        # 雨天
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        
        # 找到穿衣指南字段
        clothing_field = next(f for f in embed["fields"] if f["name"] == "穿衣指南")
        self.assertIn("穿衣", clothing_field["value"])
        
        # 雨天应该有特殊提示
        self.assertIn("雨具", clothing_field["value"])
    
    def test_embed_timestamp(self):
        """测试时间戳格式"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        
        # 验证时间戳是有效的 ISO 格式
        timestamp = embed["timestamp"]
        try:
            datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
        except ValueError:
            self.fail("时间戳格式无效")
    
    def test_embed_json_serializable(self):
        """测试 Embed 可以被序列化为 JSON"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        
        # 验证可以序列化为 JSON
        try:
            json_str = json.dumps(payload, ensure_ascii=False)
            # 验证可以反序列化
            json.loads(json_str)
        except (TypeError, ValueError) as e:
            self.fail(f"JSON 序列化失败：{e}")
    
    def test_embed_inline_fields(self):
        """测试内联字段"""
        payload = create_weather_embed(
            self.weather_data, 0, self.city_name, self.notify_user, is_morning=True
        )
        embed = payload["embeds"][0]
        
        # 前 5 个字段应该是内联的
        for i in range(5):
            self.assertTrue(embed["fields"][i].get("inline", False), 
                          f"字段 {i} 应该是内联的")
        
        # 最后一个字段（穿衣指南）不应该内联
        self.assertFalse(embed["fields"][-1].get("inline", False),
                        "穿衣指南字段不应该内联")


class TestDiscordWebhook(unittest.TestCase):
    """测试 Discord Webhook 相关功能"""
    
    def test_webhook_payload_format(self):
        """测试 Webhook payload 格式"""
        weather_data = {
            "daily": {
                "time": ["2026-03-24"],
                "weathercode": [0],
                "temperature_2m_max": [20],
                "temperature_2m_min": [12],
                "precipitation_probability_max": [20],
                "windspeed_10m_max": [10],
                "relativehumidity_2m_max": [60]
            }
        }
        
        payload = create_weather_embed(weather_data, 0, "杭州", "123456", True)
        
        # 验证 payload 符合 Discord Webhook 格式
        self.assertIn("embeds", payload)
        self.assertIsInstance(payload["embeds"], list)
        
        # 验证 embed 符合 Discord Embed 规范
        embed = payload["embeds"][0]
        self.assertLessEqual(len(embed.get("title", "")), 256)
        self.assertLessEqual(len(embed.get("description", "")), 4096)
        self.assertLessEqual(len(embed.get("footer", {}).get("text", "")), 2048)


if __name__ == '__main__':
    unittest.main(verbosity=2)
