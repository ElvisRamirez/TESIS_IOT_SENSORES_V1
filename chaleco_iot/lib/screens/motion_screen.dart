import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/sensor_data.dart';

class MotionScreen extends StatelessWidget {
  final SensorData data; // <-- agregamos este parámetro

  MotionScreen({required this.data}); // <-- constructor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movimiento'),
        backgroundColor: Colors.blue[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/person_movement.json',
            ), // archivo Lottie que simula movimiento
            SizedBox(height: 20),
            Text(
              'Magnitud movimiento: ${data.mag.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, color: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }
}
