import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import OBLIGATORIO
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga .env PRIMERO y ESPERA a que termine
  try {
    await dotenv.load(fileName: ".env");
    print('dotenv cargado correctamente');
    print('Channel ID: ${dotenv.env['THINGSPEAK_CHANNEL_ID']}');
    print('Read Key: ${dotenv.env['THINGSPEAK_READ_KEY']}');
  } catch (e) {
    print('Error al cargar .env: $e');
  }

  // Bloquea orientación vertical
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

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
      home: const WelcomeScreen(),
    );
  }
}
