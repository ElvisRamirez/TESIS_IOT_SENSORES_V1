import 'dart:async';
import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/api_service.dart';

class PulseScreen extends StatefulWidget {
  const PulseScreen({super.key});

  @override
  State<PulseScreen> createState() => _PulseScreenState();
}

class _PulseScreenState extends State<PulseScreen> {
  SensorData? data;
  Timer? timer;

  final List<int> lastPulse = [];

  @override
  void initState() {
    super.initState();
    _fetchData();

    timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final result = await ApiService.fetchLatestData();

      if (result.pulse != null) {
        lastPulse.insert(0, result.pulse!.round());
        if (lastPulse.length > 5) lastPulse.removeLast();
      }

      setState(() => data = result);
    } catch (e) {
      debugPrint("Error pulso: $e");
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
        title: const Text('Pulso Cardíaco'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: data == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ICONO CORAZÓN
                  Icon(
                    Icons.favorite,
                    size: 90,
                    color: _pulseColor(data!.pulse),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${_convertToBPM(data!.pulse!)} BPM",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.bold,
                      color: _pulseColor(data!.pulse),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _pulseStatus(data!.pulse),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Últimas lecturas",
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: ListView.builder(
                      itemCount: lastPulse.length,
                      itemBuilder: (_, i) {
                        return ListTile(
                          leading: const Icon(
                            Icons.favorite,
                            color: Colors.pinkAccent,
                          ),
                          title: Text(
                            "${_convertToBPM(lastPulse[i])} BPM",
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
  Color _pulseColor(int? p) {
    if (p == null) return Colors.grey;
    int bpm = _convertToBPM(p);
    if (bpm < 50) return Colors.blueAccent;
    if (bpm < 100) return Colors.greenAccent;
    if (bpm < 120) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _pulseStatus(int? p) {
    if (p == null) return "Sensor no conectado";
    int bpm = _convertToBPM(p);
    if (bpm < 50) return "Pulso bajo";
    if (bpm < 100) return "Normal";
    if (bpm < 120) return "Elevado";
    return "ALERTA CARDÍACA";
  }

  // Conversión a BPM - Calibrada según datos (ajusta con más puntos para precisión)
  int _convertToBPM(int raw) {
    // Provisional: basado en raw=1992 → BPM=60 (tranquilo)
    // Para calibración real, usa interpolación lineal con más datos
    // Ejemplo: si tienes raw1=1917 (BPM1=60), raw2=X (BPM2=Y), calcula pendiente
    double factor = 1992 / 60.0; // ~31.95
    return (raw / factor).round();
  }
}
