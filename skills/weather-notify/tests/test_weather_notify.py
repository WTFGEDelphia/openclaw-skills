#!/usr/bin/env python3
"""
weather-notify 单元测试
测试穿衣推荐算法、温馨提示生成、天气代码映射
"""

import unittest
import sys
import os

# 添加脚本所在目录到路径
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PARENT_DIR = os.path.dirname(SCRIPT_DIR)
sys.path.insert(0, PARENT_DIR)

from main import (
    WEATHER_CODES,
    get_weather_info,
    get_clothing_recommendation,
    get_weather_tip
)


class TestWeatherCodes(unittest.TestCase):
    """测试天气代码映射"""
    
    def test_sunny(self):
        """测试晴天代码"""
        weather, icon = get_weather_info(0)
        self.assertEqual(weather, "晴天")
        self.assertEqual(icon, "☀️")
    
    def test_cloudy(self):
        """测试多云代码"""
        for code in [1, 2, 3]:
            weather, icon = get_weather_info(code)
            self.assertEqual(weather, "多云")
            self.assertEqual(icon, "⛅")
    
    def test_fog(self):
        """测试雾天代码"""
        for code in [45, 48]:
            weather, icon = get_weather_info(code)
            self.assertEqual(weather, "雾")
            self.assertEqual(icon, "🌫️")
    
    def test_rain(self):
        """测试雨天代码"""
        # 小雨
        weather, icon = get_weather_info(51)
        self.assertEqual(weather, "小雨")
        self.assertEqual(icon, "🌧️")
        
        # 中雨
        weather, icon = get_weather_info(63)
        self.assertEqual(weather, "中雨")
        
        # 大雨
        weather, icon = get_weather_info(65)
        self.assertEqual(weather, "大雨")
    
    def test_snow(self):
        """测试雪天代码"""
        # 小雪
        weather, icon = get_weather_info(71)
        self.assertEqual(weather, "小雪")
        self.assertEqual(icon, "❄️")
        
        # 大雪
        weather, icon = get_weather_info(75)
        self.assertEqual(weather, "大雪")
    
    def test_shower(self):
        """测试阵雨代码"""
        for code in [80, 81, 82]:
            weather, icon = get_weather_info(code)
            self.assertEqual(weather, "阵雨")
            self.assertEqual(icon, "🌧️")
    
    def test_snow_shower(self):
        """测试阵雪代码"""
        for code in [85, 86]:
            weather, icon = get_weather_info(code)
            self.assertEqual(weather, "阵雪")
            self.assertEqual(icon, "❄️")
    
    def test_thunderstorm(self):
        """测试雷雨代码"""
        weather, icon = get_weather_info(95)
        self.assertEqual(weather, "雷雨")
        self.assertEqual(icon, "⛈️")
    
    def test_unknown(self):
        """测试未知天气代码"""
        weather, icon = get_weather_info(999)
        self.assertEqual(weather, "未知")
        self.assertEqual(icon, "❓")


class TestClothingRecommendation(unittest.TestCase):
    """测试穿衣推荐算法"""
    
    def test_very_cold(self):
        """测试极冷天气 (< 5°C)"""
        result = get_clothing_recommendation(-5, 3, 0)
        self.assertIn("厚羽绒服", result)
        self.assertIn("保暖内衣", result)
        self.assertIn("围巾", result)
        self.assertIn("手套", result)
    
    def test_cold(self):
        """测试寒冷天气 (5-10°C)"""
        result = get_clothing_recommendation(5, 9, 0)
        self.assertIn("厚外套", result)
        self.assertIn("毛衣", result)
        self.assertIn("保暖内衣", result)
    
    def test_cool(self):
        """测试凉爽天气 (10-15°C)"""
        result = get_clothing_recommendation(10, 14, 0)
        self.assertIn("长袖", result)
        self.assertIn("薄外套", result)
        self.assertIn("毛衣", result)
    
    def test_mild(self):
        """测试温和天气 (15-20°C)"""
        result = get_clothing_recommendation(15, 19, 0)
        self.assertIn("长袖", result)
        self.assertIn("薄外套", result)
        self.assertNotIn("毛衣", result)
    
    def test_warm(self):
        """测试温暖天气 (20-25°C)"""
        result = get_clothing_recommendation(20, 24, 0)
        self.assertIn("短袖", result)
        self.assertIn("薄外套", result)
        self.assertIn("早晚", result)
    
    def test_hot(self):
        """测试炎热天气 (25-30°C)"""
        result = get_clothing_recommendation(25, 29, 0)
        self.assertIn("短袖", result)
        self.assertIn("防晒", result)
    
    def test_very_hot(self):
        """测试酷热天气 (> 30°C)"""
        result = get_clothing_recommendation(30, 35, 0)
        self.assertIn("短袖", result)
        self.assertIn("防晒衣", result)
        self.assertIn("多喝水", result)
    
    def test_rainy_day(self):
        """测试雨天特殊推荐"""
        # 小雨代码 51
        result = get_clothing_recommendation(15, 20, 51)
        self.assertIn("防水外套", result)
        self.assertIn("雨具", result)
        self.assertIn("防水鞋", result)
    
    def test_foggy_day(self):
        """测试雾天特殊推荐"""
        result = get_clothing_recommendation(10, 15, 45)
        self.assertIn("口罩", result)
        self.assertIn("交通安全", result)
    
    def test_snowy_day(self):
        """测试雪天特殊推荐"""
        result = get_clothing_recommendation(-2, 5, 71)
        self.assertIn("防滑鞋", result)
        self.assertIn("保暖", result)
        self.assertIn("路滑", result)
    
    def test_large_temperature_difference(self):
        """测试温差大推荐"""
        # 温差超过 10°C
        result = get_clothing_recommendation(10, 22, 0)
        self.assertIn("温差大", result)
        self.assertIn("洋葱式穿衣", result)


