import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../widgets/battery_bar.dart';

class TemperatureScreen extends StatelessWidget {
  final SensorData data;
  TemperatureScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperatura y Batería'),
        backgroundColor: Colors.red[400],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Temperatura: ${data.temp} °C',
            style: TextStyle(fontSize: 32, color: Colors.red),
          ),
          SizedBox(height: 40),
          BatteryBar(percentage: data.batteryPct),
        ],
      ),
    );
  }
}
