import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service/models/post_product_request.dart';
import '../service/models/post_product_response.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class CreatePostController extends GetxController {
  final SellerAuthService _authService = SellerAuthService();
  final ImagePicker picker = ImagePicker();

  RxList<File?> selectedImages = <File?>[].obs;
  RxList<dynamic> categories = [].obs;
  RxBool isLoadingCategories = true.obs;
  RxString selectedCategory = ''.obs;


  // Form field controllers
  final productNameController = ''.obs;
  final brandController = ''.obs;
  final modelController = ''.obs;
  final priceController = ''.obs;
  final descriptionController = ''.obs;
  final stockController = ''.obs;
  final colorController = ''.obs;
  final variantController = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedImages.add(null);
    loadCategories();
  }

  Future<void> pickImage(int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (index < selectedImages.length) {
        selectedImages[index] = File(pickedFile.path);
      } else {
        selectedImages.add(File(pickedFile.path));
      }

      if (selectedImages.length == index + 1) {
        selectedImages.add(null);
      }
    }
  }

  Future<void> loadCategories() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    try {
      final result = await _authService.getAllCategories(token);
      categories.value = result;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> submitProduct() async {
    if (isLoading.value) return;
    isLoading.value = true;

    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Error", "Please login first");
      isLoading.value = false;
      return;
    }

    try {
      final requestModel = PostProductRequest(
        categoryId: selectedCategory.value,
        productName: productNameController.value,
        brand: brandController.value,
        model: modelController.value,
        price: double.tryParse(priceController.value) ?? 0.0,
        description: descriptionController.value,
        stock: int.tryParse(stockController.value) ?? 0,
        colors: colorController.value.isNotEmpty
            ? colorController.value.split(',').map((e) => e.trim()).toList()
            : null,
        variants: variantController.value.isNotEmpty
            ? variantController.value.split(',').map((e) => e.trim()).toList()
            : null,
        imageFiles: selectedImages.whereType<File>().toList(),
      );

      final PostProductResponse response =
      await _authService.postProduct(token: token, requestModel: requestModel);

      print('✅ API Response: ${response.status} - ${response.message}');
      Get.snackbar(response.status.capitalizeFirst ?? 'Status', response.message);
    } catch (e) {
      print('❌ Error submitting product: $e');
      Get.snackbar("Upload Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
