import 'package:flutter/material.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IITGsync',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[400],
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'IITGsync'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[100],
      appBar: AppBar(
        backgroundColor: Colors.purple[200],
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[400],
        child: Center(
          child: ElevatedButton(
            onPressed: () => wheretogo(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[100],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('START'),
          ),
        ),
      ),
    );
  }

  void wheretogo(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        // Navigate to ProfileScreen if access token is present
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  ProfileScreen()),
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