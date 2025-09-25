// services/product_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:seller_loop/product_details/product_details_models.dart';

class ProductService {
  /// You can inject a base URL for tests, or let it read from .env at construction time.
  ProductService({String? baseUrl})
      : _base = _normalizeBase(baseUrl ?? dotenv.env['API_BASE_URL'] ?? '');

  final String _base;

  static String _normalizeBase(String s) => s.replaceAll(RegExp(r'/+$'), '');

  String get baseUrl => _base;

  Future<Map<String, dynamic>> fetchDetailsRaw(String productId) async {
    if (_base.isEmpty) {
      throw StateError('API_BASE_URL is empty. Check your .env (and that dotenv.load ran before creating ProductService).');
    }

    final uri = Uri.parse('$_base/product_details.php')
        .replace(queryParameters: {'product_id': productId});

    if (kDebugMode) {
      debugPrint('[ProductService] GET $uri');
    }

    late http.Response res;
    try {
      res = await http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('HTTP error while contacting server.');
    } on FormatException {
      throw Exception('Bad response format from server.');
    }

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Unknown error'}');
    }

    // Parse JSON safely
    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Unexpected JSON type: ${decoded.runtimeType}');
    }

    // Many PHP APIs use: { status: "success", data: {...} } or { status: "success", product: {...} }
    final status = (decoded['status'] as String?)?.toLowerCase();
    if (status != 'success') {
      final msg = decoded['message'] ?? 'API status != success';
      throw Exception(msg.toString());
    }

    // Accept both "data" and "product"
    final payload = decoded['data'] ?? decoded['product'];
    if (payload is! Map) {
      throw Exception('Missing product payload in response.');
    }

    return Map<String, dynamic>.from(payload as Map);
  }

  Future<ProductDetailsData> fetchDetails(String productId) async {
    final data = await fetchDetailsRaw(productId);
    return ProductDetailsData.fromApi(data);
  }
}
