// language_change_page.dart
import 'package:copy/services/api_service.dart';
import 'package:copy/user_profile_page.dart' hide primaryBlue, lightBackground, darkBlue;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_us_page.dart';
import 'activity/email_otp_verify.dart' hide primaryBlue;
import 'l10n/app_localizations.dart';
import 'theme.dart' hide lightSand;
import '../providers/language_provider.dart';

class LanguageChangePage extends StatefulWidget {
  const LanguageChangePage({super.key});

  @override
  State<LanguageChangePage> createState() => _LanguageChangePageState();
}

class _LanguageChangePageState extends State<LanguageChangePage> {
  String _selectedLanguage = 'English';

  final List<Map<String, String>> languages = [
    {'name': 'English', 'code': 'en', 'flag': '🇬🇧', 'localizedName': 'English'},
    {'name': 'Hindi', 'code': 'hi', 'flag': '🇮🇳', 'localizedName': 'हिन्दी'},
    {'name': 'Marathi', 'code': 'mr', 'flag': '🇮🇳', 'localizedName': 'मराठी'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() {
    final context = this.context;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final languageProvider =
      Provider.of<LanguageProvider>(context, listen: false);

      // Load saved language from shared preferences
      String? savedCode = await ApiService.getLanguageCode();

      if (savedCode != null) {
        setState(() {
          _selectedLanguage = _getLanguageNameFromCode(savedCode);
        });
      } else {
        setState(() {
          _selectedLanguage =
              _getLanguageNameFromCode(languageProvider.locale.languageCode);
        });
      }
    });
  }

  String _getLanguageNameFromCode(String code) {
    switch (code) {
      case 'hi':
        return 'Hindi';
      case 'mr':
        return 'Marathi';
      default:
        return 'English';
    }
  }

  String _getLocalizedName(String languageCode, BuildContext context) {
    switch (languageCode) {
      case 'en':
        return AppLocalizations.of(context)!.english;
      case 'hi':
        return AppLocalizations.of(context)!.hindi;
      case 'mr':
        return AppLocalizations.of(context)!.marathi;
      default:
        return languageCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: AppBar(
        title: Text(appLocalizations.language),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalizations.selectLanguage,
              style: TextStyle(color: darkBlue, fontSize: 16),
            ),
            const SizedBox(height: 20),

            ...languages.map((lang) {
              bool isSelected = _selectedLanguage == lang['name'];
              String localizedName = _getLocalizedName(lang['code']!, context);

              return Card(
                color: isSelected ? lightSand : Colors.white,
                elevation: isSelected ? 4 : 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected ? primaryBlue : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: ListTile(
                  leading:
                  Text(lang['flag']!, style: const TextStyle(fontSize: 26)),
                  title: Text(
                    localizedName,
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? primaryBlue : darkBlue,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: primaryBlue)
                      : null,
                  onTap: () {
                    _changeLanguage(
                        lang['code']!, lang['name']!, lang['flag']!, languageProvider);
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _applyLanguageChange(languageProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  appLocalizations.apply,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(String code, String name, String flag,
      LanguageProvider languageProvider) async {
    setState(() {
      _selectedLanguage = name;
    });

    languageProvider.changeLanguage(code);

    // Save language code & flag
    await ApiService.saveLanguageCode(code);
    await ApiService.saveLanguageFlag(flag);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ${AppLocalizations.of(context)!.selected}'),
        backgroundColor: primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyLanguageChange(LanguageProvider languageProvider) {
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${AppLocalizations.of(context)!.languageChanged} $_selectedLanguage'),
        backgroundColor: primaryBlue,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
