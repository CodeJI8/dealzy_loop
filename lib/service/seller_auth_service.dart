import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:seller_loop/service/models/post_product_request.dart';

import 'models/SellerProfile.dart';
import 'models/post_product_response.dart';

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

    // ✅ Print the raw response body for debugging
    print('🔁 Response Body: ${response.body}');

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


  Future<List<dynamic>> getCurrentDeals(String token, {int page = 1, int limit = 15}) async {
    final url = Uri.parse('https://dealzyloop.com/api/get_current_deals.php?page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);
    print('🛠️ getCurrentDeals response: ${response.body}');

    if (response.statusCode == 200) {
      final products = data['products'] as List<dynamic>?;

      print('📦 current deal response: ${response.body}');
      if (products != null && products.isNotEmpty) {
        return products;
      } else {
        throw Exception(data['message'] ?? 'No products found');
      }
    } else {
      throw Exception('Failed to fetch deals: ${response.statusCode}');
    }
  }




  Future<PostProductResponse> postProduct({
    required String token,
    required PostProductRequest requestModel,
  }) async {
    final request = await requestModel.toMultipartRequest('$baseUrl/post_products.php', token);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📦 postProduct response: ${response.body}');

    if (response.statusCode == 200) {
      return PostProductResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to post product: ${response.statusCode}");
    }
  }



  Future<List<dynamic>> getPostedProducts(String token, {int page = 1, int limit = 15}) async {
    final url = Uri.parse('$baseUrl/get_posted_products.php?page=$page&limit=$limit');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final data = json.decode(response.body);

    print('🛠️ getPostedProducts response: ${response.body}');

    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['products'] ?? [];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch posted products');
    }
  }



  // ✅ ADD OFFER TO PRODUCT (POST)
  Future<Map<String, dynamic>> addOffer({
    required String token,
    required String productId,
    required String discount,
    required String offerCategory,
    String? expiryDate,
  }) async {
    final url = Uri.parse('$baseUrl/add_offer.php');

    final body = {
      'product_id': productId,
      'discount': discount,
      'offer_category': offerCategory,
    };

    if (offerCategory == 'regular' && expiryDate != null) {
      body['expiry_date'] = expiryDate;
    }

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // ✅ Important
      },
      body: jsonEncode(body), // ✅ send as JSON
    );

    final data = json.decode(response.body);
    print('🟠 add_offer.php response: $data');

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to add offer. Code: ${response.statusCode}');
    }
  }



  // ✅ GET PRODUCT DETAILS BY ID (NO AUTH)
  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    final url = Uri.parse('$baseUrl/product_details.php?product_id=$productId');

    final response = await http.get(url);

    print('🟢 getProductDetails response: ${response.body}');

    final data = json.decode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return data; // You can return data['product'] if needed
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch product details');
    }
  }





  Future<SellerProfileResponse> getSellerProfile({
    required String token,
  }) async {
    final url = Uri.parse('$baseUrl/seller_profile.php');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return SellerProfileResponse.fromJson(decoded);
    } else {
      throw Exception(
          'Failed to load profile. '
              'Code: ${response.statusCode}, '
              'Body: ${response.body}'
      );
    }
  }





  /// ✅ UPDATE PRODUCT (PUT JSON)
  /// Endpoint: /update_product.php
  Future<Map<String, dynamic>> updateProduct({
    required String token,
    required String productId,
    required int stock,
    required double price,
  }) async {
    final url = Uri.parse('$baseUrl/update_product.php');

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'product_id': productId,
        'stock': stock,
        'price': price,
      }),
    );

    print('🟢 updateProduct response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
        "Failed to update product. Code: ${response.statusCode}",
      );
    }
  }

  Future<Map<String, dynamic>> deleteItem({
    required String token,
    required String productId,
    required String item, // 'offers' or 'products'
  }) async {
    final url = Uri.parse('$baseUrl/delete.php');
    final body = jsonEncode({
      'product_id': productId,
      'item': item,
    });

    // 🔍 Log the request
    print('🔴 DELETE $url');
    print('    Authorization: Bearer $token');
    print('    Body: $body');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // 🔍 Log the response
    print('🟢 Response code: ${response.statusCode}');
    print('    Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to delete $item. '
              'Code: ${response.statusCode}, '
              'Body: ${response.body}'
      );
    }
  }







}
