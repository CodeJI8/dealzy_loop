import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../routes/app_routes.dart'; // make sure this exists

class WelcomeController extends GetxController {
  var step = 1.obs;

  void nextStep() {
    step.value++;
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted || status.isDenied) {
      // ✅ Either granted or temporarily denied, still navigate
      Get.toNamed(AppRoutes.signIn);
    } else if (status.isPermanentlyDenied) {
      // ⚠️ Open app settings for manual permission
      await openAppSettings();
      Get.snackbar("Permission Required", "Please allow location access from settings.");
    } else {
      // 🔒 Just in case for other edge states (like restricted)
      Get.toNamed(AppRoutes.signIn);
    }
  }

}
