// lib/profile/profile_controller.dart

import 'package:get/get.dart';
import '../service/models/SellerProfile.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class ProfileController extends GetxController {
  final _service = SellerAuthService();

  var isLoading = true.obs;
  var profile = Rxn<SellerProfile>();
  var errorMessage = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    final token = await TokenStorage.getToken();
    if (token == null) {
      errorMessage.value = 'Login required';
      isLoading.value = false;
      return;
    }

    try {
      final resp = await _service.getSellerProfile(token: token);
      if (resp.status == 'success' && resp.data != null) {
        profile.value = resp.data;
      } else {
        errorMessage.value = resp.message ?? 'Unknown error';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
