import 'package:flutter/material.dart';

class SignUpIntro extends StatelessWidget {
  final VoidCallback onSignUpTap;
  final VoidCallback onLoginTap;

  const SignUpIntro({
    super.key,
    required this.onSignUpTap,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/discount_icon.png', height: 80),
            const SizedBox(height: 16),
            const Text(
              "LocalLoop helps you save money by showing real-time deals from nearby local shops on expiring, overstocked, and discounted items — reducing food waste while supporting your community.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSignUpTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3D78),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onLoginTap,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(45),
                  foregroundColor: const Color(0xFF0C3D78),
                  side: const BorderSide(color: Color(0xFFCCCCCC)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Log In"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
