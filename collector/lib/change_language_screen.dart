// change_language_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryGold = Color(0xFFb59d31);

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  String _selectedLanguage = "English";
  final List<Map<String, String>> _languages = [
    {"name": "English", "flag": "🇬🇧"},
    {"name": "Hindi", "flag": "🇮🇳"},
    {"name": "Marathi", "flag": "🇮🇳"},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString("selected_language") ?? "English";
    setState(() {
      _selectedLanguage = savedLang;
    });
  }

  Future<void> _saveSelectedLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_language", lang);
  }

  void _onApply() {
    _saveSelectedLanguage(_selectedLanguage);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Language changed to $_selectedLanguage")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Language"),
        backgroundColor: primaryGold,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select your language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index]["name"]!;
                final flag = _languages[index]["flag"]!;
                final isSelected = _selectedLanguage == lang;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGold.withOpacity(0.2) : Colors.white,
                        border: Border.all(
                            color: isSelected ? primaryGold : Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lang,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? primaryGold : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: primaryGold),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onApply,
                style: ElevatedButton.styleFrom(backgroundColor: primaryGold),
                child: const Text(
                  "Apply",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: primaryGold,
            padding: const EdgeInsets.all(12),
            child: Text(
              "$_selectedLanguage चयनित",
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
