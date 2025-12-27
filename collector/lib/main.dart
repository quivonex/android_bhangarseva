// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'splash_screen.dart';
import 'providers/language_provider.dart';

/// Define your global primary color (light blue)
const Color primaryLightBlue = Color(0xFF64B5F6); // Light Blue Accent

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Bhangar-seva-collector',
            debugShowCheckedModeBanner: false,

            // Prevent UI going inside device bottom navigation
            builder: (context, widget) {
              return SafeArea(
                top: false,
                bottom: true,
                child: widget!,
              );
            },

            // Localization Configuration
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // Hindi
              Locale('mr'), // Marathi
            ],

            // Theme Configuration
            theme: ThemeData(
              primaryColor: primaryLightBlue,
              scaffoldBackgroundColor: Colors.white,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryLightBlue,
                primary: primaryLightBlue,
                secondary: const Color(0xFF42A5F5),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: primaryLightBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                centerTitle: true,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryLightBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: primaryLightBlue,
                foregroundColor: Colors.white,
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.blue[50],
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: primaryLightBlue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintStyle: const TextStyle(color: Colors.grey),
              ),

              // Text Theme for multiple languages
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                displayMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
              ),
              useMaterial3: true,
            ),

            // Dark theme support
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: primaryLightBlue,
              colorScheme: const ColorScheme.dark().copyWith(
                primary: primaryLightBlue,
                secondary: Color(0xFF42A5F5),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: primaryLightBlue,
                elevation: 2,
              ),
              useMaterial3: true,
            ),

            home: const SplashScreen(),

            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
          );
        },
      ),
    );
  }
}