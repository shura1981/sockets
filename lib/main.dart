import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    // Configura local notifications
    var initializationSettingsAndroid = const AndroidInitializationSettings('ic_launcher'); // Este es el ícono de la notificación, puedes cambiarlo.
    var initializationSettingsIOS = const IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showNotification(message);
        _navigateToScreen(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToScreen(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToScreen(message);
      },
    );
  }

  void _showNotification(Map<String, dynamic> message) {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'channel_ID', 'channel_name', 'channel_description',
      importance: Importance.max, priority: Priority.high, showWhen: false);
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  void _navigateToScreen(Map<String, dynamic> message) {
    final screenName = message['data']['screen'];
    if (screenName == "ScreenA") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScreenA()),
      );
    } else if (screenName == "ScreenB") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ScreenB()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Push Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Flutter Push Notifications")),
      body: const Center(
        child: Text("Home Screen"),
      ),
    );
  }
}

class ScreenA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen A")),
      body: const Center(child: Text("Pantalla A")),
    );
  }
}

class ScreenB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Screen B")),
      body: const Center(child: Text("Pantalla B")),
    );
  }
}
