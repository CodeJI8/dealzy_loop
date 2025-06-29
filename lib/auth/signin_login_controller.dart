import 'package:get/get.dart';
import '../routes/app_routes.dart';

class SignInLoginController extends GetxController {
  void goToHome() {
    Get.toNamed(AppRoutes.home);
  }
}
