import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  static const String channelId = "3202744";
  static const String readKey = "D8CS8L02VP13LDA1";

  static Future<SensorData> fetchLatestData() async {
    final url =
        "https://api.thingspeak.com/channels/$channelId/feeds/last.json?api_key=$readKey";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception("Error ThingSpeak");
    }

    final json = jsonDecode(response.body);

    return SensorData(
      temp: double.tryParse(json['field1'] ?? '0') ?? 0,
      mag: double.tryParse(json['field2'] ?? '0') ?? 0,
      rssi: int.tryParse(json['field3'] ?? '-120') ?? -120,
      distance: double.tryParse(json['field4'] ?? '0') ?? 0,
      activity: int.tryParse(json['field5'] ?? '0') ?? 0,
      x: double.tryParse(json['field6'] ?? '0') ?? 0,
      y: double.tryParse(json['field7'] ?? '0') ?? 0,
      z: double.tryParse(json['field8'] ?? '0') ?? 0,
    );
  }
}
