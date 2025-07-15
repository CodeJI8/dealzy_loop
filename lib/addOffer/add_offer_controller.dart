import 'package:get/get.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class AddOfferController extends GetxController {
  final SellerAuthService _authService = SellerAuthService();

  Future<void> addOffer({
    required String productId,
    required String discount,
    required String offerCategory,
    String? expiryDate, // only required for 'regular'
  }) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Error", "Please login first.");
      return;
    }

    try {
      final response = await _authService.addOffer(
        token: token,
        productId: productId,
        discount: discount,
        offerCategory: offerCategory,
        expiryDate: expiryDate,
      );

      if (response['status'] == 'success') {
        Get.snackbar("Success", response['message'] ?? "Offer added successfully");
      } else {
        Get.snackbar("Failed", response['message'] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
