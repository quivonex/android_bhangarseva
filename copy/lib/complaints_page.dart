// complaints_page.dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'dashboard_screen.dart'; // for colors

class ComplaintsPage extends StatelessWidget {
  const ComplaintsPage({super.key});

  get primaryBrand => null;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.complaints),
        backgroundColor: primaryBlue,
      ),
      body: Center(
        child: Text(
          t.complaints,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
