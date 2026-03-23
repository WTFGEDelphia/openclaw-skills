#!/usr/bin/env python3
"""穿衣推荐算法单元测试"""

import unittest
from main import get_clothing_recommendation, get_weather_tip


class TestClothingRecommendation(unittest.TestCase):
    """测试穿衣推荐算法"""
    
    def test_extreme_cold_below_zero(self):
        """测试零下低温"""
        result = get_clothing_recommendation(-5, 2, 0)
        self.assertIn("厚羽绒服", result)
        self.assertIn("保暖内衣", result)
    
    def test_cold_0_to_5(self):
        """测试 0-5°C 低温"""
        result = get_clothing_recommendation(0, 5, 0)
        self.assertIn("厚羽绒服", result)
    
    def test_cool_5_to_10(self):
        """测试 5-10°C 凉爽"""
        result = get_clothing_recommendation(5, 10, 0)
        self.assertIn("厚外套", result)
    
    def test_cool_10_to_15(self):
        """测试 10-15°C 微凉"""
        result = get_clothing_recommendation(10, 15, 0)
        self.assertIn("长袖", result)
        self.assertIn("薄外套", result)
    
    def test_mild_15_to_20(self):
        """测试 15-20°C 温和"""
        result = get_clothing_recommendation(15, 20, 0)
        self.assertIn("长袖", result)
        self.assertIn("薄外套", result)
    
    def test_warm_20_to_25(self):
        """测试 20-25°C 温暖"""
        result = get_clothing_recommendation(20, 25, 0)
        self.assertIn("短袖", result)
    
    def test_hot_25_to_30(self):
        """测试 25-30°C 炎热"""
        result = get_clothing_recommendation(25, 30, 0)
        self.assertIn("短袖", result)
        self.assertIn("防晒", result)
    
    def test_extreme_hot_above_30(self):
        """测试 30°C 以上酷热"""
        result = get_clothing_recommendation(30, 38, 0)
        self.assertIn("短袖", result)
        self.assertIn("防晒衣", result)
        self.assertIn("多喝水", result)
    
    def test_rainy_light(self):
        """测试小雨天气"""
        result = get_clothing_recommendation(12, 18, 61)
        self.assertIn("防水外套", result)
        self.assertIn("携带雨具", result)
    
    def test_rainy_heavy(self):
        """测试大雨天气"""
        result = get_clothing_recommendation(15, 20, 65)
        self.assertIn("防水外套", result)
        self.assertIn("携带雨具", result)
    
    def test_foggy_light(self):
        """测试轻雾"""
        result = get_clothing_recommendation(10, 15, 45)
        self.assertIn("佩戴口罩", result)
        self.assertIn("注意交通安全", result)
    
    def test_foggy_dense(self):
        """测试浓雾"""
        result = get_clothing_recommendation(8, 12, 48)
        self.assertIn("佩戴口罩", result)
    
    def test_snow_light(self):
        """测试小雪"""
        result = get_clothing_recommendation(-2, 3, 71)
        self.assertIn("防滑鞋", result)
        self.assertIn("保暖", result)
    
    def test_snow_heavy(self):
        """测试大雪"""
        result = get_clothing_recommendation(-5, 0, 75)
        self.assertIn("防滑鞋", result)
        self.assertIn("注意路滑", result)
    
    def test_thunderstorm(self):
        """测试雷雨"""
        result = get_clothing_recommendation(18, 25, 95)
        self.assertIn("避免外出", result)
        self.assertIn("远离金属物体", result)
    
    def test_large_temp_diff(self):
        """测试温差大 (>10°C)"""
        result = get_clothing_recommendation(8, 22, 0)
        self.assertIn("温差大", result)
        self.assertIn("洋葱式穿衣", result)
    
    def test_large_temp_diff_very_large(self):
        """测试温差非常大 (>15°C)"""
        result = get_clothing_recommendation(5, 25, 0)
        self.assertIn("温差大", result)
    
    def test_small_temp_diff(self):
        """测试温差小"""
        result = get_clothing_recommendation(15, 18, 0)
        self.assertNotIn("温差大", result)
    
    def test_high_humidity_hot(self):
        """测试高温高湿"""
        result = get_clothing_recommendation(28, 32, 0, humidity=75)
        self.assertIn("闷热", result)
        self.assertIn("透气", result)
    
    def test_combined_conditions(self):
        """测试组合条件（雨天 + 温差大）"""
        result = get_clothing_recommendation(8, 20, 61)
        self.assertIn("防水外套", result)
        self.assertIn("温差大", result)


