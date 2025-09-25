// lib/service/models/SellerProfile.dart

class SellerProfileResponse {
  final String status;             // "success" | "error"
  final String? message;           // optional error/info message
  final SellerProfile? data;       // parsed seller data

  SellerProfileResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory SellerProfileResponse.fromJson(Map<String, dynamic> json) {
    return SellerProfileResponse(
      status: (json['status'] ?? '').toString(),
      message: json['message']?.toString(),
      data: json['data'] != null
          ? SellerProfile.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SellerProfile {
  final String name;
  final String phone;
  final String proPath;
  final String address;
  final String storeName;
  final String storeType;

  /// Nullable because API may return null
  final String? openingTime; // json: "opening_time"
  final String? closingTime; // json: "closing_time"

  SellerProfile({
    required this.name,
    required this.phone,
    required this.proPath,
    required this.address,
    required this.storeName,
    required this.storeType,
    this.openingTime,
    this.closingTime,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      proPath: json['pro_path']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      storeType: json['store_type']?.toString() ?? '',
      openingTime: json['opening_time']?.toString(),
      closingTime: json['closing_time']?.toString(),
    );
  }
}
