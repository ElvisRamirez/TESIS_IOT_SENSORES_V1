import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import 'temperature_screen.dart';
import 'motion_screen.dart';
import 'pulse_screen.dart';
import 'signal_screen.dart';

String _getSignalText(int level) {
  switch (level) {
    case 5:
      return "MUY CERCA";
    case 4:
      return "CERCA";
    case 3:
      return "MEDIA";
    case 2:
      return "LEJOS";
    case 1:
      return "MUY LEJOS";
    default:
      return "SIN SEÑAL";
  }
}

Color _getSignalColor(int level) {
  switch (level) {
    case 5:
      return Colors.greenAccent;
    case 4:
      return Colors.green;
    case 3:
      return Colors.orangeAccent;
    case 2:
      return Colors.orange;
    case 1:
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  SensorData? data;
  Timer? timer;

  late AnimationController _controller;
  late Animation<double> _fade;

  int _convertToBPM(int raw) => (raw / 32).toInt();
  bool _detectMovement(double mag) => mag > 0.14;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    fetchData();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      setState(() => data = result);
    } catch (e) {
      debugPrint("Dashboard error: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: data == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== HEADER =====
                      const Text(
                        "CENTRO DE CONTROL",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Estados y enlace LoRa",
                        style: TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 28),

                      // ===== TEMPERATURA =====
                      _card(
                        icon: Icons.monitor_heart,
                        title: "Temperatura Corporal",
                        value: "${data!.temp.toStringAsFixed(1)} °C",
                        color: Colors.redAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TemperatureScreen(data: data!),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ===== PULSO =====
                      _card(
                        icon: Icons.favorite,
                        title: "Pulso Cardíaco",
                        value: "${_convertToBPM(data!.pulse).toString()} BPM",
                        color: Colors.pinkAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PulseScreen()),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ===== MOVIMIENTO =====
                      _card(
                        icon: Icons.directions_run,
                        title: "Estado de Movimiento",
                        value: _detectMovement(data!.mag)
                            ? "UNIDAD EN MOVIMIENTO"
                            : "UNIDAD ESTÁTICA",
                        color: Colors.orangeAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MotionScreen(data: data!),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ===== LORA =====
                      _card(
                        icon: Icons.wifi_tethering,
                        title: "Enlace LoRa",
                        value:
                            _getSignalText(data!.signalLevel) +
                            "\nRSSI: ${data!.rssi} dBm",
                        color: _getSignalColor(data!.signalLevel),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignalScreen()),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 135,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF151A21),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 34, color: color),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
