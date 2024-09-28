import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/event_screen.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

// Method to send FCM token to your server
Future<void> sendFCMTokenToServer(String? token) async {
  if (token != null) {
    final url = 'http://192.168.0.102:3000/register-token';
    try {
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': '5f50b61f78d1e74d8c3f0002', // Make sure to include userId
          'fcmToken': token,
        }),
      );
      print("Token sent to server: $token");
    } catch (e) {
      print("Error sending token to server: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Get FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token"); // This line prints the token

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

    // Get the initial token and send it to your server
    messaging.getToken().then((token) {
      print('Initial FCM Token: $token');
      sendFCMTokenToServer(token);
    });

    // Listen for token refresh and send the new token to your server
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM Token: $newToken');
      sendFCMTokenToServer(newToken);
    });

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
