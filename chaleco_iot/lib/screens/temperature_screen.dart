import 'dart:async';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/api_service.dart';
import '../models/sensor_data.dart';

class TemperatureScreen extends StatefulWidget {
  final SensorData data;

  const TemperatureScreen({super.key, required this.data});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen>
    with SingleTickerProviderStateMixin {
  SensorData? data;
  Timer? timer;

  final List<double> lastTemps = [];
  double? lastTemp;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAlert = false;

  DateTime? _calibrationStart;
  bool _calibrationAlertSent = false;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    lastTemp = widget.data.temp;
    lastTemps.add(widget.data.temp);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _fetchData();

    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  // ================= DATOS =================
  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      final temp = result.temp;

      // Detectar cambio brusco
      if (lastTemp != null && (temp - lastTemp!).abs() >= 1.5) {
        _sendNotification(temp);
        _triggerAlertAnimation();
      }

      // Manejar calibración
      if (temp < 25 || temp > 45) {
        if (_calibrationStart == null) {
          _calibrationStart = DateTime.now();
          _calibrationAlertSent = false;
        } else if (DateTime.now().difference(_calibrationStart!).inMinutes >=
                5 &&
            !_calibrationAlertSent) {
          _sendCalibrationAlert(temp);
          _calibrationAlertSent = true;
        }
      } else {
        _calibrationStart = null;
        _calibrationAlertSent = false;
      }

      lastTemp = temp;

      // Guardar últimos 5 valores
      lastTemps.insert(0, temp);
      if (lastTemps.length > 5) lastTemps.removeLast();

      setState(() => data = result);
    } catch (e) {
      debugPrint("Error temperatura: $e");
    }
  }

  void _triggerAlertAnimation() {
    _animationController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 3), () {
      _animationController.stop();
      _animationController.reset();
    });
  }

  void _sendNotification(double temp) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chaleco_channel',
        title: '⚠️ Cambio brusco de temperatura',
        body: 'Temperatura actual: ${temp.toStringAsFixed(1)} °C',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  void _sendCalibrationAlert(double temp) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1,
        channelKey: 'chaleco_channel',
        title: '⚠️ Alerta de Calibración',
        body:
            'Temperatura fuera de rango por más de 5 minutos: ${temp.toStringAsFixed(1)} °C. Verificar sensor.',
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E11),
      appBar: AppBar(
        title: const Text('Temperatura en Cuello'),
        backgroundColor: Colors.redAccent,
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ICONO PERSONA
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      Icons.accessibility_new,
                      size: 90,
                      color: _tempColor(data!.temp),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${data!.temp.toStringAsFixed(1)} °C",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: _tempColor(data!.temp),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _tempStatus(data!.temp),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Sensor LM35 en cuello",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Últimas lecturas",
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: lastTemps.length,
                      itemBuilder: (_, i) {
                        return ListTile(
                          leading: const Icon(
                            Icons.thermostat,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            "${lastTemps[i].toStringAsFixed(1)} °C",
                            style: const TextStyle(color: Colors.white),
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

  // ================= UTILIDADES =================
  Color _tempColor(double t) {
    if (t < 25 || t > 45) return Colors.yellow; // Calibración de sensor
    if (t < 28) return Colors.blue[900]!; // Hipotermia severa
    if (t < 30) return Colors.blueAccent;
    if (t < 36) return Colors.greenAccent;
    if (t < 38) return Colors.orangeAccent;
    if (t > 40) return Colors.red[900]!; // Ola de calor extrema
    if (t > 38) return Colors.redAccent;
    return Colors.greenAccent;
  }

  String _tempStatus(double t) {
    if (t < 25 || t > 45) return "Calibración de Sensor";
    if (t < 28) return "Hipotermia Severa";
    if (t < 30) return "Hipotermia";
    if (t > 40) return "Ola de Calor Extrema";
    if (t > 38) return "Ola de Calor";
    return "Normal";
  }
}
