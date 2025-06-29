import 'package:dealzy_loop/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth/signin_login_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ShopCenter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.signIn,
      getPages: [
        GetPage(name: AppRoutes.signIn, page: () => const SignInLoginScreen()),
      ],
    );
  }
}
