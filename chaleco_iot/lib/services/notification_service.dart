import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart'; // <- Agrega esto

class NotificationService {
  // Inicializa Awesome Notifications
  static Future init() async {
    await AwesomeNotifications().initialize(
      null, // Icono por defecto, usa null o '@mipmap/ic_launcher'
      [
        NotificationChannel(
          channelKey: 'chaleco_channel',
          channelName: 'Chaleco Alerts',
          channelDescription: 'Notificaciones del Chaleco IoT',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.Max,
          channelShowBadge: true,
        ),
      ],
    );

    // Solicitar permisos
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  // Mostrar notificación
  static Future showNotification(String title, String body) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'chaleco_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
