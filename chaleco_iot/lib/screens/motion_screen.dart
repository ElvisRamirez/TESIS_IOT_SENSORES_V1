import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class MotionScreen extends StatefulWidget {
  final SensorData data;

  const MotionScreen({super.key, required this.data});

  @override
  State<MotionScreen> createState() => _MotionScreenState();
}

class _MotionScreenState extends State<MotionScreen> {
  SensorData? data;
  Timer? timer;

  String posture = "Desconocido";
  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _updateStatus();

    _fetchData();

    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      setState(() => data = result);
      _updateStatus();
    } catch (e) {
      debugPrint("Error motion: $e");
    }
  }

  void _updateStatus() {
    if (data != null) {
      posture = _detectPosture(data!.ax, data!.ay, data!.az);
      isMoving = _detectMovement(data!.mag);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Magnitud de Movimiento'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ICONO SEGÚN POSTURA
                  Icon(
                    _getPostureIcon(posture),
                    size: 90,
                    color: isMoving ? Colors.redAccent : Colors.orangeAccent,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Magnitud: ${data!.mag.toStringAsFixed(2)} g",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Postura: $posture",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    isMoving ? "En movimiento" : "Quieto",
                    style: TextStyle(
                      color: isMoving ? Colors.redAccent : Colors.greenAccent,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Datos del ADXL335",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  _dataRow("Ax", data!.ax),
                  _dataRow("Ay", data!.ay),
                  _dataRow("Az", data!.az),
                  _dataRow("Mag", data!.mag),
                ],
              ),
            ),
    );
  }

  Widget _dataRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(color: Colors.white70)),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ================= UTILIDADES =================
  String _detectPosture(double ax, double ay, double az) {
    // Asumiendo valores normalizados a g (9.81 m/s² ≈ 1)
    if (az.abs() > 0.8) {
      return az > 0 ? "Boca arriba" : "Boca abajo";
    } else if (ay.abs() > 0.8) {
      return "De pie";
    } else if (ax.abs() > 0.8) {
      return "De lado";
    } else {
      return "Sentado";
    }
  }

  bool _detectMovement(double mag) {
    // Si magnitud fuera de 0.9-1.1 g, considera movimiento
    return mag < 0.9 || mag > 1.1;
  }

  IconData _getPostureIcon(String posture) {
    switch (posture) {
      case "De pie":
        return Icons.accessibility;
      case "Sentado":
        return Icons.airline_seat_recline_normal;
      case "Boca arriba":
        return Icons.bed;
      case "Boca abajo":
        return Icons.bedtime;
      case "De lado":
        return Icons.account_circle;
      default:
        return Icons.help;
    }
  }
}
