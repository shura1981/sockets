import 'dart:async';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Key ID:NV4TU24ARL
// SHA1: EE:20:11:DB:B8:5E:D7:F6:40:8F:06:45:BC:AF:94:8D:BA:4D:C6:84

class PushNotificationService {
  static final FirebaseMessaging message = FirebaseMessaging.instance;
  // static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static String? token;
  static final StreamController<String> _messageStream =
      StreamController.broadcast();
  static Stream<String> get messageStream => _messageStream.stream;
  static closeController() {
    _messageStream.close();
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
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      token = await message.getToken();
      print(token);
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onMessageHandler);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);
      localNotificaion();
    }

    message.onTokenRefresh.listen((token) {
      print('Token: $token');
    });
  }



  static Future _backgroundHandler(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
    if (message.data.containsKey('screen')) {
    String screen = message.data['screen'];
    await flutterLocalNotificationsPlugin.show(
        0, 'Notificación', 'Nueva notificación', const NotificationDetails(),
        payload: "/home");
    }
  }
  static Future _onMessageHandler(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
  }
  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print(message.data);
    _messageStream.add(message.notification?.title ?? 'No data');
  }


// local notifications
/// Create a [AndroidNotificationChannel] for heads up notifications
static late AndroidNotificationChannel channel;
  static String? selectedNotificationPayload;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static localNotificaion() async {

      channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'high_importance_channel', // id
    'This channel is used for important notifications', // title
    importance: Importance.high,
  );

 /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('star');

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (
              int id,
              String? title,
              String? body,
              String? payload,
            ) async {
              _messageStream.add(
                title ?? 'No data',
              );
            });

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        print('notification payload: $payload');
      }
      selectedNotificationPayload = payload;
      _messageStream.add(
        payload ?? 'No data',
      );
    }).then((value) => null);

    var notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      String? screen = notificationAppLaunchDetails?.payload;
      if (screen != null) {
        // Navigator.pushNamed(context, screen);
        _messageStream.add(
          screen,
        );
      }
    }
  }
  static mostarNotificacion() {
    flutterLocalNotificationsPlugin.show(
        0,
        'New Post',
        'How to Show Notification in Flutter',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            "1",
            "high_importance_channel",
            "channelDescription",
            icon: 'star',
          ),
          iOS: IOSNotificationDetails(),
        ),
        payload: 'How to Show Notification in Flutter');
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
