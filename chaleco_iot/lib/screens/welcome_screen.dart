import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart'; // Asegúrate de que este import esté correcto
import '../services/api_service.dart'; // ← Importamos tu ApiService

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  bool isSignalReady = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Inicia chequeo de señal usando ApiService
    _checkSignalWithApi();
    _checkTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkSignalWithApi(),
    );
  }

  Future<void> _checkSignalWithApi() async {
    try {
      final sensorData = await ApiService.fetchLatestData();

      // Si llegamos aquí, hay datos válidos en ThingSpeak
      // Puedes mejorar esto si agregas timestamp en SensorData
      setState(() {
        isSignalReady = true;
      });

      // Deja de chequear una vez que el sistema está listo
      _checkTimer?.cancel();
    } catch (e) {
      debugPrint("Error chequeando señal: $e");
      // Si falla → sigue esperando
      setState(() {
        isSignalReady = false;
      });
    }
  }

  void _enterSystem() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      body: FadeTransition(
        opacity: _fade,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ===== EMBLEMA TÁCTICO =====
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.security,
                    size: 90,
                    color: Colors.greenAccent,
                  ),
                ),

                const SizedBox(height: 30),

                // ===== TITULO =====
                const Text(
                  "SISTEMA TÁCTICO IoT",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "MONITOREO FISIOLÓGICO • TRANSMISIÓN LoRa",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ===== ESTADO DEL SISTEMA (dinámico) =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSignalReady ? Icons.check_circle : Icons.pending,
                      size: 12,
                      color: isSignalReady
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isSignalReady
                          ? "SISTEMA LISTO"
                          : "ESPERANDO SEÑAL LoRa...",
                      style: TextStyle(
                        color: isSignalReady
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 14,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                // ===== BOTÓN ENTRADA (solo activo cuando hay señal) =====
                GestureDetector(
                  onTap: isSignalReady ? _enterSystem : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSignalReady
                          ? Colors.greenAccent
                          : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSignalReady ? Colors.greenAccent : Colors.grey,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      isSignalReady ? "INGRESAR" : "ESPERANDO SEÑAL...",
                      style: TextStyle(
                        color: isSignalReady ? Colors.black : Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
