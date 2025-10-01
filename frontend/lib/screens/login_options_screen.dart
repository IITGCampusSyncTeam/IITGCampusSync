import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

import '../apis/authentication/login.dart';


class LoginOptionsScreen extends StatefulWidget {
  const LoginOptionsScreen({Key? key}) : super(key: key);

  @override
  State<LoginOptionsScreen> createState() => _LoginOptionsScreenState();
}

class _LoginOptionsScreenState extends State<LoginOptionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInWelcome;
  late Animation<double> _fadeInSubtitle;
  late Animation<double> _fadeInButtons;
  late Animation<double> _fadeInFooter;

  // Animations for sliding
  late Animation<Offset> _slideInWelcome;
  late Animation<Offset> _slideInSubtitle;
  late Animation<Offset> _slideInButtons;

  // Authentication status
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Adjust timing to not start until after Hero animation completes
    // Remove logo and title animations since they'll transition with Hero
    _fadeInWelcome = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _fadeInSubtitle = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _fadeInButtons = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );

    _fadeInFooter = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Setup slide animations
    _slideInWelcome =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideInSubtitle =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideInButtons =
        Tween<Offset>(begin: const Offset(0.0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Delay animation start to let Hero complete first
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticateUser(String userType) async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      await authenticate();

      if (!mounted) return;

      // Navigate based on userType
      if (userType == 'student') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(),
          ),
        );
      } else if (userType == 'organizer') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Authentication failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  // // Authentication function shared between student and organizer
  // Future<void> _authenticateUser(String userType) async {
  //   if (_isAuthenticating) return; // Prevent multiple authentication attempts
  //
  //   setState(() {
  //     _isAuthenticating = true;
  //   });
  //
  //   try {
  //     // Use the same authenticate function from your old login screen
  //     await authenticate();
  //
  //     if (!mounted) return;
  //
  //     // Navigate to ProfileScreen after successful authentication
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(
  //         builder: (context) => ProfileScreen(),
  //       ),
  //     );
  //   } catch (e) {
  //     // Show error message if authentication fails
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Authentication failed: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //     print("Authentication failed: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isAuthenticating = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Header with logo and app name using Hero widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade800,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.calendar_month_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Hero(
                    tag: 'app_title',
                    child: Material(
                      color: Colors.transparent,
                      child: const Text(
                        'Campus Calendar',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              // Welcome text - Centered
              SlideTransition(
                position: _slideInWelcome,
                child: FadeTransition(
                  opacity: _fadeInWelcome,
                  child: const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SlideTransition(
                position: _slideInSubtitle,
                child: FadeTransition(
                  opacity: _fadeInSubtitle,
                  child: Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[400],
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              // Login options
              SlideTransition(
                position: _slideInButtons,
                child: FadeTransition(
                  opacity: _fadeInButtons,
                  child: Column(
                    children: [
                      _buildLoginButton(
                        icon: Icons.school,
                        text: _isAuthenticating
                            ? 'Authenticating...'
                            : 'Login as Student',
                        color: Colors.deepPurple,
                        onPressed: _isAuthenticating
                            ? null
                            : () => _authenticateUser('student'),
                      ),
                      const SizedBox(height: 20),
                      _buildLoginButton(
                        icon: Icons.admin_panel_settings,
                        text: _isAuthenticating
                            ? 'Authenticating...'
                            : 'Login as Organizer',
                        color: Colors.green,
                        onPressed: _isAuthenticating
                            ? null
                            : () => _authenticateUser('organizer'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Footer
              FadeTransition(
                opacity: _fadeInFooter,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Made by Coding Club IITG',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.15),
          foregroundColor: color,
          minimumSize: const Size(double.infinity, 64), // Slightly taller
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
