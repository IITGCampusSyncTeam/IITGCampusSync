import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/screens/club_profile_screen.dart';
import 'package:frontend/screens/home.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/sharing.dart';
import 'package:frontend/services/notification_services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './constants/endpoints.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> sendFCMTokenToServer(String? token) async {
  if (token != null) {
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('email'); // Fetch stored user ID
    print(email);
    print(token);
    if (email == null) {
      print("⚠️ User ID not found in SharedPreferences. Cannot send token.");
      return;
    }

    const url = NotifEndpoints.saveToken;
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'fcmToken': token,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Token sent to server: $token");
      } else {
        print("❌ Failed to send token: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending token to server: $e");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize NotificationServices
  NotificationServices notificationServices = NotificationServices();

  // Request notification permissions
  notificationServices.requestNotificationPermission();
  // Get FCM Token
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token"); // This line prints the token
  // Save token locally
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (token != null) {
    await prefs.setString('fcmToken', token);
  }
  final accessToken = prefs.getString('access_token');
  if (accessToken != null && accessToken.isNotEmpty) {
    // Send token to backend

    await sendFCMTokenToServer(token);
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('Refreshed FCM Token: $newToken');
      sendFCMTokenToServer(newToken);
    });
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationServices _notificationServices = NotificationServices();
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase notifications
    _notificationServices.firebaseInit(context);

    // Set up foreground notification presentation options
    _notificationServices.forgroundMessage();
    messaging = FirebaseMessaging.instance;

    // Request permission for notifications
    messaging.requestPermission();

    // Get the initial token and send it to your server
    // messaging.getToken().then((token) {
    //   print('Initial FCM Token: $token');
    //   sendFCMTokenToServer(token);
    // });

    // Listen for token refresh and send the new token to your server
    // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    //   print('Refreshed FCM Token: $newToken');
    //   sendFCMTokenToServer(newToken);
    // });

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
      title: 'IITGsync',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[400],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: PaymentScreen(),
      //home: const MyHomePage(title: 'IITGsync'),
      //home:  EventShareScreen(),
      home : ClubProfileScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  static const String KEY_LOGIN_STATUS = "login";

  @override
  void initState() {
    super.initState();
    wheretogo(); // Automatically call wheretogo when MyHomePage loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while navigating
      ),
    );
  }

  void wheretogo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        // Navigate to ProfileScreen if access token is present
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // Navigate to login if no access token is found
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const login()),
        );
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }
}
