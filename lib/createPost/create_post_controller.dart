import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service/models/post_product_request.dart';
import '../service/models/post_product_response.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class CreatePostController extends GetxController {
  // ── Services ─────────────────────────────────────────────
  final SellerAuthService _authService = SellerAuthService();
  final ImagePicker picker = ImagePicker();

  // ── Reactive State ──────────────────────────────────────
  /// The list of images (with one trailing `null` slot for “Add Image”).
  RxList<File?> selectedImages = <File?>[null].obs;

  /// Category data
  RxList<dynamic> categories        = <dynamic>[].obs;
  RxBool         isLoadingCategories = true.obs;
  RxString       selectedCategory    = ''.obs;

  /// Simple text fields
  RxString productName = ''.obs;
  RxString brand       = ''.obs;
  RxString model       = ''.obs;
  RxString price       = ''.obs;
  RxString stock       = ''.obs;
  RxString description = ''.obs;

  /// **NEW**: Lists for multi-select tags
  RxList<String> selectedColors = <String>[].obs;
  RxList<String> variants       = <String>[].obs;

  /// Loading flag for submit button
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  /// Adds a new color tag if non-empty & not already present
  void addColor(String value) {
    final color = value.trim();
    if (color.isNotEmpty && !selectedColors.contains(color)) {
      selectedColors.add(color);
    }
  }

  // ── Image Picker / Remover ──────────────────────────────

  /// Pick an image into slot [index].
  /// If that was the last slot, append a new `null` slot at the end.
  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    if (index < selectedImages.length) {
      selectedImages[index] = file;
    } else {
      selectedImages.add(file);
    }
    // ensure one empty slot at end
    if (selectedImages.last != null) {
      selectedImages.add(null);
    }
  }

  /// Remove the image at [index], then clean up extra `null` slots.
  void removeImage(int index) {
    if (index < selectedImages.length) {
      selectedImages[index] = null;
    }
    // ensure one trailing null
    if (selectedImages.isEmpty || selectedImages.last != null) {
      selectedImages.add(null);
    }
    // drop extra null if there are two
    if (selectedImages.length >= 2 &&
        selectedImages[selectedImages.length - 2] == null &&
        selectedImages.last                       == null) {
      selectedImages.removeLast();
    }
  }

  // ── Category Loader ─────────────────────────────────────

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

  // ── Color & Variant Helpers ─────────────────────────────

  /// Toggle a color on/off in the selection.
  void toggleColor(String color) {
    if (selectedColors.contains(color)) {
      selectedColors.remove(color);
    } else {
      selectedColors.add(color);
    }
  }

  /// Add a new variant tag (if not empty / duplicate).
  void addVariant(String v) {
    final t = v.trim();
    if (t.isNotEmpty && !variants.contains(t)) {
      variants.add(t);
    }
  }

  /// Remove an existing variant tag.
  void removeVariant(String v) {
    variants.remove(v);
  }

  // ── Submit Product ──────────────────────────────────────

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
      final request = PostProductRequest(
        categoryId:  selectedCategory.value,
        productName: productName.value,
        brand:       brand.value,
        model:       model.value,
        price:       double.tryParse(price.value)     ?? 0.0,
        stock:       int.tryParse(stock.value)        ?? 0,
        description: description.value,
        // turn your lists into arrays, or null if empty:
        colors:   selectedColors.isNotEmpty ? selectedColors.toList() : null,
        variants: variants.isNotEmpty       ? variants.toList()       : null,
        imageFiles: selectedImages
            .where((f) => f != null)
            .cast<File>()
            .toList(),
      );

      final resp = await _authService.postProduct(
        token: token,
        requestModel: request,
      );

      Get.snackbar(
        resp.status.capitalizeFirst ?? 'Status',
        resp.message,
      );
    } catch (e) {
      Get.snackbar("Upload Failed", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
