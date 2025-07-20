import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../DashboardScreen/DashboardScreen.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkTokenAndNavigate();
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void checkTokenAndNavigate() async {
    try {
      final token = await TokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        Get.off(() => DashboardScreen());
      }
    } catch (e, stacktrace) {
      print('❌ Token access error: $e');
      print('📄 Stacktrace:\n$stacktrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,  // ← Prevents body shift when keyboard opens
      backgroundColor: const Color(0xFF004D99),
      body: SafeArea(
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer transparent container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 21.6, vertical: 21.6),
                padding: const EdgeInsets.only(top: 21.6, bottom: 63),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14.4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Inner white container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 21.6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "\"Welcome back! Find fresh local deals & save today.\nSign in now!\"",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 18),

                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 11.7),
                            decoration: InputDecoration(
                              hintText: 'enter your phone number',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14.4,
                                vertical: 10.8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10.8),

                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: const TextStyle(fontSize: 11.7),
                            decoration: InputDecoration(
                              hintText: 'password',
                              suffixIcon: const Icon(Icons.visibility_off, size: 21.6),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14.4,
                                vertical: 10.8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                          const SizedBox(height: 7.2),

                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                // Add forgot password navigation here if needed
                              },
                              child: const Text(
                                'Forget Password?',
                                style: TextStyle(
                                  fontSize: 10.8,
                                  color: Color(0xFF0C3D78),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Login button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SizedBox(
                              width: screenWidth * 0.85,
                              height: 40.5,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final phone = phoneController.text.trim();
                                  final password = passwordController.text;

                                  if (phone.isEmpty || password.isEmpty) {
                                    Get.snackbar(
                                      'Missing Fields',
                                      'Please enter both phone and password',
                                    );
                                    return;
                                  }

                                  try {
                                    final authService = SellerAuthService();
                                    final response = await authService.loginSeller(
                                      phone: phone,
                                      password: password,
                                    );

                                    if (response['status'] == 'success') {
                                      final token = response['user']['token'];
                                      final name = response['user']['name'];
                                      await TokenStorage.saveToken(token);
                                      Get.snackbar(
                                        'Success',
                                        'Welcome back, $name!',
                                      );
                                      Get.off(() => DashboardScreen());
                                    } else {
                                      Get.snackbar(
                                        'Login Failed',
                                        response['message'] ?? 'Something went wrong',
                                      );
                                    }
                                  } catch (e) {
                                    Get.snackbar('Error', e.toString());
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0C3D78),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: const Text(
                                  'confirm',
                                  style: TextStyle(fontSize: 12.6),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 45),

                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.center,
                            ),
                            onPressed: () => Get.toNamed('/signup'),
                            child: const Text.rich(
                              TextSpan(
                                text: "If you don’t have an account, just ",
                                style: TextStyle(fontSize: 11.7),
                                children: [
                                  TextSpan(
                                    text: "Sign up now!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0C3D78),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // These images will stay fixed at 100px from bottom
              Positioned(
                bottom: 100,
                left: 0,
                child: Image.asset(
                  'assets/left_character.png',
                  width: screenWidth * 0.225,
                ),
              ),
              Positioned(
                bottom: 100,
                right: 0,
                child: Image.asset(
                  'assets/right_character.png',
                  width: screenWidth * 0.225,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
