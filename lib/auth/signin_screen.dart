import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../DashboardScreen/DashboardScreen.dart';
// Replace with your actual dashboard screen

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        const TextField(
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
                        const TextField(
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
                            onPressed: () {
                              Get.to(() => const DashboardScreen());
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
