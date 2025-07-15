import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SellerAuthService {
  final String baseUrl = 'https://dealzyloop.com/api';

  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String phone,
    required String password,
    required String storeName,
    required String storeType,
    required String address,
    required String imagePath,
  }) async {
    final url = Uri.parse('$baseUrl/seller_registration.php');

    var request = http.MultipartRequest('POST', url);
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['store_name'] = storeName;
    request.fields['store_type'] = storeType;
    request.fields['address'] = address;

    final mimeType = lookupMimeType(imagePath)?.split('/');
    if (mimeType != null && mimeType.length == 2) {
      request.files.add(await http.MultipartFile.fromPath(
        'pro_path',
        imagePath,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to register seller. Code: ${response.statusCode}");
    }
  }


  // ✅ LOGIN SELLER (POST JSON)
  Future<Map<String, dynamic>> loginSeller({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/seller_login.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to login. Code: ${response.statusCode}");
    }
  }




// ✅ GET ALL CATEGORIES (GET with Bearer Token)
  Future<List<dynamic>> getAllCategories(String token) async {
    final url = Uri.parse('$baseUrl/get_all_category.php');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );


    final data = json.decode(response.body);

    // 👇 Print full raw response
    print(' categories response: ${response.body}');

    if (response.statusCode == 200) {

      if (data['status'] == 'success') {
        return data['categories']; // Adjust based on your API response
      } else {
        throw Exception("Error fetching categories: ${data['message']}");
      }
    } else {
      throw Exception("Failed to fetch categories. Code: ${response.statusCode}");
    }
  }


// ✅ GET CURRENTDEALS


  Future<List<dynamic>> getCurrentDeals(String token, {int page = 1, int limit = 5}) async {
    final url = Uri.parse('$baseUrl/get_current_deals.php?page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);

    // 👇 Print full raw response
    print('🛠️ getCurrentDeals response: ${response.body}');

    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['data']; // Adjust key if needed
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch deals');
    }
  }


}
