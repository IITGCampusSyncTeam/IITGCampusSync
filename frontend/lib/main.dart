import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/notifications_provider.dart';
import 'package:frontend/screens/event_screen.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> sendFCMTokenToServer() async {
  String? token = await messaging.getToken();
  if (token != null) {
    final url = 'http://192.168.0.102:3000/register-token';
    await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': '5f50b61f78d1e74d8c3f0002',
        'fcmToken':
            'cDccltMOSvaxExFxsxLSQs:APA91bH075549UA84cSIfty-Cj0l5h2R_ji4wmn_N2tNkknGpPBlFjVBByoQVzAZTb_0ei8YIge1f7haBKED0wCGQspT5DsS66iXBzqqJw5zgyXzAgdeL5sBYh6AmOdlCqNEqozNNiLe'
      }), // Make sure to include userId
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Get FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token"); // This line prints the token

  await Future.wait([
    checkForNotifications(),
    //FirebaseMessaging.instance.getToken(),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    messaging.requestPermission();

    // Get the token for the device
    messaging.getToken().then((token) {
      print('FCM Token: $token');
      // Send this token to your server
    });
    sendFCMTokenToServer();

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message while in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: EventScreen());
  }
}
