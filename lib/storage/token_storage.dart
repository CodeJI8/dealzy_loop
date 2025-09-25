// token_storage.dart
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _launchedKey = 'has_launched_once';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('📦 Retrieved token: $token');
      return token;
    } catch (e) {
      print('❌ Error in getToken(): $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ---- First launch helpers ----
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_launchedKey) ?? false);
  }

  static Future<void> markLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_launchedKey, true);
  }
}
