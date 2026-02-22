import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/sensor_data.dart';

class ApiService {
  static Future<SensorData> fetchLatestData() async {
    // Verifica si dotenv se cargó
    if (dotenv.env.isEmpty) {
      throw Exception("dotenv no cargado. Verifica main.dart");
    }

    final channelId = dotenv.env['THINGSPEAK_CHANNEL_ID'] ?? '';
    final readKey = dotenv.env['THINGSPEAK_READ_KEY'] ?? '';

    if (channelId.isEmpty || readKey.isEmpty) {
      throw Exception("Claves de ThingSpeak no encontradas en .env");
    }

    final url =
        "https://api.thingspeak.com/channels/$channelId/feeds/last.json?api_key=$readKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception(
        "Error ThingSpeak: ${response.statusCode} - ${response.body}",
      );
    }

    final json = jsonDecode(response.body);
    return SensorData.fromThingSpeak(json);
  }
}
