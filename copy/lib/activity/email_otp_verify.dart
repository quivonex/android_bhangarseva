import 'package:copy/services/api_service.dart';
import 'package:flutter/material.dart';
import '../dashboard_screen.dart';

/// 🌿 Eco Trust Theme Colors
const Color primaryGreen = Color(0xFF6FAE3E);
const Color darkGreen = Color(0xFF3E6B2C);
const Color primaryBlue = Color(0xFF1F4E79);
const Color lightBackground = Color(0xFFF4F7F3);
const Color accentGold = Color(0xFFC48A3A);
const Color textDark = Color(0xFF1E1E1E);

class EmailOtpVerifyPage extends StatefulWidget {
  final String email;
  const EmailOtpVerifyPage({super.key, required this.email});

  @override
  State<EmailOtpVerifyPage> createState() => _EmailOtpVerifyPageState();
}

class _EmailOtpVerifyPageState extends State<EmailOtpVerifyPage> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter complete OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await ApiService.verifyOtp(otp, widget.email);
    setState(() => _isLoading = false);

    if (response["success"] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
            (_) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Verified Successfully"),
          backgroundColor: primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["error"] ?? "OTP verification failed"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    final response = await ApiService.sendOtp(widget.email);
    setState(() => _isResending = false);

    if (response["success"] == true) {
      for (var c in _otpControllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP Resent Successfully"),
          backgroundColor: primaryGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["error"] ?? "Failed to resend OTP"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackground,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          /// 🌈 Eco Gradient
          gradient: LinearGradient(
            colors: [primaryGreen, primaryBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Logo
                Image.asset(
                  "assets/images/bhangarwala.png",
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),

                /// Title
                const Text(
                  "Verify OTP",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),

                /// Subtitle
                Text(
                  "OTP sent to ${widget.email}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 30),

                /// OTP Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextField(
                          controller: _otpControllers[i],
                          focusNode: _focusNodes[i],
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          cursorColor: primaryGreen,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 18),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: primaryGreen,
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                            if (val.isNotEmpty && i == 5) {
                              String otp = _otpControllers
                                  .map((e) => e.text)
                                  .join();
                              if (otp.length == 6) _verifyOtp();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                /// Verify Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Text(
                      "VERIFY OTP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                /// Resend OTP
                TextButton(
                  onPressed: _isResending ? null : _resendOtp,
                  child: _isResending
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text(
                    "Resend OTP",
                    style: TextStyle(
                      color: accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
