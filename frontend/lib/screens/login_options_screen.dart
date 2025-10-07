import 'package:flutter/material.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/org_screens/org_login.dart';
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
  // Animations for sliding
  late Animation<Offset> _slideInWelcome;
  late Animation<Offset> _slideInSubtitle;
  late Animation<Offset> _slideInButtons;

  // Authentication status
  bool _isAuthenticating = false;

  // Track selected role
  String? _selectedRole;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

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
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _onRoleSelected(String role) {
    if (_isAuthenticating) return;
    setState(() {
      _selectedRole = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              // Header with logo and app name using Hero widgets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      width: 80,
                      height: 80,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/appicon.png',
                          width: 52,
                          height: 52,
                          // color: Colors.white,
                          // colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // const Spacer(flex: 1),
              // Welcome text
              SlideTransition(
                position: _slideInWelcome,
                child: FadeTransition(
                  opacity: _fadeInWelcome,
                  child: const Text(
                    'Choose how you want to get started.',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                    'Switch roles anytime from settings',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      letterSpacing: 0.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SlideTransition(
                position: _slideInButtons,
                child: FadeTransition(
                  opacity: _fadeInButtons,
                  child: Column(
                    children: [
                      _buildLoginButton(
                        // icon: Icons.school,
                        text: 'Student',
                        color: Color(0xFF2B2B2B),
                        isSelected: _selectedRole == 'student',
                        onPressed: () => _onRoleSelected('student'),
                      ),
                      const SizedBox(height: 20),
                      _buildLoginButton(
                        // icon: Icons.admin_panel_settings,
                        text: 'Organizer',
                        color: Color(0xFF2B2B2B),
                        isSelected: _selectedRole == 'organizer',
                        onPressed: () => _onRoleSelected('organizer'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: ElevatedButton(
                  // onPressed: (_selectedRole == null || _isAuthenticating) ? null : () => _authenticateUser(_selectedRole!),
                  onPressed: (_selectedRole == null || _isAuthenticating) ? null : () {
                    if (_selectedRole == 'student') {
                      _authenticateUser(_selectedRole!);
                    } else if (_selectedRole == 'organizer') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage()), // Replace SignInPage() with your actual screen
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedRole == null ? Colors.grey:Color(0xFF2B2B2B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(400, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    _isAuthenticating ? 'Authenticating...' : 'Continue',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
    // required IconData icon,
    required String text,
    required Color color,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
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
          backgroundColor: isSelected ? color:Colors.white24,
          foregroundColor: isSelected ? Colors.white:color,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(
            //   icon,
            //   size: 24,
            // ),
            const SizedBox(width: 14),
            Text(
              text,
              style: const TextStyle(
                fontSize: 17,
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
