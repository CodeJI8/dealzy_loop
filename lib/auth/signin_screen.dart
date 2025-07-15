import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../DashboardScreen/DashboardScreen.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
// Replace with your actual dashboard screen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  @override
  void initState() {
    super.initState();
    checkTokenAndNavigate();
  }

  void checkTokenAndNavigate() async {
    try {
      final token = await TokenStorage.getToken();
      print('TOKEN FROM STORAGE: $token');

      if (token != null && token.isNotEmpty) {
        print('Navigating to DashboardScreen...');
        Get.off(() => DashboardScreen());
      } else {
        print('No token found.');
      }
    } catch (e, stacktrace) {
      print('❌ Exception while accessing SharedPreferences: $e');
      print('📄 Stacktrace:\n$stacktrace');
    }
  }


  @override
  Widget build(BuildContext context) {
    print('🔥 SignInScreen build method called');


    final phoneController = TextEditingController();
    final passwordController = TextEditingController();



    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF004D99),
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset('assets/ic_shopcenter.png', width: 160, height: 160),
                  const SizedBox(height: 16),

                  // White container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Welcome back! Find fresh local deals & save today.\nSign in now!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // Phone number
                         TextField(
                           controller: phoneController,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Enter your phone number',
                            labelStyle: TextStyle(fontSize: 14),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Password
                         TextField(
                           controller: passwordController,
                          obscureText: true,
                          style: TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: 14),
                            suffixIcon: Icon(Icons.visibility_off),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: Forget password
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Color(0xFF0C3D78),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm button
                        Center(
                          child: ElevatedButton(
                              onPressed: () async {
                                final phone = phoneController.text.trim();
                                final password = passwordController.text;

                                if (phone.isEmpty || password.isEmpty) {
                                  Get.snackbar('Missing Fields', 'Please enter both phone and password');
                                  return;
                                }

                                try {
                                  final authService = SellerAuthService();
                                  final response = await authService.loginSeller(
                                    phone: phone,
                                    password: password,
                                  );

                                  if (response['status'] == 'success') {
                                    final user = response['user'];
                                    final token = user['token'];
                                    final name = user['name'];

                                    await TokenStorage.saveToken(token); // ✅ Save token

                                    Get.snackbar('Success', 'Welcome back, $name!');
                                    Get.off(() =>  DashboardScreen());
                                  } else {
                                    Get.snackbar('Login Failed', response['message'] ?? 'Something went wrong');
                                  }
                                } catch (e) {
                                  Get.snackbar('Error', e.toString());
                                }
                              },


                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C3D78),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(180, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Confirm'),
                          ),
                        ),
                        const SizedBox(height: 60), // space for character overlap
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            const Text(
                              "If you don’t have an account, just",
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/signup'),
                              child: const Text(
                                "Sign up now!",
                                style: TextStyle(
                                  color: Color(0xFF0C3D78),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Characters (outside white container)
            Positioned(
              bottom: 20,
              left: 0,
              child: Image.asset(
                'assets/left_character.png',
                width: screenWidth * 0.30,
                height: screenWidth * 0.50,
              ),
            ),
            Positioned(
              bottom: 20,
              right: 0,
              child: Image.asset(
                'assets/right_character.png',
                width: screenWidth * 0.30,
                height: screenWidth * 0.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
