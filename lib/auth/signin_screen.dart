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

  // 👇 state for password visibility
  bool _obscure = true;

  // 👇 change these to your actual asset paths for the eye icons
  static const String _eyeOpenAsset = 'assets/icons/eye_open.png';
  static const String _eyeClosedAsset = 'assets/icons/eye_closed.png';

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  Widget _passwordSuffixIcon() {
    // Use asset icon; if asset missing at runtime, fall back to Material icon safely.
    return GestureDetector(
      onTap: () => setState(() => _obscure = !_obscure),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          _obscure ? _eyeClosedAsset : _eyeOpenAsset,
          width: 22,
          height: 22,
          errorBuilder: (_, __, ___) => Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            size: 22,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF004D99),
      body: SafeArea(
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ===== Card shell =====
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 21.6, vertical: 21.6),
                padding: const EdgeInsets.only(top: 48, bottom: 63),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14.4),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Inner white card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 21.6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8), // keep space under overlapped logo
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "\Welcome back! Find fresh local deals & save today.\n",
                                  style: TextStyle(
                                    fontSize: 12,

                                  ),
                                ),
                                TextSpan(
                                  text: "Sign in now!",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold, // 👈 makes it bold
                                    color: Colors.black,    // optional: highlight in your theme color
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 18),

                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 11.7),
                            decoration: InputDecoration(
                              hintText: 'Enter your phone number',
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
                            obscureText: _obscure,
                            style: const TextStyle(fontSize: 11.7),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              suffixIcon: _passwordSuffixIcon(), // 👈 asset-based toggle
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
                              onTap: () {Get.toNamed('/forget-password');},
                              child: const Text(
                                'Forget Password?',
                                style: TextStyle(
                                  fontSize: 12,
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
                                      final token = response['user']['token'];
                                      final name = response['user']['name'];

                                      // ✅ Save token using your TokenStorage helper
                                      await TokenStorage.saveToken(token);

                                      Get.snackbar('Success', 'Welcome back, $name!');
                                      Get.off(() => DashboardScreen());
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                ),
                                child: const Text('Confirm', style: TextStyle(fontSize: 12.6)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

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
                                children: [
                                  TextSpan(
                                    text: "If you don’t have an account, just\n", // 👈 added \n
                                    style: TextStyle(fontSize: 11.7),
                                  ),
                                  TextSpan(
                                    text: "Sign up now!",
                                    style: TextStyle(
                                      fontSize: 11.7,
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

                    // ===== Overlapped logo on top of the card =====
                    Positioned(
                      top: -120, // negative to overlap
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(6),

                          child: Image.asset(
                            'assets/ic_shopcenter.png', // 👈 your logo
                            width: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Decorative characters (fixed 100px from bottom)
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
