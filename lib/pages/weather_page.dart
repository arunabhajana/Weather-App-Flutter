// ignore_for_file: avoid_print

import 'dart:async'; // Add this line to import the Timer class
import 'package:flutter/material.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final _weatherService = WeatherService('YOUR API KEY HERE');
  Weather? _weather;

  bool isBadWeather(String? mainCondition) {
    if (mainCondition == null) return false;

    return mainCondition.toLowerCase() == 'rain' ||
        mainCondition.toLowerCase() == 'thunderstorm';
  }

  _fetchWeather() async {
    String cityName = await _weatherService.getCurrentCity();
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  String getWeatherAnimation(String? maincondition) {
    if (maincondition == null) return 'assets/sunny.json';

    switch (maincondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/windy.json';

      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/raining.json';

      case 'thunderstorm':
        return 'assets/thunder.json';

      case 'clear':
        return 'assets/sunny.json';

      default:
        return 'assets/sunny.json';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();

    // Schedule periodic updates every minute
    Timer.periodic(const Duration(minutes: 1), (Timer timer) {
      _fetchWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        bool isBadWeatherCondition =
            isBadWeather(_weather?.mainCondition ?? "");

        return Theme(
          data: isBadWeatherCondition
              ? ThemeData.dark() // Dark theme for bad weather
              : ThemeData.light(), // Light theme for other conditions
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // City name
                  Text(_weather?.cityName ?? "loading city..."),
                  // Weather animation
                  Lottie.asset(
                      getWeatherAnimation(_weather?.mainCondition ?? "")),
                  // Temperature
                  Text('${_weather?.temperature.round()}°C'),
                  // Weather condition
                  Text(_weather?.mainCondition ?? ""),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
