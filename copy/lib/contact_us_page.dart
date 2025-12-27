import 'package:copy/theme.dart';
import 'package:copy/user_profile_page.dart' hide primaryBlue, lightSand, lightBackground, darkBlue;
import 'package:flutter/material.dart';
import 'about_us_page.dart';
import 'activity/email_otp_verify.dart' hide primaryBlue;
import 'main.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryBlue,
            lightSand,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackground(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top +
                  AppBar().preferredSize.height +
                  20,
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 5,
                    color: Colors.white.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Contact Details',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 15),
                          _buildContactRow(icon: Icons.phone, text: '+91-9226859922'),
                          _buildContactRow(icon: Icons.mail, text: 'quivonexsolutions@gmail.com'),
                          _buildContactRow(icon: Icons.language, text: 'www.bhangarwala.com'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    elevation: 5,
                    color: Colors.white.withOpacity(0.95),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          _buildTextField(hint: 'Enter Your Name'),
                          _buildTextField(hint: 'Enter Your Mobile Number'),
                          _buildTextField(hint: 'Email Address'),
                          _buildTextField(hint: 'Type Your Message*', maxLines: 5),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Message Submitted!"),
                            backgroundColor: primaryBlue,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('SUBMIT',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios,
                              size: 18, color: Colors.white)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 10),
          Flexible(
              child: Text(text,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          fillColor: lightSand,
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: darkBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
