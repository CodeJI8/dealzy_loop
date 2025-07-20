import 'package:get/get.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import '../viewProduct/ProductViewPage.dart';

class DashboardController extends GetxController {
  final SellerAuthService _authService = SellerAuthService();

  var postedProducts = <dynamic>[].obs;
  var isLoading = false.obs;
  int currentPage = 1;
  final int limit = 15;
  bool hasMore = true;

  Future<void> loadPostedProducts({bool refresh = false}) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    if (refresh) {
      currentPage = 1;
      postedProducts.clear();
      hasMore = true;
    }

    if (!hasMore || isLoading.value) return;

    isLoading.value = true;

    try {
      final newProducts = await _authService.getPostedProducts(token, page: currentPage, limit: limit);
      postedProducts.addAll(newProducts);
      hasMore = newProducts.length == limit;
      if (hasMore) currentPage++;
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }



}




