// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:msa/models/recordatorio.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'recordatorios_channel';
  static const String channelName = 'Recordatorios';
  static const String channelDescription = 'Notificaciones de recordatorios';

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
        );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    tz.initializeTimeZones();
    
    // --- NUEVA LÓGICA PARA FIREBASE ---
    // Escucha los mensajes de FCM mientras la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(message.notification!);
      }
    });

    // Solicitar permiso de notificación para FCM
    await FirebaseMessaging.instance.requestPermission();
  }

  // Muestra una notificación local a partir de un mensaje de Firebase
  Future<void> showLocalNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  Future<void> programarRecordatorio(Recordatorio recordatorio) async {
    // La lógica de programación de FCM requiere un servidor, por lo que este método ahora es obsoleto.
    debugPrint('programarRecordatorio: Ahora se usa FCM.');
    // Aquí iría la llamada a tu API para programar el envío del mensaje de FCM
    // Por ejemplo:
    // http.post(
    //   'https://tu-servidor-de-api.com/programar-notificacion',
    //   body: {'token': await FirebaseMessaging.instance.getToken(), 'hora': recordatorio.hora, 'minuto': recordatorio.minuto, 'mensaje': recordatorio.mensaje}
    // );
  }

  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      '¡Hola desde MSA!',
      'Esta es una notificación de prueba. Si la ves, todo funciona.',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> cancelarRecordatorio(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}