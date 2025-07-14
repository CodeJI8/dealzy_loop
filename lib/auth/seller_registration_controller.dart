import 'package:get/get.dart';
import '../service/serviceApi .dart';


class SellerRegistrationController extends GetxController {
  final ServiceApi _service = ServiceApi();

  var isLoading = false.obs;
  var registrationMessage = ''.obs;

  Future<void> registerSeller({
    required String name,
    required String phone,
    required String password,
    required String storeName,
    required String storeType,
    required String address,
    required String otp,
    required String profileImagePath,
  }) async {
    try {
      isLoading.value = true;
      var response = await _service.registerSeller(
        name: name,
        phone: phone,
        password: password,
        storeName: storeName,
        storeType: storeType,
        address: address,
        otp: otp,
        profileImagePath: profileImagePath,
      );
      registrationMessage.value = response.message;
    } catch (e) {
      registrationMessage.value = 'Error: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
