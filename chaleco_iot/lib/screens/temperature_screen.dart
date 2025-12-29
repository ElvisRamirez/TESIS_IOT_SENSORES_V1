import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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

  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    data = widget.data;
    lastTemp = widget.data.temp;
    lastTemps.add(widget.data.temp);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fetchData();
    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();
      final temp = result.temp;

      if (lastTemp != null && (temp - lastTemp!).abs() >= 1.5) {
        _sendNotification(temp);
      }

      lastTemp = temp;

      lastTemps.insert(0, temp);
      if (lastTemps.length > 5) lastTemps.removeLast();

      setState(() => data = result);
    } catch (e) {
      debugPrint("Error temperatura: $e");
    }
  }

  void _sendNotification(double temp) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chaleco_channel',
        title: '⚠️ ALERTA TÉRMICA',
        body: 'Cambio brusco detectado: ${temp.toStringAsFixed(1)} °C',
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro táctico
      appBar: AppBar(
        title: const Text('MONITOREO TÉRMICO'),
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
                color: Colors.redAccent,
                strokeWidth: 5,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ===== BLOQUE PRINCIPAL =====
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _tempColor(data!.temp).withOpacity(0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _tempColor(data!.temp).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Icon(
                            Icons.thermostat,
                            size: 100,
                            color: _tempColor(data!.temp),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${data!.temp.toStringAsFixed(1)} °C",
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            color: _tempColor(data!.temp),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tempStatus(data!.temp),
                          style: TextStyle(
                            color: _tempColor(data!.temp),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sensor Biométrico – Zona Cervical",
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== HISTORIAL =====
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "HISTORIAL TÉRMICO (últimos 5)",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ===== MINI GRÁFICA CON NÚMEROS =====
                  SizedBox(
                    height: 140,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          verticalInterval: 5,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: Colors.white10, strokeWidth: 1),
                          getDrawingVerticalLine: (value) =>
                              FlLine(color: Colors.white10, strokeWidth: 1),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) => Text(
                                '${(5 - value.toInt())}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}°C',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.white12),
                        ),
                        minX: 0,
                        maxX: 4,
                        minY: 25,
                        maxY: 45,
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(
                              lastTemps.length,
                              (i) => FlSpot(
                                (lastTemps.length - 1 - i).toDouble(),
                                lastTemps[i],
                              ),
                            ),
                            isCurved: true,
                            curveSmoothness: 0.4,
                            color: Colors.redAccent,
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                    radius: 5,
                                    color: Colors.redAccent,
                                    strokeColor: Colors.white,
                                    strokeWidth: 2,
                                  ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.redAccent.withOpacity(0.25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ================= UTILIDADES (sin cambios) =================
  Color _tempColor(double t) {
    if (t < 28) return Colors.blueAccent;
    if (t < 36) return Colors.greenAccent;
    if (t < 38) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _tempStatus(double t) {
    if (t < 28) return "HIPOTERMIA";
    if (t < 36) return "ESTABLE";
    if (t < 38) return "SOBRECARGA TÉRMICA";
    return "RIESGO CRÍTICO";
  }
}
