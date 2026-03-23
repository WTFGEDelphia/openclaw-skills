#!/usr/bin/env python3
"""
测试天气推送技能的双模式发送功能
"""

import json
import sys
import os
from unittest.mock import patch, MagicMock

# 添加项目路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from main import (
    send_message,
    send_via_webhook,
    send_via_message,
    create_weather_embed,
    get_weather_info,
    get_clothing_recommendation,
    get_weather_tip
)


def test_send_mode_auto_with_webhook():
    """测试 auto 模式（有 webhook_url）"""
    print("\n=== 测试 auto 模式（有 webhook_url）===")
    
    embed = {"title": "Test", "fields": []}
    
    with patch('main.send_via_webhook') as mock_webhook, \
         patch('main.send_via_message') as mock_message:
        
        mock_webhook.return_value = True
        
        result = send_message(
            channel_id="test_channel",
            user_id="test_user",
            embed=embed,
            send_mode="auto",
            webhook_url="https://webhook.test"
        )
        
        # 应该调用 webhook
        mock_webhook.assert_called_once()
        mock_message.assert_not_called()
        assert result == True
        print("✅ auto 模式（有 webhook）- 正确调用 Webhook")


def test_send_mode_auto_without_webhook():
    """测试 auto 模式（无 webhook_url）"""
    print("\n=== 测试 auto 模式（无 webhook_url）===")
    
    embed = {"title": "Test", "fields": []}
    
    with patch('main.send_via_webhook') as mock_webhook, \
         patch('main.send_via_message') as mock_message:
        
        mock_message.return_value = True
        
        result = send_message(
            channel_id="test_channel",
            user_id="test_user",
            embed=embed,
            send_mode="auto",
            webhook_url=None
        )
        
        # 应该调用 message
        mock_webhook.assert_not_called()
        mock_message.assert_called_once()
        assert result == True
        print("✅ auto 模式（无 webhook）- 正确调用 Message 工具")


def test_send_mode_auto_webhook_fallback():
    """测试 auto 模式（Webhook 失败降级）"""
    print("\n=== 测试 auto 模式（Webhook 失败降级）===")
    
    embed = {"title": "Test", "fields": []}
    
    with patch('main.send_via_webhook') as mock_webhook, \
         patch('main.send_via_message') as mock_message:
        
        mock_webhook.return_value = False  # Webhook 失败
        mock_message.return_value = True   # Message 成功
        
        result = send_message(
            channel_id="test_channel",
            user_id="test_user",
            embed=embed,
            send_mode="auto",
            webhook_url="https://webhook.test"
        )
        
        # 应该先调用 webhook，失败后调用 message
        assert mock_webhook.call_count == 1
        assert mock_message.call_count == 1
        assert result == True
        print("✅ auto 模式（降级）- Webhook 失败后正确降级到 Message")


def test_send_mode_message():
    """测试 message 模式"""
    print("\n=== 测试 message 模式===")
    
    embed = {"title": "Test", "fields": []}
    
    with patch('main.send_via_webhook') as mock_webhook, \
         patch('main.send_via_message') as mock_message:
        
        mock_message.return_value = True
        
        result = send_message(
            channel_id="test_channel",
            user_id="test_user",
            embed=embed,
            send_mode="message",
            webhook_url="https://webhook.test"
        )
        
        # 应该只调用 message，即使有 webhook_url
        mock_webhook.assert_not_called()
        mock_message.assert_called_once()
        assert result == True
        print("✅ message 模式 - 强制使用 Message 工具")


def test_send_mode_webhook():
    """测试 webhook 模式"""
    print("\n=== 测试 webhook 模式===")
    
    embed = {"title": "Test", "fields": []}
    
    with patch('main.send_via_webhook') as mock_webhook, \
         patch('main.send_via_message') as mock_message:
        
        mock_webhook.return_value = True
        
        result = send_message(
            channel_id="test_channel",
            user_id="test_user",
            embed=embed,
            send_mode="webhook",
            webhook_url="https://webhook.test"
        )
        
        # 应该只调用 webhook，即使 message 可用
        mock_webhook.assert_called_once()
        mock_message.assert_not_called()
        assert result == True
        print("✅ webhook 模式 - 强制使用 Webhook")


def test_weather_code_mapping():
    """测试天气代码映射"""
    print("\n=== 测试天气代码映射===")
    
    test_cases = [
        (0, ("晴天", "☀️")),
        (1, ("多云", "⛅")),
        (51, ("小雨", "🌧️")),
        (71, ("小雪", "❄️")),
        (95, ("雷雨", "⛈️")),
    ]
    
    for code, expected in test_cases:
        result = get_weather_info(code)
        assert result == expected, f"天气代码 {code} 映射错误"
    
    print("✅ 天气代码映射测试通过")


def test_clothing_recommendation():
    """测试穿衣推荐"""
    print("\n=== 测试穿衣推荐===")
    
    test_cases = [
        (0, 10, 0, "厚羽绒服"),      # 平均 5°C 以下
        (5, 15, 0, "厚外套"),        # 平均 10°C 以下
        (10, 20, 0, "长袖 + 薄外套"),  # 平均 15°C 以下
        (20, 30, 0, "短袖"),         # 平均 25°C 以下
    ]
    
    for temp_min, temp_max, weather_code, expected_keyword in test_cases:
        result = get_clothing_recommendation(temp_min, temp_max, weather_code)
        assert expected_keyword in result, f"穿衣推荐错误：{temp_min}-{temp_max}°C"
    
    print("✅ 穿衣推荐测试通过")


def test_weather_tip():
    """测试温馨提示"""
    print("\n=== 测试温馨提示===")
    
    # 大雨提示
    tip = get_weather_tip(0, 10, 20, 80)
    assert "大雨，务必带伞" in tip
    
    # 温差提示
    tip = get_weather_tip(0, 5, 25, 10)
    assert "温差达" in tip
    
    # 低温提示
    tip = get_weather_tip(0, -5, 10, 10)
    assert "早晨低温" in tip
    
    print("✅ 温馨提示测试通过")


def test_embed_creation():
    """测试 Embed 创建"""
    print("\n=== 测试 Embed 创建===")
    
    weather_data = {
        "daily": {
            "time": ["2026-03-24"],
            "weathercode": [0],
            "temperature_2m_max": [15],
            "temperature_2m_min": [5],
            "precipitation_probability_max": [10],
            "windspeed_10m_max": [12]
        }
    }
    
    embed = create_weather_embed("杭州", "2026 年 03 月 24 日", "周二", weather_data, is_morning=True)
    
    assert embed["title"] == "🌅 杭州今日天气播报"
    assert len(embed["fields"]) == 4
    assert embed["color"] == 3447003
    
    print("✅ Embed 创建测试通过")


def run_all_tests():
    """运行所有测试"""
    print("=" * 50)
    print("天气推送技能双模式发送测试")
    print("=" * 50)
    
    tests = [
        test_send_mode_auto_with_webhook,
        test_send_mode_auto_without_webhook,
        test_send_mode_auto_webhook_fallback,
        test_send_mode_message,
        test_send_mode_webhook,
        test_weather_code_mapping,
        test_clothing_recommendation,
        test_weather_tip,
        test_embed_creation,
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            test()
            passed += 1
        except Exception as e:
            print(f"❌ {test.__name__} 失败：{e}")
            failed += 1
    
    print("\n" + "=" * 50)
    print(f"测试完成：{passed} 通过，{failed} 失败")
    print("=" * 50)
    
    return failed == 0


if __name__ == "__main__":
    success = run_all_tests()
    sys.exit(0 if success else 1)
