import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';
import 'temperature_screen.dart';
import 'motion_screen.dart';

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
      debugPrint("ThingSpeak error: $e");
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
            padding: const EdgeInsets.all(16),
            child: data == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TACTICAL IOT VEST",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "RSSI ${data!.rssi} dBm | Dist ${data!.distance.toStringAsFixed(0)} m",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 30),

                      // TEMPERATURA
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

                      const SizedBox(height: 20),

                      // MOVIMIENTO
                      _card(
                        icon: Icons.directions_run,
                        title: "Magnitud de Movimiento",
                        value: data!.mag.toStringAsFixed(2),
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

                      const SizedBox(height: 20),

                      // ESTADO / ACTIVIDAD
                      _card(
                        icon: Icons.security,
                        title: "Estado de Actividad",
                        value: data!.activity == 0
                            ? "REPOSO"
                            : data!.activity == 1
                            ? "NORMAL"
                            : data!.activity == 2
                            ? "ACTIVO"
                            : "ALERTA",
                        color: data!.activity == 3
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        onTap: () {},
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
        height: 130,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF151A21),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 34, color: color),
            ),
            const SizedBox(width: 20),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