class TestWeatherTips(unittest.TestCase):
    """测试温馨提示生成"""
    
    def test_heavy_rain(self):
        """测试大雨提示"""
        result = get_weather_tip(65, 15, 20, 80)
        self.assertIn("大雨", result)
        self.assertIn("务必带伞", result)
    
    def test_possible_rain(self):
        """测试可能有雨提示"""
        result = get_weather_tip(51, 15, 20, 50)
        self.assertIn("可能有雨", result)
        self.assertIn("建议带伞", result)
    
    def test_foggy_warning(self):
        """测试雾天警告"""
        result = get_weather_tip(45, 10, 15, 10)
        self.assertIn("雾霾", result)
        self.assertIn("户外活动", result)
    
    def test_large_temp_diff(self):
        """测试温差提示"""
        result = get_weather_tip(0, 8, 20, 10)
        self.assertIn("温差", result)
        self.assertIn("增减衣物", result)
    
    def test_morning_cold(self):
        """测试早晨低温提示"""
        result = get_weather_tip(0, 2, 15, 10)
        self.assertIn("早晨低温", result)
        self.assertIn("保暖", result)
    
    def test_high_temperature(self):
        """测试高温提示"""
        result = get_weather_tip(0, 25, 32, 10)
        self.assertIn("高温", result)
        self.assertIn("防暑降温", result)
    
    def test_high_wind(self):
        """测试大风提示"""
        result = get_weather_tip(0, 15, 25, 10, wind_speed=35)
        self.assertIn("风力较大", result)
        self.assertIn("防风", result)
    
    def test_pleasant_weather(self):
        """测试宜人天气"""
        result = get_weather_tip(1, 15, 22, 10)
        self.assertEqual(result, "💡 今日天气宜人！")
    
    def test_combined_tips(self):
        """测试多个提示组合"""
        # 大雨 + 大风
        result = get_weather_tip(65, 15, 20, 80, wind_speed=35)
        self.assertIn("大雨", result)
        self.assertIn("务必带伞", result)
        self.assertIn("风力较大", result)
        self.assertIn("防风", result)


class TestWeatherInfoIntegration(unittest.TestCase):
    """集成测试：天气信息组合"""
    
    def test_spring_day(self):
        """测试春季典型天气"""
        # 多云，15-22°C，微风
        clothing = get_clothing_recommendation(15, 22, 1)
        tip = get_weather_tip(1, 15, 22, 10, wind_speed=10)
        
        self.assertIn("长袖", clothing)
        self.assertIn("薄外套", clothing)
        self.assertEqual(tip, "💡 今日天气宜人！")
    
    def test_summer_storm(self):
        """测试夏季雷雨"""
        # 雷雨，25-30°C，降水概率 80%
        clothing = get_clothing_recommendation(25, 30, 95)
        tip = get_weather_tip(95, 25, 30, 80)
        
        self.assertIn("短袖", clothing)
        self.assertIn("防晒", clothing)
        self.assertIn("大雨", tip)
    
    def test_winter_cold(self):
        """测试冬季寒冷"""
        # 晴天，-5-5°C
        clothing = get_clothing_recommendation(-5, 5, 0)
        tip = get_weather_tip(0, -5, 5, 10)
        
        self.assertIn("厚羽绒服", clothing)
        self.assertIn("早晨低温", tip)
        self.assertIn("保暖", tip)
    
    def test_autumn_rain(self):
        """测试秋季雨天"""
        # 小雨，10-15°C，降水概率 60%
        clothing = get_clothing_recommendation(10, 15, 51)
        tip = get_weather_tip(51, 10, 15, 60)
        
        self.assertIn("防水外套", clothing)
        self.assertIn("雨具", clothing)
        self.assertIn("可能有雨", tip)


if __name__ == '__main__':
    unittest.main(verbosity=2)
