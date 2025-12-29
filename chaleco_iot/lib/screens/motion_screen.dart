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

  String posture = "DESCONOCIDO";
  bool isMoving = false;

  final List<String> lastPostures = [];

  @override
  void initState() {
    super.initState();
    data = widget.data;
    _updateStatus();
    lastPostures.add("${posture} - ${isMoving ? 'EN MOVIMIENTO' : 'ESTÁTICO'}");

    _fetchData();

    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      setState(() {
        data = result;
      });
      _updateStatus();
      lastPostures.insert(
        0,
        "${posture} - ${isMoving ? 'EN MOVIMIENTO' : 'ESTÁTICO'}",
      );
      if (lastPostures.length > 5) lastPostures.removeLast();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('CONTROL POSTURAL Y MOVIMIENTO'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.5,
        ),
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
                strokeWidth: 5,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ICONO MILITAR
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isMoving ? Colors.redAccent : Colors.greenAccent)
                          .withOpacity(0.2),
                      border: Border.all(
                        color: isMoving ? Colors.redAccent : Colors.greenAccent,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _getPostureIcon(posture),
                      size: 80,
                      color: isMoving ? Colors.redAccent : Colors.greenAccent,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // MAGNITUD
                  Text(
                    "${data!.mag.toStringAsFixed(3)} g",
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const Text(
                    "MAGNITUD ACELERACIÓN",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ESTADO MOVIMIENTO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: (isMoving ? Colors.redAccent : Colors.greenAccent)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isMoving ? Colors.redAccent : Colors.greenAccent,
                        width: 3,
                      ),
                    ),
                    child: Text(
                      isMoving ? "EN MOVIMIENTO" : "ESTÁTICO",
                      style: TextStyle(
                        color: isMoving ? Colors.redAccent : Colors.greenAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // POSTURA ACTUAL
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.orangeAccent, width: 2),
                    ),
                    child: Text(
                      "POSTURA: $posture",
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // HISTORIAL
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "REGISTRO DE ACTIVIDAD",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const Divider(
                    color: Colors.white24,
                    thickness: 1,
                    height: 20,
                  ),

                  // LISTA HISTORIAL
                  Expanded(
                    child: ListView.builder(
                      itemCount: lastPostures.length,
                      itemBuilder: (_, i) {
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.white10),
                          ),
                          child: ListTile(
                            leading: Icon(
                              _getPostureIcon(lastPostures[i].split(' - ')[0]),
                              color: Colors.greenAccent,
                              size: 32,
                            ),
                            title: Text(
                              lastPostures[i],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              "#${i + 1}",
                              style: const TextStyle(color: Colors.white54),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= DETECCIÓN FINAL CALIBRADA A TUS DATOS REALES =================
  String _detectPosture(double ax, double ay, double az) {
    // PRONO (boca abajo): Z negativo claro (tus datos -0.116 a -0.120)
    if (az < -0.08) {
      return "PRONO";
    }
    // SUPINO (boca arriba): Z positivo claro
    else if (az > 0.08) {
      return "SUPINO";
    }
    // EN CUCLILLAS: Z negativo moderado + X positivo
    else if (ax > 0.08 && az < -0.04 && az > -0.15) {
      return "EN CUCLILLAS";
    }
    // ERGUIDO (de pie/caminando): X positivo
    else if (ax > 0.06) {
      return "ERGUIDO";
    }
    // SEDENTE (sentado): resto
    else {
      return "SEDENTE";
    }
  }

  bool _detectMovement(double mag) {
    // Más sensible para detectar pequeños movimientos (respiración, ajustes)
    return mag > 0.13;
  }

  IconData _getPostureIcon(String posture) {
    switch (posture) {
      case "ERGUIDO":
        return Icons.straighten;
      case "SEDENTE":
        return Icons.event_seat;
      case "SUPINO":
        return Icons.airline_seat_flat;
      case "PRONO":
        return Icons.airline_seat_flat_angled;
      case "EN CUCLILLAS":
        return Icons.airline_seat_individual_suite;
      default:
        return Icons.help_outline;
    }
  }
}