class TestWeatherTip(unittest.TestCase):
    """测试温馨提示生成"""
    
    def test_tip_high_precipitation_80(self):
        """测试高降水概率 (80%)"""
        result = get_weather_tip(61, 10, 18, 80, 70, 10)
        self.assertIn("大雨", result)
        self.assertIn("带伞", result)
    
    def test_tip_medium_precipitation_50(self):
        """测试中等降水概率 (50%)"""
        result = get_weather_tip(61, 10, 18, 50, 70, 10)
        self.assertIn("可能", result)
        self.assertIn("带伞", result)
    
    def test_tip_low_precipitation_20(self):
        """测试低降水概率 (20%)"""
        result = get_weather_tip(61, 10, 18, 20, 70, 10)
        self.assertNotIn("带伞", result)
    
    def test_tip_foggy(self):
        """测试雾天提示"""
        result = get_weather_tip(45, 8, 15, 20, 80, 5)
        self.assertIn("雾霾", result)
        self.assertIn("户外活动", result)
    
    def test_tip_large_temp_diff_15(self):
        """测试温差 15°C"""
        result = get_weather_tip(0, 5, 20, 10, 50, 10)
        self.assertIn("温差", result)
        self.assertIn("15°C", result)
    
    def test_tip_low_temp_3(self):
        """测试低温 3°C"""
        result = get_weather_tip(0, 3, 12, 10, 50, 10)
        self.assertIn("低温", result)
        self.assertIn("保暖", result)
    
    def test_tip_high_temp_32(self):
        """测试高温 32°C"""
        result = get_weather_tip(0, 20, 32, 10, 40, 10)
        self.assertIn("高温", result)
        self.assertIn("防暑", result)
    
    def test_tip_high_wind_35(self):
        """测试大风 35km/h"""
        result = get_weather_tip(0, 15, 25, 10, 50, 35)
        self.assertIn("风力较大", result)
        self.assertIn("防风", result)
    
    def test_tip_high_humidity_85(self):
        """测试高湿度 85%"""
        result = get_weather_tip(0, 15, 22, 10, 85, 10)
        self.assertIn("湿度较大", result)
        self.assertIn("防潮", result)
    
    def test_tip_low_humidity_25(self):
        """测试低湿度 25%"""
        result = get_weather_tip(0, 15, 22, 10, 25, 10)
        self.assertIn("干燥", result)
        self.assertIn("补水", result)
    
    def test_tip_comfortable(self):
        """测试舒适天气（无特殊提示）"""
        result = get_weather_tip(0, 15, 22, 20, 60, 10)
        self.assertIn("舒适", result)
    
    def test_tip_multiple_conditions(self):
        """测试多种条件组合"""
        result = get_weather_tip(61, 5, 20, 80, 85, 35)
        self.assertIn("带伞", result)
        self.assertIn("温差", result)
        self.assertIn("湿度", result)
        self.assertIn("风力", result)
    
    def test_tip_zero_precipitation(self):
        """测试无降水"""
        result = get_weather_tip(0, 15, 22, 0, 60, 10)
        self.assertNotIn("带伞", result)
    
    def test_tip_extreme_cold(self):
        """测试极端低温"""
        result = get_weather_tip(0, -5, 5, 10, 50, 10)
        self.assertIn("低温", result)
        self.assertIn("保暖", result)
    
    def test_tip_extreme_heat(self):
        """测试极端高温"""
        result = get_weather_tip(0, 25, 38, 10, 40, 10)
        self.assertIn("高温", result)
        self.assertIn("防暑", result)


class TestEdgeCases(unittest.TestCase):
    """测试边界情况"""
    
    def test_temperature_boundary_10(self):
        """测试温度边界 10°C"""
        result1 = get_clothing_recommendation(5, 10, 0)
        result2 = get_clothing_recommendation(10, 15, 0)
        self.assertNotEqual(result1, result2)
    
    def test_temperature_boundary_20(self):
        """测试温度边界 20°C"""
        result1 = get_clothing_recommendation(15, 20, 0)
        result2 = get_clothing_recommendation(20, 25, 0)
        self.assertNotEqual(result1, result2)
    
    def test_precipitation_boundary_50(self):
        """测试降水概率边界 50%"""
        result1 = get_weather_tip(0, 15, 22, 49, 60, 10)
        result2 = get_weather_tip(0, 15, 22, 51, 60, 10)
        # 49% 不应该提示带伞，51% 应该提示
        self.assertNotIn("带伞", result1)
        self.assertIn("带伞", result2)
    
    def test_temp_diff_boundary_10(self):
        """测试温差边界 10°C"""
        result1 = get_clothing_recommendation(10, 20, 0)  # 温差 10
        result2 = get_clothing_recommendation(10, 21, 0)  # 温差 11
        # 温差 10 不应该提示，温差 11 应该提示
        self.assertNotIn("温差大", result1)
        self.assertIn("温差大", result2)


if __name__ == '__main__':
    unittest.main(verbosity=2)
