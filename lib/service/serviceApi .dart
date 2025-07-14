import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/seller_registration_model.dart';

class ServiceApi {
  final String baseUrl = 'https://dealzyloop.com/api';

  /// Seller Registration
  Future<SellerRegistrationResponse> registerSeller({
    required String name,
    required String phone,
    required String password,
    required String storeName,
    required String storeType,
    required String address,
    required String otp,
    required String profileImagePath,
  }) async {
    var url = Uri.parse('$baseUrl/seller_registration.php');

    var request = http.MultipartRequest('POST', url)
      ..fields.addAll({
        'name': name,
        'phone': phone,
        'password': password,
        'store_name': storeName,
        'store_type': storeType,
        'address': address,
      })
      ..headers.addAll({'otp': otp})
      ..files.add(await http.MultipartFile.fromPath('pro_path', profileImagePath));

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception('Failed to register seller: ${response.statusCode}');
    }

    final jsonResponse = json.decode(responseBody);
    return SellerRegistrationResponse.fromJson(jsonResponse);
  }

  /// Seller Login
  Future<Map<String, dynamic>> loginSeller({
    required String phone,
    required String password,
  }) async {
    var url = Uri.parse('$baseUrl/seller_login.php');

    var response = await http.post(url, body: {
      'phone': phone,
      'password': password,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to login: ${response.statusCode}');
    }

    return json.decode(response.body);
  }

  /// Get All Categories
  Future<Map<String, dynamic>> getAllCategories({required String token}) async {
    var url = Uri.parse('$baseUrl/get_all_category.php');

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch categories: ${response.statusCode}');
    }

    return json.decode(response.body);
  }
}
