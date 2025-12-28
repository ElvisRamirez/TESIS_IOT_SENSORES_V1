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

    return SensorData.fromThingSpeak(json);
  }
}
