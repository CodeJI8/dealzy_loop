import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service/models/post_product_request.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import '../DashboardScreen/DashboardScreen.dart';

class CreatePostController extends GetxController {
  final SellerAuthService _authService = SellerAuthService();
  final ImagePicker picker = ImagePicker();

  /// Only store ACTUAL images here (no trailing nulls).
  RxList<File> selectedImages = <File>[].obs;

  // Categories
  RxList<dynamic> categories = <dynamic>[].obs;
  RxBool isLoadingCategories = true.obs;
  RxString selectedCategory = ''.obs;

  // Fields
  RxString productName = ''.obs;
  RxString brand = ''.obs;
  RxString model = ''.obs;
  RxString price = ''.obs;
  RxString stock = ''.obs;
  RxString description = ''.obs;

  // Chips
  RxList<String> selectedColors = <String>[].obs;
  RxList<String> variants = <String>[].obs;

  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // ---- Images ----

  /// If [index] < images.length -> replace; else append.
  Future<void> pickImageForSlot(int index, ImageSource source) async {
    final XFile? x = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (x == null) return;

    final file = File(x.path);
    if (index < selectedImages.length) {
      selectedImages[index] = file;
    } else {
      selectedImages.add(file);
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  bool _validateRequiredFields() {
    // Images: at least one
    if (selectedImages.isEmpty) {
      Get.snackbar(
        'Image required',
        'Please add at least one product image.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // Product name: required & sensible length
    final name = productName.value.trim();
    if (name.isEmpty || name.length < 3) {
      Get.snackbar(
        'Product name required',
        'Please enter a product name (min 3 characters).',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // Category: required
    if (selectedCategory.value.trim().isEmpty) {
      Get.snackbar(
        'Category required',
        'Please select a category.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // Price: required & > 0
    final p = double.tryParse(price.value.trim());
    if (p == null || p <= 0) {
      Get.snackbar(
        'Price required',
        'Please enter a valid price greater than 0.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    // Stock: required & >= 1
    final s = int.tryParse(stock.value.trim());
    if (s == null || s < 1) {
      Get.snackbar(
        'Stock required',
        'Please enter a valid stock (at least 1).',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }




  void _notifyMissingOptionalFields() {
    final missing = <String>[];
    if (brand.value.isEmpty) missing.add('Brand');
    if (model.value.isEmpty) missing.add('Model');
    if (selectedColors.isEmpty) missing.add('Color');
    if (variants.isEmpty) missing.add('Variant');
    if (description.value.isEmpty) missing.add('Description');

    if (missing.isNotEmpty) {
      Get.snackbar(
        'Tip',
        'You can improve your post by adding: ${missing.join(', ')}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ---- Categories ----

  Future<void> loadCategories() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      isLoadingCategories.value = false;
      return;
    }
    try {
      final result = await _authService.getAllCategories(token);
      categories.value = result;
    } catch (e) {
      Get.snackbar("Error loading categories", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ---- Chips ----

  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }

  void addVariant(String v) {
    final t = v.trim();
    if (t.isNotEmpty && !variants.contains(t)) {
      variants.add(t);
    }
  }

  void removeVariant(String v) {
    variants.remove(v);
  }

  // ---- Submit ----

  Future<void> submitProduct() async {
    if (isLoading.value) return;
    isLoading.value = true;

    if (!_validateRequiredFields()) {
      isLoading.value = false; // important to reset
      return;
    }

    // Inform user about optional fields if they’re empty (non-blocking).
    _notifyMissingOptionalFields();

    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Error", "Please login first");
      isLoading.value = false;
      return;
    }

    try {
      final request = PostProductRequest(
        categoryId: selectedCategory.value,
        productName: productName.value,
        brand: brand.value.isNotEmpty ? brand.value : '',
        model: model.value.isNotEmpty ? model.value : '',
        price: double.tryParse(price.value) ?? 0.0,
        stock: stock.value.isNotEmpty ? int.tryParse(stock.value) ?? 0 : 0,
        description: description.value.isNotEmpty ? description.value : '',
        colors: selectedColors.isNotEmpty ? selectedColors.toList() : null,
        variants: variants.isNotEmpty ? variants.toList() : null,
        imageFiles: selectedImages.toList(),
      );

      final resp = await _authService.postProduct(token: token, requestModel: request);

      if (resp.status == "success") {
        Get.snackbar("Upload Successful", resp.message);
        Get.offAll(() => const DashboardScreen());
      } else {
        Get.snackbar("Error", resp.message);
      }
    } catch (e) {
      Get.snackbar("Upload Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

}
