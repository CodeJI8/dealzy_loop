// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:seller_loop/profile/ProfileController.dart';
import 'package:seller_loop/update_password/update_password_controller.dart';
import 'package:seller_loop/update_password/update_password_view.dart';

import 'app_start_gate.dart';
import 'forget_password/forget_password_controller.dart';
import 'forget_password/forget_password_view.dart';
import 'otp/otp_verification_controller.dart';
import 'otp/otp_verification_view.dart';
import 'routes/app_routes.dart';

import 'auth/signin_screen.dart';
import 'auth/signup_screen.dart';
import 'addOffer/AddOfferScreen.dart';
import 'createPost/CreatePostScreen.dart';
import 'profile/ProfileScreen.dart';
import 'DashboardScreen/DashboardScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return GetMaterialApp(
          title: 'ShopCenter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            useMaterial3: true,
          ),
          // 👇 Start at the gate; it decides where to go
          initialRoute: AppRoutes.splash,
          getPages: [
            GetPage(name: AppRoutes.splash, page: () => const AppStartGate()),
            GetPage(name: AppRoutes.addOffer, page: () => AddOfferScreen()),
            GetPage(name: AppRoutes.signIn, page: () => const SignInScreen()),
            GetPage(name: AppRoutes.signup, page: () => const SignUpScreen()),

            GetPage(name: AppRoutes.createPost, page: () => const CreatePostScreen()),
            GetPage(name: AppRoutes.dashboard, page: () => const DashboardScreen()),
            GetPage(
              name: '/forget-password',
              page: () => const ForgetPasswordView(),
              binding: BindingsBuilder(() {
                Get.put(ForgetPasswordController());
              }),
            ),

            GetPage(
              name: AppRoutes.otpVerification,
              page: () => const OtpVerificationView(),
              binding: BindingsBuilder(() {
                Get.lazyPut<OtpVerificationController>(() => OtpVerificationController(), fenix: true);
              }),
            ),
            GetPage(
              name: AppRoutes.updatePassword,
              page: () => const UpdatePasswordView(),
              binding: BindingsBuilder(() {
                Get.lazyPut<UpdatePasswordController>(
                      () => UpdatePasswordController(),
                  fenix: true,
                );
              }),

            ),

            GetPage(
              name: AppRoutes.profile,
              page: () => const ProfileScreen(),
              binding: BindingsBuilder(() {
                Get.lazyPut<ProfileController>(() => ProfileController());
              }),
            ),

          ],
        );
      },
    );
  }
}
