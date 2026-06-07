import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rabbit_flutter/firebase_options.dart';
import 'package:rabbit_flutter/main.dart';

late AndroidNotificationChannel channel;
bool isFlutterLocalNotificationsInitialized = false;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  await showFlutterNotification(message);
  print('Handling a background message ${message.messageId}');
  print('INFORMACION NOTIFICACION BACKGROUND: ${message.data}');
}


Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: _onLocalNotificationTap,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

Future<void> requestFcmPermission() async {
  if (kIsWeb) return;
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    provisional: false,
  );
}

Future<void> showFlutterNotification(RemoteMessage message) async {
  print('---------- NOTIFICACION PRIMER PLANO -----------');
  print('DATA FOREGROUND : ${message.data}');
  print('NOTIFICATION FOREGROUND: ${message.notification?.title}');
  print('NOTIFICATION FOREGROUND: ${message.notification?.body}');
  if (kIsWeb) return;
  await setupFlutterNotifications();

  final title = message.notification?.title ??
      message.data['title']?.toString() ??
      'Nueva solicitud de viaje';
  final body = message.notification?.body ??
      message.data['body']?.toString() ??
      'Revisa las solicitudes cercanas';

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: '@mipmap/ic_launcher',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
    // Reenviamos el data de FCM para poder rutear al tocar la notificación
    // local mostrada en foreground.
    payload: jsonEncode(message.data),
  );
}

int? _extractInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

void _navigateFromNotificationData(Map<String, dynamic> data) {
  if (data['type'] == 'CLIENT_REQUEST') {
    final idClientRequest = _extractInt(data['id_client_request']);
    navigatorKey.currentState?.pushNamed(
      'driver/client/request',
      arguments: idClientRequest,
    );
  }
}

/// Callback al tocar una notificación local (mostrada en foreground).
/// Recupera el `data` original (serializado como payload) y rutea.
void _onLocalNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload == null || payload.isEmpty) return;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      _navigateFromNotificationData(Map<String, dynamic>.from(decoded));
    }
  } catch (e) {
    print('Error decodificando payload de notificación: $e');
  }
}

Future<void> onMessageListener() async {
  await requestFcmPermission();
  await setupFlutterNotifications();

  // APP TERMINADA: abierta desde una notificación push.
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null && message.data.isNotEmpty) {
      print('---------- NOTIFICACION ENTRANTE (terminated) ---------');
      print('INFORMACION NOTIFICACION: ${message.data}');
      // Pequeño delay para asegurar que el Navigator ya esté montado.
      Future.delayed(const Duration(milliseconds: 800), () {
        _navigateFromNotificationData(message.data);
      });
    }
  });

  // NOTIFICACIONES EN PRIMER PLANO: solo mostramos la notificación local.
  // La navegación ocurre cuando el usuario la toca (_onLocalNotificationTap).
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await showFlutterNotification(message);
  });

  // APP EN BACKGROUND: el usuario tocó la notificación.
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('---------- NOTIFICACION CLICKEADA (background) -----------');
    print('INFORMACION NOTIFICACION CLICKEADA: ${message.data}');
    _navigateFromNotificationData(message.data);
  });
}

Future<void> registerFcmTokenRefresh(
  Future<void> Function(String token) onTokenRefresh,
) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null && token.isNotEmpty) {
    await onTokenRefresh(token);
  }
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await onTokenRefresh(newToken);
  });
}