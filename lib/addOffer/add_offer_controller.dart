import 'package:get/get.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class AddOfferController extends GetxController {
  AddOfferController({SellerAuthService? authService})
      : _authService = authService ?? SellerAuthService();

  final SellerAuthService _authService;

  Future<void> addOffer({
    required String productId,
    required String discount,
    required String offerCategory, // 'regular' | 'expiring_soon' | 'clearance'
    String? expiryDate,            // only for non-regular
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Error", "Please login first.");
      return;
    }

    try {
      final res = await _authService.addOffer(
        token: token,
        productId: productId,
        discount: discount,
        offerCategory: offerCategory,
        expiryDate: expiryDate,
      );

      if (res['status'] == 'success') {
        Get.snackbar("Success", res['message'] ?? "Offer added successfully");
      } else {
        Get.snackbar("Failed", res['message'] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
