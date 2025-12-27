// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Keys
  static const String _userIdKey = 'flutter.user_id';
  static const String _isLoggedInKey = 'flutter.isLoggedIn';
  static const String _userEmailKey = 'flutter.user_email';

  // Get user ID (optional)
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdStr = prefs.getString(_userIdKey);
    if (userIdStr != null && userIdStr.isNotEmpty) {
      return int.tryParse(userIdStr);
    }
    return null;
  }

  // Check if user is logged in (optional)
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get user email (optional)
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }
}