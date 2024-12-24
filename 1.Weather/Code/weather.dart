import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  TextEditingController _cityController = TextEditingController();
  String _city = 'Chennai';      
  String _temperature = '--';
  String _weatherDescription = 'Loading...';
  String _humidity = '--';
  String _windSpeed = '--';
  String _error = '';

  final String _apiKey = '012e7346ac8959d7fe943eba36ae35fe';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData(_city);
  }

  Future<void> _fetchWeatherData(String city) async {
    setState(() {
      _error = '';
    });

    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$_apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString();
          _weatherDescription = data['weather'][0]['description'];
          _humidity = data['main']['humidity'].toString();
          _windSpeed = data['wind']['speed'].toString();
        });
      } else {
        setState(() {
          _error = 'City not found. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data. Please check your internet connection.';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _fetchWeatherDataFromCoordinates(position.latitude, position.longitude);
  }

  Future<void> _fetchWeatherDataFromCoordinates(double lat, double lon) async {
    setState(() {
      _error = '';
    });

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _temperature = data['main']['temp'].toString();
          _weatherDescription = data['weather'][0]['description'];
          _humidity = data['main']['humidity'].toString();
          _windSpeed = data['wind']['speed'].toString();
          _city = data['name'];
        });
      } else {
        setState(() {
          _error = 'Failed to fetch weather data for this location.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch data. Please check your internet connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter City',
                hintText: 'e.g. Chennai',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _city = value; 
                  });
                  _fetchWeatherData(value); 
                }
              },
            ),
            SizedBox(height: 20),

           
            if (_error.isNotEmpty)
              Text(
                _error,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (_error.isEmpty) ...[
             
              Text(
                'City: $_city',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

            
              Text(
                'Temperature: $_temperature°C',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Description: $_weatherDescription',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Humidity: $_humidity%',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Wind Speed: $_windSpeed m/s',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _getCurrentLocation,
                  child: Text('Get Weather for My Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

