import 'package:seller_loop/createPost/CreatePostScreen.dart';
import 'package:seller_loop/profile/ProfileScreen.dart';
import 'package:seller_loop/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'auth/signin_screen.dart';
import 'auth/signup_screen.dart';
import 'createPost/AddOfferScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            GetPage(name: AppRoutes.addOffer, page: () => AddOfferScreen()),
            GetPage(name: AppRoutes.signIn, page: () => SignInScreen()),
            GetPage(name: AppRoutes.signup, page: () =>  SignUpScreen()),
            GetPage(name: AppRoutes.profile, page: () =>  ProfileScreen()),
            GetPage(name: AppRoutes.createPost, page: () =>  CreatePostScreen()),


          ],
        );
      },
    );
  }
}
