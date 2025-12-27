// feedback_page.dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'dashboard_screen.dart'; // for colors

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  get primaryBrand => null;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.feedback),
        backgroundColor: primaryBlue,
      ),
      body: Center(
        child: Text(
          t.feedback,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
