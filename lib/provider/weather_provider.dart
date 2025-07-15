import 'package:flutter/material.dart';
import '../utils/models/api.dart';
import '../utils/models/weather.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weatherData;
  bool _isLoading = false;

  Weather? get weatherData => _weatherData;
  bool get isLoading => _isLoading;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weatherData = await WeatherService.getWeather(city);
    } catch (e) {
      print('Error fetching weather: $e');
      _weatherData = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
