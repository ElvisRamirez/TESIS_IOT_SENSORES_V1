import 'package:flutter/material.dart';
import '../models/sensor_data.dart';

class TemperatureScreen extends StatelessWidget {
  final SensorData data;

  const TemperatureScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text(
          'Temperatura Corporal',
          style: TextStyle(letterSpacing: 1.2),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF151A21),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.monitor_heart,
                color: Colors.redAccent,
                size: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                "TEMPERATURA ACTUAL",
                style: TextStyle(color: Colors.white70, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              Text(
                "${data.temp.toStringAsFixed(1)} °C",
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                data.temp >= 38
                    ? "⚠ ALERTA: TEMPERATURA ALTA"
                    : "ESTADO NORMAL",
                style: TextStyle(
                  color: data.temp >= 38
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
