class SellerRegistrationResponse {
  final String status;
  final String message;

  SellerRegistrationResponse({
    required this.status,
    required this.message,
  });

  factory SellerRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return SellerRegistrationResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
