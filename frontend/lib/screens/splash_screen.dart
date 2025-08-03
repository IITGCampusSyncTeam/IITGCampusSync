import 'package:flutter/material.dart';
import 'package:frontend/screens/explore_screen.dart';
import 'dart:async';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/nav_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/screens/home.dart';
import 'login_options_screen.dart'; // Make sure this import is correct

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    // Start animation and check authentication after delay
    _animationController.forward();
    Timer(const Duration(milliseconds: 1500), () {
      _checkAuthAndNavigate();
    });
  }

  // Check if user is logged in and navigate accordingly
  void _checkAuthAndNavigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken != null && accessToken.isNotEmpty) {
        // Navigate to Home if access token is present
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainNavigationContainer()),
        );
      } else {
        // Navigate to login if no access token is found
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600), // Slower transition for the hero
            pageBuilder: (context, animation, secondaryAnimation) => const LoginOptionsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      print("ERROR: $e");
      // Default to login screen if there's an error
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOptionsScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo wrapped in Hero widget with a unique tag
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade800,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // App Name with Hero widget
              Hero(
                tag: 'app_title',
                child: Material(
                  color: Colors.transparent,
                  child: const Text(
                    'Campus Calendar',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tagline
              const Text(
                'Your Campus Events, Personalized',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
