import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/weather_main_card.dart';
import '../widgets/hourly_item.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<WeatherProvider>(context, listen: false);

      // safe call
      p.fetchWeather("Lahore");
    });
  }

  @override
  void dispose() {
    controller.dispose(); // ✅ memory leak fix
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<WeatherProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌄 DYNAMIC BACKGROUND BASED ON WEATHER
        decoration: _buildBackgroundDecoration(p.weather?.icon),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: SingleChildScrollView(
              child: Column(
                children: [

                  // 🔍 SEARCH
                  GlassCard(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search city",
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            final city = controller.text.trim();

                            if (city.isNotEmpty) {
                              p.fetchWeather(city);
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ⏳ LOADING
                  if (p.loading)
                    const CircularProgressIndicator(color: Colors.white),

                  // ❌ ERROR
                  if (p.error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        p.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 🌤️ WEATHER CARD (100% SAFE FIX)
                  if (p.weather != null)
                    Builder(
                      builder: (context) {
                        try {
                          return WeatherMainCard(data: p.weather!);
                        } catch (e) {
                          return const Text(
                            "Weather UI Error",
                            style: TextStyle(color: Colors.red),
                          );
                        }
                      },
                    )
                  else
                    const Text(
                      "No Weather Data",
                      style: TextStyle(color: Colors.white70),
                    ),

                  const SizedBox(height: 20),

                  // 🕒 HOURLY FORECAST
                  if (p.forecast.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Hourly Forecast",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: p.forecast.length,
                            itemBuilder: (context, i) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: HourlyItem(data: p.forecast[i]),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(),

                  const SizedBox(height: 20),

                  // 📌 DEFAULT
                  if (!p.loading && p.weather == null)
                    const Text(
                      "Search a city to see weather 🌍",
                      style: TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  BoxDecoration _buildBackgroundDecoration(String? icon) {
    final gradient = _backgroundGradient(icon);
    return BoxDecoration(
      gradient: gradient,
      image: icon != null
          ? DecorationImage(
              image: NetworkImage(_backgroundImageUrl(icon)),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35),
                BlendMode.darken,
              ),
            )
          : null,
    );
  }

  LinearGradient _backgroundGradient(String? icon) {
    if (icon == null) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF394867), Color(0xFF212B40)],
      );
    }

    if (icon.startsWith('01')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF56CCF2), Color(0xFF2F80ED)],
      );
    } else if (icon.startsWith('02') || icon.startsWith('03') || icon.startsWith('04')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF8E9AAF), Color(0xFF4A5E7B)],
      );
    } else if (icon.startsWith('09') || icon.startsWith('10')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      );
    } else if (icon.startsWith('11')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0F2027), Color(0xFF203A43)],
      );
    } else if (icon.startsWith('13')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF83A4D4), Color(0xFFB6FBFF)],
      );
    } else if (icon.endsWith('n')) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF283048), Color(0xFF859398)],
      );
    }

    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
    );
  }

  String _backgroundImageUrl(String icon) {
    if (icon.startsWith('01')) {
      return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1200&q=80';
    } else if (icon.startsWith('02') || icon.startsWith('03') || icon.startsWith('04')) {
      return 'https://images.unsplash.com/photo-1499346030926-9a72daac6c63?auto=format&fit=crop&w=1200&q=80';
    } else if (icon.startsWith('09') || icon.startsWith('10')) {
      return 'https://images.unsplash.com/photo-1501973801540-537f08ccae7b?auto=format&fit=crop&w=1200&q=80';
    } else if (icon.startsWith('11')) {
      return 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?auto=format&fit=crop&w=1200&q=80';
    } else if (icon.startsWith('13')) {
      return 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?auto=format&fit=crop&w=1200&q=80';
    } else if (icon.endsWith('n')) {
      return 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=80';
    }
    return 'https://images.unsplash.com/photo-1496979363610-35a4f9f84167?auto=format&fit=crop&w=1200&q=80';
  }}