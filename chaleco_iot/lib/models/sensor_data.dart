class SensorData {
  final double temp;
  final double x;
  final double y;
  final double z;
  final double mag;
  final double batV;
  final int batteryPct;
  final double? pulse; // FUTURO

  SensorData({
    this.temp = 0.0,
    this.x = 0.0,
    this.y = 0.0,
    this.z = 0.0,
    this.mag = 0.0,
    this.batV = 0.0,
    this.batteryPct = 0,
    this.pulse = 0.0,
  });
}
