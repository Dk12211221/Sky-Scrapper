import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/theme_provider.dart';
import '../provider/weather_provider.dart';
import '../provider/internet_provider.dart';
import 'bookmark_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  List<String> savedCities = [];
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    loadSavedCities();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final internetProvider = Provider.of<Internetprovider>(context);
    if (internetProvider.connectivityResult == ConnectivityResult.none && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoInternetDialog();
      });
    }
  }

  Future<void> _showNoInternetDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Please check your connection and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _dialogShown = false;
              });
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Future<void> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities = prefs.getStringList('saved_cities') ?? [];
    });
  }

  Future<void> bookmarkCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    if (!savedCities.contains(city)) {
      savedCities.add(city);
      await prefs.setStringList('saved_cities', savedCities);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$city bookmarked!')),
      );
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$city is already bookmarked.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final internetProvider = Provider.of<Internetprovider>(context);
    final isDark = themeProvider.isDarkMode;
    final bool hasInternet = internetProvider.connectivityResult != ConnectivityResult.none;

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App', style: GoogleFonts.poppins()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SavedCitiesScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          )
        ],
        flexibleSpace: Container(
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
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.purple.shade50, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const SizedBox(height: 10),
            if (hasInternet) ...[
              TextField(
                controller: _cityController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Enter city name',
                  labelStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.location_city),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      if (_cityController.text.isNotEmpty) {
                        weatherProvider.fetchWeather(_cityController.text);
                      }
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              weatherProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : weatherProvider.weatherData == null
                  ? Center(
                child: Text(
                  'Search for a city to get weather updates',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.location_on,
                            size: 40, color: Colors.deepPurple),
                        const SizedBox(height: 8),
                        Text(
                          weatherProvider.weatherData!.city,
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.deepPurple.shade900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Icon(Icons.thermostat,
                            size: 50, color: Colors.orange),
                        Text(
                          '${weatherProvider.weatherData!.temperature}°C',
                          style: GoogleFonts.poppins(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            bookmarkCity(
                                weatherProvider.weatherData!.city);
                          },
                          icon: const Icon(Icons.bookmark_add_outlined),
                          label: Text('Bookmark City',
                              style: GoogleFonts.poppins()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                  buildDetailRow(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value:
                    '${weatherProvider.weatherData!.humidity}%',
                    isDark: isDark,
                  ),
                  buildDetailRow(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value:
                    '${weatherProvider.weatherData!.windSpeed} km/h',
                    isDark: isDark,
                  ),
                  buildDetailRow(
                    icon: Icons.wb_sunny,
                    label: 'Sunrise',
                    value: weatherProvider.weatherData!.sunrise,
                    isDark: isDark,
                  ),
                  buildDetailRow(
                    icon: Icons.nights_stay,
                    label: 'Sunset',
                    value: weatherProvider.weatherData!.sunset,
                    isDark: isDark,
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
            ),
          ),
        ],
      ),
    );
  }
}
