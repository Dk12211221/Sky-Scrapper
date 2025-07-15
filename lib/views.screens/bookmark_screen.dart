import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/weather_provider.dart';
import '../provider/theme_provider.dart';
import 'detail_screen.dart';

class SavedCitiesScreen extends StatefulWidget {
  @override
  _SavedCitiesScreenState createState() => _SavedCitiesScreenState();
}

class _SavedCitiesScreenState extends State<SavedCitiesScreen> {
  List<String> savedCities = [];

  @override
  void initState() {
    super.initState();
    loadSavedCities();
  }

  Future<void> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities = prefs.getStringList('saved_cities') ?? [];
    });
  }

  Future<void> removeCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities.remove(city);
    });
    await prefs.setStringList('saved_cities', savedCities);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Saved Cities',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Colors.deepPurple.shade900, Colors.black]
                  : [Colors.deepPurple, Colors.purple.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: savedCities.isEmpty
          ? Center(
        child: Text(
          'No saved cities yet!',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: isDark ? Colors.white70 : Colors.grey[700],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: savedCities.length,
        itemBuilder: (context, index) {
          final city = savedCities[index];
          return GestureDetector(
            onTap: () {
              weatherProvider.fetchWeather(city);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen()),
              );
            },
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.deepPurple.shade800, Colors.black87]
                          : [Colors.purpleAccent, Colors.deepPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Row(
                      children: [
                        const SizedBox(width: 48), // space for icon
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                city,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap to view weather details',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          onPressed: () => removeCity(city),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.white.withOpacity(0.9),
                    ),
                    child: const Icon(Icons.location_city,
                        color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
