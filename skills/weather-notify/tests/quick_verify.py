#!/usr/bin/env python3
"""
快速验证脚本 - 验证双模式发送功能的基本逻辑
"""

import sys
import os

# 添加项目路径
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# 导入测试函数
from tests.test_send_mode import (
    test_send_mode_auto_with_webhook,
    test_send_mode_auto_without_webhook,
    test_send_mode_auto_webhook_fallback,
    test_send_mode_message,
    test_send_mode_webhook,
    test_weather_code_mapping,
    test_clothing_recommendation,
    test_weather_tip,
    test_embed_creation,
)

def quick_verify():
    """快速验证核心功能"""
    print("\n" + "=" * 60)
    print("天气推送技能 - 双模式发送功能验证")
    print("=" * 60)
    
    tests = [
        ("发送模式 - auto+webhook", test_send_mode_auto_with_webhook),
        ("发送模式 - auto 无 webhook", test_send_mode_auto_without_webhook),
        ("发送模式 - 降级机制", test_send_mode_auto_webhook_fallback),
        ("发送模式 - message 强制", test_send_mode_message),
        ("发送模式 - webhook 强制", test_send_mode_webhook),
        ("天气代码映射", test_weather_code_mapping),
        ("穿衣推荐算法", test_clothing_recommendation),
        ("温馨提示生成", test_weather_tip),
        ("Embed 消息创建", test_embed_creation),
    ]
    
    passed = 0
    failed = 0
    
    for name, test_func in tests:
        try:
            test_func()
            passed += 1
        except Exception as e:
            print(f"❌ {name} 失败：{e}")
            failed += 1
    
    print("\n" + "=" * 60)
    print(f"验证结果：{passed} 通过，{failed} 失败")
    print("=" * 60)
    
    if failed == 0:
        print("\n✅ 所有测试通过！双模式发送功能正常。")
        print("\n配置示例:")
        print('  send_mode: "auto"   - 自动选择（推荐）')
        print('  send_mode: "message" - 强制使用 Message 工具')
        print('  send_mode: "webhook" - 强制使用 Webhook')
        print("\n降级机制：Webhook 失败时自动切换到 Message 工具")
    
    return failed == 0

if __name__ == "__main__":
    success = quick_verify()
    sys.exit(0 if success else 1)
