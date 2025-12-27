import 'package:flutter/material.dart';

// UPDATED COLOR THEME
const Color primaryBlue = Color(0xFF1F4E79);        // Header / Title
const Color darkBlue = Color(0xFF0D2C4A);           // Text color
const Color lightBlueBackground = Color(0xFFEAF1F8); // Section background
const Color backgroundLight = Color(0xFFF4F7F9);    // Page background

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const List<Map<String, String>> privacySections = [
    {
      'title': '1. Information We Collect',
      'content':
      'Personal Information: Name, mobile number, and address when you register via our app or customer service.\n\n'
          'Activity Data: Interactions with our platform, preferences, and device/browser data using cookies and analytics tools.\n\n'
          'We do NOT collect sensitive data like credit card numbers or banking credentials. '
          'All payments are securely handled by third-party providers.',
    },
    {
      'title': '2. Use of Your Information',
      'content':
      '• To create and manage your user account.\n'
          '• To verify your identity and ensure secure access to our services.\n'
          '• To send service updates, alerts, and marketing offers only with your consent.\n'
          '• To improve user experience through analytics and usage trends.\n'
          '• To provide customer support and resolve issues.',
    },
    {
      'title': '3. Sharing of Information',
      'content':
      'We may share data with law enforcement or regulatory authorities when required by law.\n\n'
          'We may share non-sensitive data with trusted service providers working on our behalf.\n\n'
          'We take appropriate measures to protect your data from unauthorized access or misuse.',
    },
    {
      'title': '4. Cookies & Tracking',
      'content':
      'We use cookies to improve platform performance, remember preferences, '
          'and analyze user behavior. You can control or disable cookies through your browser settings.',
    },
    {
      'title': '5. Your Rights & Choices',
      'content':
      'You can stop receiving promotional messages at any time.\n\n'
          'You may request access, correction, or deletion of your personal data by contacting us.',
    },
    {
      'title': '6. Policy Updates',
      'content':
      'We may update this Privacy Policy periodically. Any changes will be posted within the app. '
          'Continued use of our services means you accept the updated policy.',
    },
    {
      'title': '7. Feedback & Contact',
      'content':
      'Your feedback helps us improve our services. For any privacy-related concerns, '
          'please contact us using the email provided in the application.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: October 8, 2025',
              style: TextStyle(fontSize: 14, color: darkBlue),
            ),
            const SizedBox(height: 10),
            const Text(
              'We respect your privacy and are committed to protecting your personal information.',
              style: TextStyle(fontSize: 16, color: darkBlue),
            ),
            const Divider(
              height: 30,
              thickness: 1,
              color: primaryBlue,
            ),
            ...privacySections.map(
                  (section) =>
                  _buildSection(section['title']!, section['content']!),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Thank you for trusting our services.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightBlueBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryBlue, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: darkBlue,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
