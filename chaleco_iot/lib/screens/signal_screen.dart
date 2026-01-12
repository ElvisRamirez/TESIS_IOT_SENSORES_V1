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
      duration: const Duration(seconds: 4),
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
      backgroundColor: const Color(0xFF121212),
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

                  // RADAR TÁCTICO (cambia color según nivel de señal)
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getSignalColor(
                          data!.signalLevel,
                        ).withOpacity(0.6),
                        width: 3,
                      ),
                    ),
                    child: AnimatedBuilder(
                      animation: _radarController,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: _RadarPainter(
                            angle: _radarController.value * 2 * pi,
                            signalLevel: data!.signalLevel,
                            rssi: data!.rssi,
                          ),
                          child: Container(),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  // CÁPSULA DE ESTADO (cambia color y texto según nivel)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                    decoration: BoxDecoration(
                      color: _getSignalColor(
                        data!.signalLevel,
                      ).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _getSignalColor(data!.signalLevel),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      _getSignalText(data!.signalLevel),
                      style: TextStyle(
                        color: _getSignalColor(data!.signalLevel),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // DATOS TÉCNICOS (con color según nivel)
                  _infoRow(
                    "RSSI",
                    "${data!.rssi} dBm",
                    _getSignalColor(data!.signalLevel),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= HELPERS (colores y texto según nivel 1-5) =================
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
        return Colors.greenAccent.shade400; // Verde brillante
      case 4:
        return Colors.green.shade600; // Verde fuerte
      case 3:
        return Colors.orangeAccent.shade400; // Naranja vivo
      case 2:
        return Colors.orange.shade700; // Naranja oscuro
      case 1:
        return Colors.redAccent.shade700; // Rojo intenso
      default:
        return Colors.grey.shade600;
    }
  }

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
}

// ================= RADAR PAINTER (cambia color y posición según nivel) =================
class _RadarPainter extends CustomPainter {
  final double angle;
  final int signalLevel;
  final int rssi;

  _RadarPainter({
    required this.angle,
    required this.signalLevel,
    required this.rssi,
  });

  // Función interna de colores (para que funcione dentro de la clase)
  Color _getRadarColor() {
    switch (signalLevel) {
      case 5:
        return Colors.greenAccent.shade400;
      case 4:
        return Colors.green.shade600;
      case 3:
        return Colors.orangeAccent.shade400;
      case 2:
        return Colors.orange.shade700;
      case 1:
        return Colors.redAccent.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = min(size.width, size.height) / 2 - 20;

    // Círculos concéntricos (con color del nivel)
    final circlePaint = Paint()
      ..color = _getRadarColor().withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, circlePaint);
    }

    // Líneas radiales (con color del nivel)
    final linePaint = Paint()
      ..color = _getRadarColor().withOpacity(0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 12; i++) {
      double radAngle = i * pi / 6;
      canvas.drawLine(
        center,
        center + Offset(maxRadius * cos(radAngle), maxRadius * sin(radAngle)),
        linePaint,
      );
    }

    // Barrido del radar (cambia color según nivel)
    final sweepPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          _getRadarColor().withOpacity(0.5),
          _getRadarColor().withOpacity(0.0),
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

    // Punto del objetivo (posición y color según nivel)
    final dotPaint = Paint()
      ..color = _getRadarColor()
      ..style = PaintingStyle.fill;

    // Distancia simbólica: nivel alto = punto cerca del centro, nivel bajo = lejos
    final dotRadius = maxRadius * (1 - (signalLevel / 5.0)); // Inverso

    final dotPosition =
        center + Offset(dotRadius * cos(angle), dotRadius * sin(angle));

    canvas.drawCircle(dotPosition, 10, dotPaint);

    canvas.drawCircle(
      dotPosition,
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
