// lib/profile/profile_controller.dart
import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/signin_screen.dart';
import '../service/models/SellerProfile.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import 'delete_user_service.dart';

class ProfileController extends GetxController {
  final _service = SellerAuthService();
  final ImagePicker _picker = ImagePicker();

  // State
  final isLoading = true.obs;
  final isUploading = false.obs;        // <-- NEW: uploading spinner
  final profile = Rxn<SellerProfile>();
  final errorMessage = Rxn<String>();
  final isDeleting = false.obs;

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

  /// Pick from camera/gallery, upload to /upload_profile.php, then refresh.
  Future<void> changeProfilePhoto(ImageSource source) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar('Login required', 'Please sign in first');
      return;
    }

    final XFile? x = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
      maxHeight: 2000,
    );
    if (x == null) return; // user cancelled

    isUploading.value = true;
    try {
      final resp = await _service.uploadProfileImage(
        token: token,
        imageFile: File(x.path),
      );

      if ((resp['status'] ?? '').toString().toLowerCase() == 'success') {
        // Option A (simple): reload from server so all fields are fresh
        await loadProfile();

        Get.snackbar('Updated', resp['message']?.toString() ?? 'Profile picture updated.');
      } else {
        Get.snackbar('Upload failed', resp['message']?.toString() ?? 'Please try again.');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isUploading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    if (isDeleting.value) return;
    isDeleting.value = true;
    try {
      final resp = await DeleteUserService.deleteUser();
      final status = (resp['status'] ?? '').toString().toLowerCase();

      if (status == 'success') {
        Get.snackbar('Deleted', (resp['message'] ?? 'User Deleted').toString());
        await TokenStorage.clearToken();
        Get.offAll(() => const SignInScreen());
      } else {
        Get.snackbar('Failed', (resp['message'] ?? 'Could not delete').toString());
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isDeleting.value = false;
    }
  }
}
