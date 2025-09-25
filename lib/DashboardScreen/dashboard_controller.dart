import 'package:get/get.dart';
import 'package:dio/dio.dart'; // if you use Dio; safe to import even if not used directly
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class DashboardController extends GetxController {
  final SellerAuthService _authService = SellerAuthService();

  final postedProducts = <dynamic>[].obs;
  final isLoading = false.obs;

  int currentPage = 1;
  final int limit = 15;
  bool hasMore = true;

  Future<void> loadPostedProducts({bool refresh = false}) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      await _logoutAndRedirect(message: "Please login first");
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
      final newProducts = await _authService.getPostedProducts(
        token,
        page: currentPage,
        limit: limit,
      );

      postedProducts.addAll(newProducts);
      hasMore = newProducts.length == limit;
      if (hasMore) currentPage++;
    } catch (e) {
      if (_isUnauthorizedError(e)) {
        await _logoutAndRedirect(message: "Session expired. Please log in again.");
        return;
      }
      // fallback for other errors
      // print for dev logs, show friendly message to user
      // ignore: avoid_print

      Get.snackbar('Error', 'Something went wrong. Please login again.');
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  bool _isUnauthorizedError(Object e) {
    // Case 1: Dio
    if (e is DioException) {
      final status = e.response?.statusCode ?? 0;
      return status == 401 || status == 403;
    }
    // Case 2: String/other exceptions with message
    final msg = e.toString().toLowerCase();
    return msg.contains('access denied') ||
        msg.contains('unauthorized') ||
        msg.contains('forbidden');
  }

  Future<void> _logoutAndRedirect({required String message}) async {
    await TokenStorage.clearToken();
    // Remove all previous routes and go to login
    Get.offAllNamed('/login');
    Get.snackbar('Login Required', message);
  }
}
