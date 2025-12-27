// about_us_page.dart
import 'package:flutter/material.dart';

// UPDATED COLOR THEME
const Color primaryBlue = Color(0xFF1F4E79);      // Header / AppBar
const Color darkBlue = Color(0xFF0D2C4A);         // Paragraph text
const Color lightBlueBackground = Color(0xFFEAF1F8); // Section background
const Color backgroundLight = Color(0xFFF4F7F9);  // Page background

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/img_6.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: primaryBlue.withOpacity(0.1),
                padding: const EdgeInsets.all(15),
                alignment: Alignment.topCenter,
                child: const Text(
                  'THE BHANGARWALA\nWorking together to save the earth.',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black45),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: const [
                  _Paragraph(
                    text:
                    'The Bhangarseva is a leading online doorstep pickup service for scrap and junk materials in Satara. We aim to make scrap selling easier and more efficient, helping individuals and businesses dispose of waste responsibly.',
                  ),
                  _Paragraph(
                    text:
                   'We buy Paper Scrap, Reusable Clothes, Glass Bottles, E-Waste, Plastic, Metals, and Tyres.'
                      'Bulk purchases from Colleges, Institutions, IT Companies, Banks, Offices, Industries, Construction Sites, and Societies.'
                  'Committed to our mission: Making India Clean & Green.'
                  'Eco-friendly recycling solutions with a seamless pickup process.'
                  ),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;

  const _Paragraph({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: darkBlue,
        ),
      ),
    );
  }
}
