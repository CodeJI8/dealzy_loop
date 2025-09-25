// lib/service/seller_auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart'; // for TimeOfDay -> "HH:mm:ss"
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'models/post_product_request.dart';
import 'models/post_product_response.dart';
import 'models/SellerProfile.dart';

class SellerAuthService {
  SellerAuthService({String? overrideBaseUrl})
      : baseUrl = overrideBaseUrl ?? (dotenv.env['API_BASE_URL'] ?? 'https://dealzyloop.com/api');

  final String baseUrl;

  static const _timeout = Duration(seconds: 20);

  Map<String, String> _jsonHeaders({String? token}) => {
    if (token != null) 'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  T _decodeJson<T>(http.Response res) {
    try {
      return jsonDecode(res.body) as T;
    } catch (_) {
      throw Exception('Unexpected response format (${res.statusCode}): ${res.body}');
    }
  }

  // -----------------------------
  // REGISTER (multipart + optional times)
  // -----------------------------
  // Ensure you have these imports somewhere in the file:
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'package:mime/mime.dart';

// Update your method signature to include `email`
  Future<Map<String, dynamic>> registerSeller({
    required String name,
    required String phone,
    required String email,         // <-- added
    required String password,
    required String storeName,
    required String storeType,
    required String address,
    required String imagePath,
    String? openingTime, // "HH:mm:ss"
    String? closingTime, // "HH:mm:ss"
    required String postalCode,
  }) async {
    final url = Uri.parse('$baseUrl/seller_registration.php');
    final request = http.MultipartRequest('POST', url)
      ..headers['Accept'] = 'application/json';

    // ---- Fields ----
    request.fields.addAll({
      'name': name,
      'phone': phone,
      'email': email,             // <-- added
      'password': password,
      'store_name': storeName,
      'store_type': storeType,
      'address': address,
      'post_code': postalCode,
    });

    if (openingTime != null && openingTime.isNotEmpty) {
      request.fields['opening_time'] = openingTime;
    }
    if (closingTime != null && closingTime.isNotEmpty) {
      request.fields['closing_time'] = closingTime;
    }

    // ---- File (pro_path) ----
    final file = File(imagePath);
    if (!await file.exists()) {
      throw Exception('Profile image not found at path: $imagePath');
    }
    final mime = lookupMimeType(imagePath) ?? 'application/octet-stream';
    final parts = mime.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'pro_path',
        imagePath,
        contentType: parts.length == 2 ? MediaType(parts[0], parts[1]) : null,
      ),
    );

    // ---- Logging (avoid printing password) ----
    final safeFields = Map.of(request.fields)..remove('password');
    print('[registerSeller] POST $url');
    print('[registerSeller] fields: $safeFields');
    print('[registerSeller] file  : $imagePath');

    // ---- Send ----
    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    print('[registerSeller] status: ${response.statusCode}');
    print('[registerSeller] body  : ${response.body}');

    // ---- Handle ----
    if (response.statusCode == 200) {
      // If you already have a helper, keep using it:
      // final decoded = _decodeJson<Map<String, dynamic>>(response);
      // Otherwise:
      Map<String, dynamic> decoded;
      try {
        decoded = json.decode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Unexpected response format (not JSON): ${response.body}');
      }

      print('[registerSeller] decoded: $decoded');
      return decoded;
    }

    throw Exception('Failed to register seller (${response.statusCode}): ${response.body}');
  }



  /// Helper if you pick time via TimeOfDay and need "HH:mm:ss"
  static String formatTimeOfDay(TimeOfDay t, {int seconds = 0}) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    final s = seconds.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // -----------------------------
  // LOGIN (JSON)
  // -----------------------------
  Future<Map<String, dynamic>> loginSeller({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/seller_login.php');

    final response = await http
        .post(
      url,
      headers: _jsonHeaders(),
      body: jsonEncode({'phone': phone, 'password': password}),
    )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeJson<Map<String, dynamic>>(response);
    }
    throw Exception('Failed to login. Code: ${response.statusCode}, Body: ${response.body}');
  }

  // -----------------------------
  // CATEGORIES (GET + Bearer)
  // -----------------------------
  Future<List<dynamic>> getAllCategories(String token) async {
    final url = Uri.parse('$baseUrl/get_all_category.php');

    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    )
        .timeout(_timeout);

    final data = _decodeJson<Map<String, dynamic>>(response);
    if (response.statusCode == 200) {
      if (data['status'] == 'success') {
        return (data['categories'] as List?) ?? [];
      }
      throw Exception('Error fetching categories: ${data['message']}');
    }
    throw Exception('Failed to fetch categories. Code: ${response.statusCode}');
  }

  // -----------------------------
  // CURRENT DEALS (GET + Bearer)
  // -----------------------------
  Future<List<dynamic>> getCurrentDeals(
      String token, {
        int page = 1,
        int limit = 15,
      }) async {
    final url = Uri.parse('$baseUrl/get_current_deals.php?page=$page&limit=$limit');

    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    )
        .timeout(_timeout);

    final data = _decodeJson<Map<String, dynamic>>(response);
    if (response.statusCode == 200) {
      final products = data['products'] as List<dynamic>?;
      if (products != null && products.isNotEmpty) return products;
      throw Exception(data['message'] ?? 'No products found');
    }
    throw Exception('Failed to fetch deals: ${response.statusCode}');
  }

  // -----------------------------
  // POST PRODUCT (multipart + Bearer)
  // -----------------------------
  Future<PostProductResponse> postProduct({
    required String token,
    required PostProductRequest requestModel,
  }) async {
    final request = await requestModel.toMultipartRequest('$baseUrl/post_products.php', token);
    final streamedResponse = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return PostProductResponse.fromJson(
        _decodeJson<Map<String, dynamic>>(response),
      );
    }
    throw Exception('Failed to post product: ${response.statusCode}, Body: ${response.body}');
  }

  // -----------------------------
  // GET POSTED PRODUCTS (GET + Bearer)
  // -----------------------------
  Future<List<dynamic>> getPostedProducts(
      String token, {
        int page = 1,
        int limit = 15,
      }) async {
    final url = Uri.parse('$baseUrl/get_posted_products.php?page=$page&limit=$limit');

    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    )
        .timeout(_timeout);

    final data = _decodeJson<Map<String, dynamic>>(response);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return (data['products'] as List?) ?? [];
    }
    throw Exception(data['message'] ?? 'Failed to fetch posted products');
  }

  // -----------------------------
  // ADD OFFER (JSON + Bearer)
  // -----------------------------
  Future<Map<String, dynamic>> addOffer({
    required String token,
    required String productId,
    required String discount,          // percentage as string; e.g., "25"
    required String offerCategory,     // backend key: 'regular' | 'expiring_soon' | 'clearance' | 'seasonal' | 'service_special'
    String? expiryDate,                // YYYY-MM-DD
  }) async {
    final url = Uri.parse('$baseUrl/add_offer.php');

    // Normalize to backend-expected lowercase keys
    final cat = offerCategory.trim().toLowerCase();

    // Accepted categories (server contract)
    const allowed = {
      'regular',
      'expiring_soon',
      'clearance',
      'seasonal',
      'service_special',
    };
    if (!allowed.contains(cat)) {
      throw ArgumentError("Invalid offer_category: $cat");
    }

    // Basic input validations (best practice)
    if (productId.isEmpty) throw ArgumentError("product_id is required");
    if (discount.isEmpty) throw ArgumentError("discount is required");

    // Server rule: expiry required for expiring_soon & seasonal; optional for clearance; not sent for regular/service_special
    final requiresExpiry = (cat == 'expiring_soon' || cat == 'seasonal');
    final expiryOptional = (cat == 'clearance');
    final shouldOmitExpiry = (cat == 'regular' || cat == 'service_special');

    if (requiresExpiry && (expiryDate == null || expiryDate.isEmpty)) {
      throw ArgumentError("expiry_date is required for $cat");
    }

    final body = <String, dynamic>{
      'product_id': productId,
      'discount': discount,
      'offer_category': cat,
    };

    if (!shouldOmitExpiry) {
      // include if required, or if optional+present
      if (requiresExpiry || (expiryOptional && (expiryDate != null && expiryDate.isNotEmpty))) {
        body['expiry_date'] = expiryDate;
      }
    }

    final response = await http
        .post(
      url,
      headers: _jsonHeaders(token: token),
      body: jsonEncode(body),
    )
        .timeout(_timeout);

    final data = _decodeJson<Map<String, dynamic>>(response);
    if (response.statusCode == 200) return data;
    throw Exception(data['message'] ?? 'Failed to add offer. Code: ${response.statusCode}');
  }


  // -----------------------------
  // PRODUCT DETAILS (GET, no auth)
  // -----------------------------
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    final url = Uri.parse('$baseUrl/product_details.php?product_id=$productId');

    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(_timeout);

    final data = _decodeJson<Map<String, dynamic>>(response);
    if (response.statusCode == 200 && data['status'] == 'success') {
      return data; // or data['product'] depending on usage
    }
    throw Exception(data['message'] ?? 'Failed to fetch product details');
  }

  // -----------------------------
  // SELLER PROFILE (GET + Bearer)
  // -----------------------------
  Future<SellerProfileResponse> getSellerProfile({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/seller_profile.php');
    final response = await http
        .get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final decoded = _decodeJson<Map<String, dynamic>>(response);
      return SellerProfileResponse.fromJson(decoded);
    }
    throw Exception(
      'Failed to load profile. Code: ${response.statusCode}, Body: ${response.body}',
    );
  }

  // -----------------------------
  // UPDATE PRODUCT (PUT JSON + Bearer)
  // -----------------------------
  Future<Map<String, dynamic>> updateProduct({
    required String token,
    required String productId,
    required int stock,
    required double price,
  }) async {
    final url = Uri.parse('$baseUrl/update_product.php');

    final response = await http
        .put(
      url,
      headers: _jsonHeaders(token: token),
      body: jsonEncode({
        'product_id': productId,
        'stock': stock,
        'price': price,
      }),
    )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeJson<Map<String, dynamic>>(response);
    }
    throw Exception('Failed to update product. Code: ${response.statusCode}, Body: ${response.body}');
  }

  // -----------------------------
  // DELETE ITEM (DELETE JSON + Bearer)
  // -----------------------------
  Future<Map<String, dynamic>> deleteItem({
    required String token,
    required String productId,
    required String item,
  }) async {
    final url = Uri.parse('$baseUrl/delete.php');
    final payload = jsonEncode({'product_id': productId, 'item': item});
    http.Response response;

    try {
      response = await http.delete(
        url,
        headers: _jsonHeaders(token: token),
        body: payload,
      ).timeout(_timeout);
    } on Exception {
      rethrow;
    }

    // Debug log
    print('DELETE response: ${response.statusCode} -> ${response.body}');

    if (response.statusCode == 204) {
      return {'status': 'success', 'message': 'Deleted'};
    }

    if (response.statusCode == 405 || response.statusCode == 501) {
      final postUrl = Uri.parse('$baseUrl/delete.php?_method=DELETE');
      final postResp = await http.post(
        postUrl,
        headers: _jsonHeaders(token: token),
        body: payload,
      ).timeout(_timeout);

      print('POST fallback response: ${postResp.statusCode} -> ${postResp.body}');

      if (postResp.statusCode == 200) {
        try {
          return _decodeJson<Map<String, dynamic>>(postResp);
        } catch (_) {
          return {'status': 'success', 'message': 'Deleted'};
        }
      }
      throw Exception('Failed to delete $item. Code: ${postResp.statusCode}, Body: ${postResp.body}');
    }

    if (response.statusCode == 200) {
      try {
        return _decodeJson<Map<String, dynamic>>(response);
      } catch (_) {
        return {'status': 'success', 'message': 'Deleted'};
      }
    }

    throw Exception('Failed to delete $item. Code: ${response.statusCode}, Body: ${response.body}');
  }

  Future<Map<String, dynamic>> uploadProfileImage({
    required String token,
    required File imageFile,
  }) async {
    final url = Uri.parse('$baseUrl/upload_profile.php');
    final req = http.MultipartRequest('POST', url)
      ..headers.addAll({'Authorization': 'Bearer $token', 'Accept': 'application/json'});

    final mime = lookupMimeType(imageFile.path) ?? 'image/png';
    final parts = mime.split('/');
    req.files.add(
      await http.MultipartFile.fromPath(
        'profile_image', // <-- API field name
        imageFile.path,
        contentType: parts.length == 2 ? MediaType(parts[0], parts[1]) : null,
      ),
    );

    final streamed = await req.send().timeout(_timeout);
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode == 200) {
      // Expected: { status, message, profile_image }
      return _decodeJson<Map<String, dynamic>>(res);
    }
    throw Exception('Upload failed: ${res.statusCode} -> ${res.body}');
  }


}
