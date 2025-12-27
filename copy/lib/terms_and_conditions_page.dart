import 'package:flutter/material.dart';

// UPDATED COLOR THEME
const Color primaryBlue = Color(0xFF1F4E79);        // Header / Title
const Color darkBlue = Color(0xFF0D2C4A);           // Text color
const Color lightBlueBackground = Color(0xFFEAF1F8); // Card background
const Color backgroundLight = Color(0xFFF4F7F9);    // Page background

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  static const List<Map<String, String>> termsSections = [
    {
      'title': 'Terms and Conditions',
      'content':
      'Please read these Terms and Conditions carefully before using the bhangarseva.com website. '
          'By accessing or using our services online, you agree to be bound by all terms, privacy policies, '
          'and guidelines laid out on this website.',
    },
    {
      'title': 'Our Services',
      'content':
      'the bhangarseva.com operates in the scrap industry and provides web-based solutions for the '
          'collection, transportation, trade, recycling, and management of scrap materials such as metal, '
          'plastic, paper, and e-waste.',
    },
    {
      'title': 'Terms for Sellers',
      'content':
      'Individuals or businesses looking to sell scrap via our website must follow our service procedures. '
          'Accurate information about scrap type, quantity, and pickup location must be provided.',
    },
    {
      'title': 'Terms for Vendors',
      'content':
      'Scrap vendors partnering with us must agree to all outlined Terms & Conditions. This includes timely '
          'pickups, fair pricing, ethical handling of materials, and compliance with all website policies.',
    },
    {
      'title': 'Eligibility and Verification',
      'content':
      'the bhangarseva.com reserves the right to assess and approve vendor applications. '
          'We may reject or discontinue services for vendors who do not meet operational or ethical standards.',
    },
    {
      'title': 'Information Accuracy',
      'content':
      'All information provided on the bhangarseva.com is for general reference. '
          'While we strive for accuracy, we do not guarantee that content is complete, current, or error-free.',
    },
    {
      'title': 'User Inactivity Policy',
      'content':
      'If a user does not place an order within 3 months of registration, '
          'we reserve the right to cancel their membership.',
    },
    {
      'title': 'Service and Price Changes',
      'content':
      'We reserve the right to update service offerings and pricing structures at any time without prior notice. '
          'Any changes will be reflected on the website.',
    },
    {
      'title': 'Website-Based Services',
      'content':
      'All services are accessible via the bhangarseva.com. Vendors are charged service fees '
          'as per published pricing and refund policies.',
    },
    {
      'title': 'Vendor Compliance Requirements',
      'content':
      'Vendors must comply with all website protocols. Failure to do so will result in termination of access '
          'or partnership to ensure transparent and fair operations.',
    },
    {
      'title': 'Pickup Cancellation Policy',
      'content':
      'Pickup requests may be accepted or denied based on location and availability. '
          'We reserve the right to reschedule or cancel pickups due to unforeseen circumstances.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
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
            const Divider(height: 30, color: primaryBlue, thickness: 1),
            ...termsSections.map(
                  (section) =>
                  _buildTermSection(section['title']!, section['content']!),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                'Thank you for choosing BhangarSeva.',
                style: TextStyle(
                  fontSize: 14,
                  color: primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: lightBlueBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryBlue, width: 0.8),
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
