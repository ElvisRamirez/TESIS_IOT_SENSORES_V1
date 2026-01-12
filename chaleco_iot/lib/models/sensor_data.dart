class SensorData {
  final double temp; // field1 - Temperatura
  final int pulse; // field2 - Pulso óptico
  final double mag; // field3 - Magnitud movimiento
  final double ax; // field4 - Aceleración X
  final double ay; // field5 - Aceleración Y
  final double az; // field6 - Aceleración Z
  final int rssi; // field7 - RSSI LoRa
  final int signalLevel; // field8 - Distancia estimada

  SensorData({
    required this.temp,
    required this.pulse,
    required this.mag,
    required this.ax,
    required this.ay,
    required this.az,
    required this.rssi,
    required this.signalLevel,
  });

  /// Útil si luego lees JSON directamente
  factory SensorData.fromThingSpeak(Map<String, dynamic> json) {
    return SensorData(
      temp: double.tryParse(json['field1'] ?? '0') ?? 0,
      pulse: int.tryParse(json['field2'] ?? '0') ?? 0,
      mag: double.tryParse(json['field3'] ?? '0') ?? 0,
      ax: double.tryParse(json['field4'] ?? '0') ?? 0,
      ay: double.tryParse(json['field5'] ?? '0') ?? 0,
      az: double.tryParse(json['field6'] ?? '0') ?? 0,
      rssi: int.tryParse(json['field7'] ?? '-120') ?? -120,
      signalLevel: int.tryParse(json['field8'] ?? '0') ?? 0,
    );
  }
}
