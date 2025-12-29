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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Fondo oscuro militar
      appBar: AppBar(
        title: const Text('MONITOREO CARDÍACO'),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 1.2,
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
                  // ICONO CORAZÓN TÁCTICO
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pulseColor(data!.pulse).withOpacity(0.2),
                      border: Border.all(
                        color: _pulseColor(data!.pulse),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite,
                      size: 100,
                      color: _pulseColor(data!.pulse),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BPM GRANDE Y PROFESIONAL
                  Text(
                    "${_convertToBPM(data!.pulse!)}",
                    style: const TextStyle(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),

                  const Text(
                    "BPM",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ESTADO CARDÍACO
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _pulseColor(data!.pulse).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _pulseColor(data!.pulse),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      _pulseStatus(data!.pulse),
                      style: TextStyle(
                        color: _pulseColor(data!.pulse),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TÍTULO ÚLTIMAS LECTURAS
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "HISTORIAL RECIENTE",
                      style: TextStyle(
                        color: Colors.redAccent,
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

                  // LISTA DE ÚLTIMAS LECTURAS
                  Expanded(
                    child: ListView.builder(
                      itemCount: lastPulse.length,
                      itemBuilder: (_, i) {
                        int bpm = _convertToBPM(lastPulse[i]);
                        return Card(
                          color: const Color(0xFF1E1E1E),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white10),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.favorite,
                              color: _pulseColor(lastPulse[i]),
                              size: 30,
                            ),
                            title: Text(
                              "$bpm BPM",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
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

  // ================= UTILIDADES =================
  Color _pulseColor(int p) {
    int bpm = _convertToBPM(p);
    if (bpm < 50) return Colors.blueAccent;
    if (bpm < 100) return Colors.greenAccent;
    if (bpm < 120) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _pulseStatus(int p) {
    int bpm = _convertToBPM(p);
    if (bpm < 50) return "BRADICARDIA";
    if (bpm < 100) return "NORMAL";
    if (bpm < 120) return "TAQUICARDIA LEVE";
    return "TAQUICARDIA - ALERTA";
  }

  int _convertToBPM(int raw) {
    // Ajusta esta fórmula según calibración real del sensor en pecho
    return (raw / 32).toInt();
  }
}
