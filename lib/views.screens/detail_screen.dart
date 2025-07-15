import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/weather_provider.dart';
import '../provider/theme_provider.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final weatherData = weatherProvider.weatherData;

    Future<void> saveCity(String city) async {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedCities = prefs.getStringList('saved_cities') ?? [];

      if (!savedCities.contains(city)) {
        savedCities.add(city);
        await prefs.setStringList('saved_cities', savedCities);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$city saved!')),
        );
      }
    }

    if (weatherData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weather Details'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'No weather data available.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${weatherData.city} Weather',
            style: GoogleFonts.poppins(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () => saveCity(weatherData.city),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.deepPurple.shade900, Colors.black]
                    : [Colors.purpleAccent.shade100, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Main Weather Card
          Center(
            child: Card(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.white.withOpacity(0.88),
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud, size: 70, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    Text(
                      '${weatherData.temperature}°C',
                      style: GoogleFonts.poppins(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.deepPurple.shade800,
                      ),
                    ),
                    const SizedBox(height: 30),
                    buildWeatherInfo(
                      isDark,
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${weatherData.humidity}%',
                    ),
                    buildWeatherInfo(
                      isDark,
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '${weatherData.windSpeed} km/h',
                    ),
                    buildWeatherInfo(
                      isDark,
                      icon: Icons.wb_sunny,
                      label: 'Sunrise',
                      value: weatherData.sunrise,
                    ),
                    buildWeatherInfo(
                      isDark,
                      icon: Icons.nights_stay,
                      label: 'Sunset',
                      value: weatherData.sunset,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWeatherInfo(bool isDark,
      {required IconData icon,
        required String label,
        required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white70 : Colors.deepPurple),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
