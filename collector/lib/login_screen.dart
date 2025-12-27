import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collector/services/api_services.dart';
import 'package:collector/subscription_screen.dart';
import 'package:collector/dashboard_screen.dart';

/// 🎨 Brand Colors
const primaryGreen = Color(0xFF3A7D44);
const primaryBlue  = Color(0xFF1F4E79);
const softGold     = Color(0xFFE7D892);
const bgLight      = Color(0xFFF9FAF7);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  /// Check if user is already logged in
  Future<void> _checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final hasSubscription = prefs.getBool('hasSubscription') ?? false;

    if (isLoggedIn && mounted) {
      final savedEmail = prefs.getString('userEmail') ?? '';
      final savedName = prefs.getString('userName') ?? 'User';

      // Navigate directly to dashboard if user has subscription
      if (hasSubscription) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(
              userEmail: savedEmail,
              userName: savedName,
            ),
          ),
              (_) => false,
        );
      }
    }
  }

  /// 🔐 LOGIN FUNCTION with SharedPreferences
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.loginWithUsernamePassword(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);
      if (!mounted) return;

      if (response['success'] == true) {
        // Save user data to SharedPreferences
        await _saveUserData(
          email: _usernameController.text.trim(),
          name: response['username'] ?? 'User',
          userId: response['user_id']?.toString(),
        );

        // Check if user has subscription
        final hasSubscription = response['has_subscription'] ?? false;

        if (hasSubscription) {
          // Save subscription status
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('hasSubscription', true);

          // Navigate to Dashboard if already subscribed
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardScreen(
                userEmail: _usernameController.text.trim(),
                userName: response['username'] ?? 'User',
              ),
            ),
                (_) => false,
          );
        } else {
          // Navigate to Subscription if no subscription
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => SubscriptionPage(
                userId: response['user_id'],
                username: response['username'],
              ),
            ),
                (_) => false,
          );
        }
      } else {
        _showSnack(response['message'] ?? 'Invalid credentials', Colors.red);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnack('Login error: $e', Colors.red);
    }
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserData({
    required String email,
    required String name,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', name);
    if (userId != null) {
      await prefs.setString('userId', userId);
    }
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// 🔰 LOGO (SIZE INCREASED & CLEAN)
              Container(
                width: 300,
                height: 200,
                decoration: BoxDecoration(
                  color: bgLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Image.asset(
                    'assets/images/img.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.business_center,
                      size: 120,
                      color: primaryBlue,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              /// 📦 LOGIN FORM CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _inputField(
                        controller: _usernameController,
                        label: 'Username / Email',
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 20),

                      _inputField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: primaryGreen,
                          ),
                          onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 10),

                      /// 🔗 FORGOT PASSWORD LINK
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            _showSnack(
                              'Forgot Password feature coming soon',
                              primaryBlue,
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 🔐 LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                              : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧩 INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: (value) =>
      value == null || value.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryBlue),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}