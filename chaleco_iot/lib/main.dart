import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ← Importa esto (necesario para bloquear orientación)
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bloquea la orientación SOLO a vertical normal (no gira, no se pone al revés)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo vertical estándar
  ]);

  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chaleco IoT Militar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: WelcomeScreen(),
    );
  }
}
