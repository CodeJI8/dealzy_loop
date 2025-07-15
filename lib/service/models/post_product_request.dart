import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PostProductRequest {
  final String categoryId;
  final String productName;
  final String brand;
  final String model;
  final double price;
  final String description;
  final int stock;
  final List<String>? colors;
  final List<String>? variants;
  final List<File> imageFiles;

  PostProductRequest({
    required this.categoryId,
    required this.productName,
    required this.brand,
    required this.model,
    required this.price,
    required this.description,
    required this.stock,
    this.colors,
    this.variants,
    required this.imageFiles,
  });

  Future<http.MultipartRequest> toMultipartRequest(String url, String token) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    // Required fields
    request.fields['category_id'] = categoryId;
    request.fields['product_name'] = productName;
    request.fields['brand'] = brand;
    request.fields['model'] = model;
    request.fields['price'] = price.toString();
    request.fields['description'] = description;
    request.fields['stock'] = stock.toString();

    // Optional arrays
    colors?.forEach((color) => request.fields['color[]'] = color);
    variants?.forEach((variant) => request.fields['variant[]'] = variant);

    // Images
    for (var file in imageFiles) {
      final mimeType = lookupMimeType(file.path)?.split('/') ?? ['image', 'jpeg'];
      request.files.add(await http.MultipartFile.fromPath(
        'img_paths[]',
        file.path,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    return request;
  }
}
