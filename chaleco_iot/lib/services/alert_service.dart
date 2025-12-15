import 'notification_service.dart';
import '../models/sensor_data.dart';

class AlertService {
  static void checkAnomalies(SensorData data) {
    if (data.temp > 40) {
      NotificationService.showNotification(
        "Alerta Temperatura",
        "Temperatura crítica: ${data.temp}°C",
      );
    }
    if (data.mag > 20) {
      NotificationService.showNotification(
        "Alerta Movimiento",
        "Impacto detectado",
      );
    }
  }
}
