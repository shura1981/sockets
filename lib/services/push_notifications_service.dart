import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Key ID:NV4TU24ARL


class PushNotificationService {
  static final FirebaseMessaging message = FirebaseMessaging.instance;
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static String? token;
  static final StreamController<String> _messageStream =
      StreamController.broadcast();

  static Stream<String> get messageStream => _messageStream.stream;

  static closeController() {
    _messageStream.close();
  }

  static Future _backgroundHandler(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
  }

  static Future initializeApp() async {
    await Firebase.initializeApp();
    await requestPermission();
  }

  static requestPermission() async {
    NotificationSettings settings = await message.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User push notification status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      token = await message.getToken();
      print(token);
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onMessageHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
    }

    message.onTokenRefresh.listen((token) {
      print('Token: $token');
    });
  }
}
