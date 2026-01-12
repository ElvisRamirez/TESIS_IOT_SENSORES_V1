import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart'; // ← Añadido para Colors
import '../models/sensor_data.dart';

class AlertService {
  // Estados de estabilización (persisten durante la sesión)
  static bool _tempStabilized = false;
  static bool _pulseStabilized = false;

  // Umbrales ajustados a tu realidad (pecho, contacto directo)
  static const double TEMP_MIN_NORMAL = 31.0; // Tu valor estable
  static const double TEMP_MAX_NORMAL = 33.5;
  static const double TEMP_CHANGE_THRESHOLD = 1.5; // Cambio brusco

  static const int PULSE_MIN_STABLE = 2000; // Tu nuevo umbral
  static const int PULSE_CHANGE_HIGH = 3000;
  static const int PULSE_CHANGE_LOW = 1500;

  static const double MAG_IMPACT_THRESHOLD = 2.0; // Impacto fuerte
  static const int SIGNAL_WEAK_THRESHOLD = 2; // Nivel 1-2 = LEJOS / MUY LEJOS

  // Resetear estabilización (llamar al iniciar app o reconectar)
  static void resetStabilization() {
    _tempStabilized = false;
    _pulseStabilized = false;
  }

  static void checkAnomalies(SensorData data) {
    // 1. Temperatura
    if (data.temp >= TEMP_MIN_NORMAL && !_tempStabilized) {
      _tempStabilized = true;
    }

    if (_tempStabilized) {
      if (data.temp < 30.0) {
        _sendCriticalAlert(
          "ALERTA TÉRMICA - HIPOTERMIA",
          "Temperatura baja: ${data.temp.toStringAsFixed(1)}°C\n"
              "Posible agotamiento de batería o hipotermia",
        );
      } else if (data.temp > 38.5) {
        _sendCriticalAlert(
          "ALERTA TÉRMICA - FIEBRE",
          "Temperatura alta: ${data.temp.toStringAsFixed(1)}°C\n"
              "Posible fiebre o sensor sobrecalentado",
        );
      } else if ((data.temp - (data.temp - 0.1)).abs() >=
          TEMP_CHANGE_THRESHOLD) {
        _sendWarningAlert(
          "Cambio Brusco de Temperatura",
          "Variación detectada: ${data.temp.toStringAsFixed(1)}°C\n"
              "Verificar batería o colocación del sensor",
        );
      }
    }

    // 2. Pulso
    if (data.pulse >= PULSE_MIN_STABLE && !_pulseStabilized) {
      _pulseStabilized = true;
    }

    if (_pulseStabilized) {
      if (data.pulse > PULSE_CHANGE_HIGH) {
        _sendCriticalAlert(
          "ALERTA DE PULSO - TAQUICARDIA",
          "Pulso elevado: ${data.pulse} (raw)\n"
              "Posible desconexión, sensor mal colocado o estrés",
        );
      } else if (data.pulse < PULSE_CHANGE_LOW) {
        _sendCriticalAlert(
          "ALERTA DE PULSO - BRADICARDIA",
          "Pulso bajo: ${data.pulse} (raw)\n"
              "Posible batería baja o sensor desconectado",
        );
      }
    }

    // 3. Movimiento / Impacto
    if (data.mag > MAG_IMPACT_THRESHOLD) {
      _sendCriticalAlert(
        "ALERTA DE IMPACTO",
        "Movimiento brusco detectado: ${data.mag.toStringAsFixed(2)} g\n"
            "Posible caída, golpe o actividad intensa",
      );
    }

    // 4. Señal LoRa débil
    if (data.signalLevel <= SIGNAL_WEAK_THRESHOLD) {
      _sendWarningAlert(
        "ALERTA DE SEÑAL LoRa",
        "Señal débil o perdida (${_getSignalText(data.signalLevel)})\n"
            "Verificar emisor, distancia o batería",
      );
    }
  }

  // Helpers
  static String _getSignalText(int level) {
    switch (level) {
      case 5:
        return "MUY CERCA";
      case 4:
        return "CERCA";
      case 3:
        return "MEDIA";
      case 2:
        return "LEJOS";
      case 1:
        return "MUY LEJOS";
      default:
        return "SIN SEÑAL";
    }
  }

  static void _sendCriticalAlert(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chaleco_channel',
        title: '🚨 $title',
        body: body,
        notificationLayout: NotificationLayout.BigText,
        color: Colors.red,
        fullScreenIntent: true,
      ),
    );
  }

  static void _sendWarningAlert(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'chaleco_channel',
        title: '⚠️ $title',
        body: body,
        notificationLayout: NotificationLayout.BigText,
        color: Colors.orangeAccent,
      ),
    );
  }
}
