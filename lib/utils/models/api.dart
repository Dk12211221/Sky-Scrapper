import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weatherapp/utils/models/weather.dart';

class WeatherService {
  static const String apiKey = '137f00d279fccf2ab0c9fbd716a2e8bf';
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  static Future<Weather?> getWeather(String city) async {
    final url = '$baseUrl?q=$city&appid=$apiKey&units=metric';
    print('Fetching weather data from: $url'); // Debugging log

    try {
      final response = await http.get(Uri.parse(url));
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Debugging log

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Parsed JSON: $data'); // Debugging log

        if (data.containsKey('main')) {
          return Weather.fromJson(data);
        } else {
          print('Error: Invalid response format');
          return null;
        }
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception caught: $e');
      return null;
    }
  }
}
