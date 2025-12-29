import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../models/sensor_data.dart';
import '../services/api_service.dart';

class SignalScreen extends StatefulWidget {
  const SignalScreen({super.key});

  @override
  State<SignalScreen> createState() => _SignalScreenState();
}

class _SignalScreenState extends State<SignalScreen>
    with SingleTickerProviderStateMixin {
  SensorData? data;
  Timer? timer;

  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 4,
      ), // Un poco más lento para efecto táctico
    )..repeat();

    _fetchData();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      setState(() => data = result);
    } catch (_) {}
  }

  @override
  void dispose() {
    timer?.cancel();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro militar
      appBar: AppBar(
        title: const Text('ENLACE LoRa'),
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
                  const SizedBox(height: 20),

                  // ===== RADAR TÁCTICO =====
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _radarController,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: _RadarPainter(
                            angle: _radarController.value * 2 * pi,
                            distance: data!.distance,
                            rssi: data!.rssi,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== ESTADO DE SEÑAL EN CÁPSULA =====
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: _signalColor(data!.rssi).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _signalColor(data!.rssi),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      _signalStatus(data!.rssi),
                      style: TextStyle(
                        color: _signalColor(data!.rssi),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ===== DATOS TÉCNICOS =====
                  _infoRow(
                    "RSSI",
                    "${data!.rssi} dBm",
                    _signalColor(data!.rssi),
                  ),
                  _infoRow(
                    "Distancia estimada",
                    "${data!.distance.toStringAsFixed(0)} m",
                    Colors.greenAccent,
                  ),
                ],
              ),
            ),
    );
  }

  // ================= COMPONENTES =================
  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _signalColor(int rssi) {
    if (rssi > -70) return Colors.greenAccent;
    if (rssi > -90) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _signalStatus(int rssi) {
    if (rssi > -70) return "SEÑAL FUERTE";
    if (rssi > -90) return "SEÑAL MEDIA";
    return "SEÑAL DÉBIL";
  }
}

// ================= RADAR PAINTER (mejorado visualmente) =================
class _RadarPainter extends CustomPainter {
  final double angle;
  final double distance;
  final int rssi;

  _RadarPainter({
    required this.angle,
    required this.distance,
    required this.rssi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2 - 20;

    // Círculos concéntricos (más sutiles)
    final circlePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, circlePaint);
    }

    // Líneas radiales (para efecto radar táctico)
    final linePaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      double radAngle = i * pi / 6;
      canvas.drawLine(
        center,
        center + Offset(maxRadius * cos(radAngle), maxRadius * sin(radAngle)),
        linePaint,
      );
    }

    // Barrido del radar (más ancho y con gradiente)
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.greenAccent.withOpacity(0.4),
          Colors.greenAccent.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: maxRadius),
      angle - pi / 6,
      pi / 3,
      true,
      sweepPaint,
    );

    // Punto del objetivo (emisor)
    final dotPaint = Paint()
      ..color = rssi > -80
          ? Colors.greenAccent
          : rssi > -100
          ? Colors.orangeAccent
          : Colors.redAccent
      ..style = PaintingStyle.fill;

    final dotRadius =
        maxRadius * (distance / 12000).clamp(0.0, 1.0); // Escala hasta 12 km

    canvas.drawCircle(
      center + Offset(dotRadius * cos(angle), dotRadius * sin(angle)),
      10,
      dotPaint..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      center + Offset(dotRadius * cos(angle), dotRadius * sin(angle)),
      10,
      Paint()
        ..color = dotPaint.color.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
