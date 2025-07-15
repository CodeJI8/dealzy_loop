// lib/models/post_product_response.dart

class PostProductResponse {
  final String status;
  final String message;

  PostProductResponse({
    required this.status,
    required this.message,
  });

  factory PostProductResponse.fromJson(Map<String, dynamic> json) {
    return PostProductResponse(
      status: json['status'] ?? 'error',
      message: json['message'] ?? '',
    );
  }
}
