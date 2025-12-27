import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LanguageProvider() {
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString('selected_language_code');

    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  void changeLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language_code', languageCode);
  }
}
