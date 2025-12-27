// bulk_order_page.dart
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'dashboard_screen.dart'; // for colors

class BulkOrderPage extends StatelessWidget {
  const BulkOrderPage({super.key});

  get primaryBrand => null;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;


    return Scaffold(
      appBar: AppBar(
        title: Text(t.bulkOrder),
        backgroundColor: primaryBlue,
      ),
      body: Center(
        child: Text(
          t.bulkOrder,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
