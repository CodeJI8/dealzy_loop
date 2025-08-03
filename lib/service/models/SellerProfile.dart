// lib/service/models/seller_profile_response.dart

class SellerProfile {
  final String name;
  final String phone;
  final String proPath;
  final String address;
  final String storeName;
  final String storeType;

  SellerProfile({
    required this.name,
    required this.phone,
    required this.proPath,
    required this.address,
    required this.storeName,
    required this.storeType,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      name: json['name'] as String,
      phone: json['phone'] as String,
      proPath: json['pro_path'] as String,
      address: json['address'] as String,
      storeName: json['store_name'] as String,
      storeType: json['store_type'] as String,
    );
  }
}

class SellerProfileResponse {
  final String status;
  final SellerProfile? data;
  final String? message;

  SellerProfileResponse({
    required this.status,
    this.data,
    this.message,
  });

  factory SellerProfileResponse.fromJson(Map<String, dynamic> json) {
    return SellerProfileResponse(
      status: json['status'] as String,
      data: json['data'] != null
          ? SellerProfile.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] as String?,
    );
  }
}
