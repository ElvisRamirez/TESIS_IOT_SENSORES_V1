import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/temperature_screen.dart';
import '../screens/motion_screen.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import '../services/alert_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SensorData latestData = SensorData(
    temp: 0,
    x: 0,
    y: 0,
    z: 0,
    mag: 0,
    batV: 0,
  );

  @override
  void initState() {
    super.initState();
    fetchDataPeriodically();
  }

  void fetchDataPeriodically() {
    fetchData();
    Timer.periodic(Duration(seconds: 15), (_) => fetchData());
  }

  void fetchData() async {
    try {
      final data = await ApiService.fetchLatestData();
      AlertService.checkAnomalies(data);
      setState(() {
        latestData = data;
      });
    } catch (e) {
      print("Error al obtener datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Chaleco IoT'),
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TemperatureScreen(data: latestData),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.red[400],
                      margin: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'Temperatura',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MotionScreen(data: latestData),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.blue[400],
                      margin: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          'Movimiento',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Temperatura: ${latestData.temp.toStringAsFixed(1)} °C',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  'Batería: ${latestData.batV} V',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 8),
                Text(
                  'Magnitud movimiento: ${latestData.mag.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
