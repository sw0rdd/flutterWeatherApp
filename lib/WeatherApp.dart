
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/AboutScreen.dart';
import 'package:http/http.dart' as http;

const apiKey = 'ce70af78d0f86e1e39f6120ad1d3b730';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _location = "";
  double _temp = 0;
  String _condition = "";
  String _describtion = "";
  late Future<void> _futureData;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureData = fetchData();
  }


  Future<Position?> _getLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low);
    } catch (e) {
      print(e);
      return null;
    }
  }


  Future<void> fetchData() async {
    bool hasPermission = await _requistLocationPerm();
    if (!hasPermission) {
      throw Exception(
          "Location denied"
      );
    }

    Position? position = await _getLocation();
    if (position == null) {
      throw Exception(
          "Failed to get current location"
      );
    }


    final response = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey"));

    if (response.statusCode == 200) {
      final weatherData = jsonDecode(response.body);
      setState(() {
        _location = "${weatherData["name"]}, ${weatherData["sys"]["country"]}";
        _temp = (weatherData["main"]["temp"] - 273.15).toDouble();
        _condition = weatherData["weather"][0]["main"];
        _describtion = weatherData["weather"][0]["description"];
      });
    } else {
      throw Exception("Weather data couldn't be loaded");
    }
  }

  final Map<String, Map<String, dynamic>> weatherIcon = {
    "Clear": {
      'icon': Icons.wb_sunny,
      'color': Colors.yellow
    },
    "Clouds": {
      'icon': Icons.cloud,
      'color': Colors.grey
    },
    "Rain": {
      'icon': Icons.umbrella,
      'color': Colors.blue
    },
    "Snow": {
      'icon': Icons.ac_unit,
      'color': Colors.grey[700] // Dark grey
    },
  };

  Widget fetchIcon(String _condition) {
    // check for error from API
    if (!weatherIcon.containsKey(_condition)) {
      return const Icon(Icons.error_outline, size: 70, color: Colors.red);
    }

    IconData? iconData = weatherIcon[_condition]?["icon"] as IconData?;
    Color? iconColor = weatherIcon[_condition]?["color"] as Color?;

    return Icon(
      iconData ?? Icons.error, // Fallback to error icon if iconData is null
      size: 70,
      color: iconColor ?? Colors.lightBlue, // Fallback to lightBlue if iconColor is null
    );
  }

  Future<bool> _requistLocationPerm() async {
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }



  Widget _buildBody() { // New method to conditionally build the body based on _currentIndex
    if (_currentIndex == 0) {
      return FutureBuilder(
        future: _futureData,
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          //show loading when weather is loaded
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // display error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // if succuess, show weather
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                fetchIcon(_condition),
                const SizedBox(height: 16),
                Text(
                  _location,
                  style: const TextStyle(
                    fontSize: 40,
                    fontFamily: "Anton"
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                    DateFormat("EEE, MMM d, y").format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: "Merriweather"
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_describtion[0].toUpperCase()}${_describtion.substring(1)}',
                  style: const TextStyle(
                      fontSize: 20,
                    fontFamily: "Merriweather",
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  '${_temp.round()}°C',
                  style: const TextStyle(
                    fontSize: 60,
                    fontFamily: "Anton"
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    } else {
      return const AboutScreen(); // Assuming this is your About widget
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Current"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "About"
          )
        ],
      ),
    );
  }


}
