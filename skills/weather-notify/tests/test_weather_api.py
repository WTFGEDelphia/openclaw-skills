#!/usr/bin/env python3
"""天气 API 单元测试"""

import unittest
from unittest.mock import patch, MagicMock
from main import fetch_weather_data, get_clothing_recommendation, get_weather_tip, WEATHER_CODES


class TestWeatherAPI(unittest.TestCase):
    """测试天气 API 相关功能"""
    
    @patch('main.requests.get')
    def test_fetch_weather_success(self, mock_get):
        """测试 API 调用成功"""
        # 模拟 API 响应
        mock_response = MagicMock()
        mock_response.json.return_value = {
            "daily": {
                "time": ["2026-03-24"],
                "weathercode": [0],
                "temperature_2m_max": [15],
                "temperature_2m_min": [8],
                "precipitation_probability_max": [10],
                "windspeed_10m_max": [12],
                "relativehumidity_2m_max": [63]
            }
        }
        mock_response.raise_for_status = MagicMock()
        mock_get.return_value = mock_response
        
        # 调用函数
        result = fetch_weather_data(30.2741, 120.1551, retry_times=1)
        
        # 验证结果
        self.assertEqual(result["daily"]["temperature_2m_max"][0], 15)
        mock_get.assert_called_once()
    
    @patch('main.requests.get')
    def test_fetch_weather_retry(self, mock_get):
        """测试 API 调用失败后重试"""
        # 模拟前两次失败，第三次成功
        mock_response = MagicMock()
        mock_response.json.return_value = {
            "daily": {
                "time": ["2026-03-24"],
                "weathercode": [1],
                "temperature_2m_max": [20],
                "temperature_2m_min": [12],
                "precipitation_probability_max": [30],
                "windspeed_10m_max": [8],
                "relativehumidity_2m_max": [70]
            }
        }
        mock_response.raise_for_status = MagicMock()
        
        # 第一次和第二次调用抛出异常
        mock_get.side_effect = [
            Exception("Timeout"),
            Exception("Timeout"),
            mock_response
        ]
        
        # 调用函数
        result = fetch_weather_data(30.2741, 120.1551, retry_times=3)
        
        # 验证重试了 3 次
        self.assertEqual(mock_get.call_count, 3)
        self.assertEqual(result["daily"]["weathercode"][0], 1)


class TestClothingRecommendation(unittest.TestCase):
    """测试穿衣推荐算法"""
    
    def test_clothing_cold(self):
        """测试低温穿衣推荐"""
        result = get_clothing_recommendation(0, 5, 0)
        self.assertIn("厚羽绒服", result)
    
    def test_clothing_cool(self):
        """测试凉爽天气穿衣推荐"""
        result = get_clothing_recommendation(8, 12, 0)
        self.assertIn("厚外套", result)
    
    def test_clothing_mild(self):
        """测试温和天气穿衣推荐"""
        result = get_clothing_recommendation(15, 20, 0)
        self.assertIn("长袖", result)
    
    def test_clothing_warm(self):
        """测试温暖天气穿衣推荐"""
        result = get_clothing_recommendation(22, 26, 0)
        self.assertIn("短袖", result)
    
    def test_clothing_hot(self):
        """测试高温穿衣推荐"""
        result = get_clothing_recommendation(28, 35, 0)
        self.assertIn("防晒", result)
    
    def test_clothing_rainy(self):
        """测试雨天穿衣推荐"""
        result = get_clothing_recommendation(12, 18, 61)  # 小雨
        self.assertIn("防水外套", result)
        self.assertIn("携带雨具", result)
    
    def test_clothing_foggy(self):
        """测试雾天穿衣推荐"""
        result = get_clothing_recommendation(10, 15, 45)  # 雾
        self.assertIn("佩戴口罩", result)
    
    def test_clothing_thunderstorm(self):
        """测试雷雨穿衣推荐"""
        result = get_clothing_recommendation(18, 25, 95)  # 雷雨
        self.assertIn("避免外出", result)
    
    def test_clothing_large_temp_diff(self):
        """测试温差大穿衣推荐"""
        result = get_clothing_recommendation(8, 22, 0)  # 温差 14°C
        self.assertIn("温差大", result)
        self.assertIn("洋葱式穿衣", result)


class TestWeatherTip(unittest.TestCase):
    """测试温馨提示生成"""
    
    def test_tip_rainy(self):
        """测试雨天提示"""
        result = get_weather_tip(61, 10, 18, 80, 70, 10)
        self.assertIn("带伞", result)
    
    def test_tip_foggy(self):
        """测试雾天提示"""
        result = get_weather_tip(45, 8, 15, 20, 80, 5)
        self.assertIn("雾霾", result)
    
    def test_tip_large_temp_diff(self):
        """测试温差大提示"""
        result = get_weather_tip(0, 5, 20, 10, 50, 10)
        self.assertIn("温差", result)
    
    def test_tip_low_temp(self):
        """测试低温提示"""
        result = get_weather_tip(0, 2, 10, 10, 50, 10)
        self.assertIn("低温", result)
    
    def test_tip_high_temp(self):
        """测试高温提示"""
        result = get_weather_tip(0, 20, 32, 10, 40, 10)
        self.assertIn("高温", result)
    
    def test_tip_high_wind(self):
        """测试大风提示"""
        result = get_weather_tip(0, 15, 25, 10, 50, 35)
        self.assertIn("风力较大", result)
    
    def test_tip_comfortable(self):
        """测试舒适天气提示"""
        result = get_weather_tip(0, 15, 22, 20, 60, 10)
        self.assertIn("天气舒适", result)


class TestWeatherCodes(unittest.TestCase):
    """测试天气代码映射"""
    
    def test_clear(self):
        """测试晴天代码"""
        self.assertIn("☀️", WEATHER_CODES[0][0])
    
    def test_cloudy(self):
        """测试多云代码"""
        self.assertIn("⛅", WEATHER_CODES[2][0])
    
    def test_rain(self):
        """测试雨天代码"""
        self.assertIn("🌧️", WEATHER_CODES[61][0])
    
    def test_snow(self):
        """测试雪天代码"""
        self.assertIn("❄️", WEATHER_CODES[71][0])
    
    def test_thunderstorm(self):
        """测试雷雨代码"""
        self.assertIn("⛈️", WEATHER_CODES[95][0])
    
    def test_fog(self):
        """测试雾天代码"""
        self.assertIn("🌫️", WEATHER_CODES[45][0])


if __name__ == '__main__':
    unittest.main(verbosity=2)
