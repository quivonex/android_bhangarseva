import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    // Check login status using SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userEmail = prefs.getString('userEmail') ?? '';
    final userName = prefs.getString('userName') ?? 'User';

    if (!mounted) return;

    if (isLoggedIn && userEmail.isNotEmpty) {
      // User is logged in, go directly to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(
            userEmail: userEmail,
            userName: userName,
          ),
        ),
      );
    } else {
      // User is not logged in, go to Login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 🔰 LOGO ZOOM
              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/images/img.png',
                  width: 240,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.recycling,
                        size: 120,
                        color: Color(0xFF1F4E79),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              /// 🏷️ APP NAME
              const Text(
                'Bhangar-Sewa',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F4E79),
                ),
              ),

              const SizedBox(height: 8),

              /// TAGLINE
              const Text(
                'Your Trusted Scrap Partner',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}