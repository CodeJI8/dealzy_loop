import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? "";

  /// Send OTP by email
  Future<Map<String, dynamic>> sendOtp(String email) async {
    if (_baseUrl.isEmpty) {
      throw Exception("API_BASE_URL not set in .env");
    }

    final url = Uri.parse("$_baseUrl/send_otp.php");
    final response = await http.post(
      url,
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to send OTP. Code: ${response.statusCode}");
    }
  }
}
