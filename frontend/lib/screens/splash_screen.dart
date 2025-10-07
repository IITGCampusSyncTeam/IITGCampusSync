import 'package:flutter/material.dart';
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
  bool _isNavigating = false;

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
    // Timer(const Duration(milliseconds: 1500), () {
    //   _checkAuthAndNavigate();
    // });
  }

  void _onContinuePressed() {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
    });

    // Reverse the animation to fade out the splash screen
    _animationController.reverse().then((_) {
      // After fade-out is complete, check auth and navigate
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Align(
        alignment: AlignmentGeometry.topLeft,
        // padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea( // optional but recommended
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              // Padding(
              //   // padding: const EdgeInsets.symmetric(horizontal: 40.0),
              //   padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                // child: Hero(
                //   tag: 'app_logo',
                  Align(
                    alignment: AlignmentGeometry.topRight,
                    child: Container(
                      width: 350,
                      height: 530,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/bg_image.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                // ),
              // ),
              SizedBox(height: 24),
              // App Name with Hero widget
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Hero(
                      tag: 'app_title',
                      child: Material(
                        color: Colors.transparent,
                        child: const Text(
                          'Discover. Sync. Connect.',
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Tagline
                    Text(
                      'Explore what’s happening on campus and bring people together in one place.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF27272A),
                      ),
                    ),
                    SizedBox(height: 34),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onContinuePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // END ADDED
            ],
          ),
      ),
    ),
        ),
      ),
    );
  }
}
