import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signin_login_controller.dart';

class SignInLoginScreen extends StatelessWidget {
  const SignInLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInLoginController());

    return Scaffold(
      backgroundColor: const Color(0xFF004D99),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 60),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/discount_icon.png', height: 80),
                      const SizedBox(height: 16),
                      const Text(
                        "LocalLoop helps you save money by showing real-time deals from nearby local shops on expiring, overstocked, and discounted items — reducing food waste while supporting your community.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.goToHome,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Sign Up"),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: controller.goToHome,
                        child: const Text("Log In"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
