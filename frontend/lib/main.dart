import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/providers/notifications_provider.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

Future<void> saveFcmTokenToServer(String userId) async {
  // Get the FCM token
  String? fcmToken = await FirebaseMessaging.instance.getToken();

  if (fcmToken != null) {
    // Make an API call to save the token to the backend
    var response = await http.post(
      Uri.parse('https://your-backend-api-url.com/save-token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'userId': userId,
        'fcmToken': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('FCM token saved successfully');
    } else {
      print('Failed to save FCM token');
    }
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('FCM Example'),
        ),
        body: Center(
          child: Text('Flutter FCM Demo'),
        ),
      ),
    );
  }
}
