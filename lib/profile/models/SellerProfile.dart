class SellerProfile {
  final String name;
  final String phone;
  final String proPath;
  final String address;
  final String storeName;
  final String storeType;

  /// These two are optional (nullable) because API may return null
  final String? openingTime;
  final String? closingTime;

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
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      proPath: json['pro_path'] ?? '',
      address: json['address'] ?? '',
      storeName: json['store_name'] ?? '',
      storeType: json['store_type'] ?? '',
      openingTime: json['opening_time'], // comes from API
      closingTime: json['closing_time'], // comes from API
    );
  }
}
