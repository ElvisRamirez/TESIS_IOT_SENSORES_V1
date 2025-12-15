import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class ApiService {
  static Future<SensorData> fetchLatestData() async {
    final response = await http.get(
      Uri.parse(
        'https://api.thingspeak.com/channels/3202744/fields/1.json?api_key=D8CS8L02VP13LDA1&results=2',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final feeds = jsonData['feeds'];

      if (feeds != null && feeds.length > 0) {
        final feed = feeds[0];
        return SensorData(
          temp: double.tryParse(feed['field1'] ?? '0') ?? 0,
          x: double.tryParse(feed['field2'] ?? '0') ?? 0,
          y: double.tryParse(feed['field3'] ?? '0') ?? 0,
          z: double.tryParse(feed['field4'] ?? '0') ?? 0,
          mag: double.tryParse(feed['field5'] ?? '0') ?? 0,
          batV: double.tryParse(feed['field6'] ?? '0') ?? 0,
          batteryPct: int.tryParse(feed['field7'] ?? '0') ?? 0,
        );
      }
    }

    throw Exception("Error al obtener datos de ThingSpeak");
  }
}
