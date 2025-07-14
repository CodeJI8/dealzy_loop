import 'package:seller_loop/createPost/CreatePostScreen.dart';
import 'package:seller_loop/home/home_view.dart';
import 'package:seller_loop/notifications/notification_view.dart';
import 'package:seller_loop/profile/ProfileScreen.dart';
import 'package:seller_loop/routes/app_routes.dart';
import 'package:seller_loop/splash/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'auth/signin_screen.dart';
import 'auth/signup_screen.dart';
import 'createPost/AddOfferScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // Set according to your design reference
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'ShopCenter',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.signup,
          getPages: [
            GetPage(name: AppRoutes.splash, page: () => WelcomeView()),
            GetPage(name: AppRoutes.addOffer, page: () => AddOfferScreen()),
            GetPage(name: AppRoutes.signIn, page: () => SignInScreen()),
            GetPage(name: AppRoutes.home, page: () => HomeView()),
            GetPage(name: AppRoutes.signup, page: () => const SignUpScreen()),
            GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
            GetPage(name: AppRoutes.notification, page: () => const NotificationView()),
            GetPage(name: AppRoutes.createPost, page: () => const CreatePostScreen()),


          ],
        );
      },
    );
  }
}
