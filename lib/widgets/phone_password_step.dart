import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class PhonePasswordStep extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController openingTimeController;
  final TextEditingController closingTimeController;

  final bool hidePassword;
  final bool hideConfirmPassword;

  final VoidCallback onToggleHidePassword;
  final VoidCallback onToggleHideConfirmPassword;

  final VoidCallback onPickOpeningTime;
  final VoidCallback onPickClosingTime;

  final VoidCallback onConfirm;
  final VoidCallback onGoToLogin;

  const PhonePasswordStep({
    super.key,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.openingTimeController,
    required this.closingTimeController,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.onToggleHidePassword,
    required this.onToggleHideConfirmPassword,
    required this.onPickOpeningTime,
    required this.onPickClosingTime,
    required this.onConfirm,
    required this.onGoToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Get exclusive local deals before they're gone.\nSign up now!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Enter your phone number',
                      labelStyle: TextStyle(fontSize: 14),
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
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Create a password',
                      labelStyle: const TextStyle(fontSize: 14),
                      suffixIcon: IconButton(
                        onPressed: onToggleHidePassword,
                        icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
                        tooltip: hidePassword ? 'Show password' : 'Hide password',
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: hideConfirmPassword,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.visiblePassword,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Confirm password',
                      labelStyle: const TextStyle(fontSize: 14),
                      suffixIcon: IconButton(
                        onPressed: onToggleHideConfirmPassword,
                        icon: Icon(hideConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        tooltip: hideConfirmPassword ? 'Show password' : 'Hide password',
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: openingTimeController,
                    readOnly: true,
                    enableInteractiveSelection: false,
                    onTap: onPickOpeningTime,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Opening time',
                      hintText: 'HH:MM',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: closingTimeController,
                    readOnly: true,
                    enableInteractiveSelection: false,
                    onTap: onPickClosingTime,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      labelText: 'Closing time',
                      hintText: 'HH:MM',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        final phone = phoneController.text.trim();
                        final password = passwordController.text;
                        final confirmPassword = confirmPasswordController.text;
                        if (phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                          Get.snackbar('Missing Fields', 'Please fill all fields');
                          return;
                        }
                        if (password != confirmPassword) {
                          Get.snackbar('Password Mismatch', 'Passwords do not match');
                          return;
                        }
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3D78),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(40.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9),
                        ),
                      ),
                      child: const Text('Confirm', style: TextStyle(fontSize: 12.6)),
                    ),
                  ),
                  const SizedBox(height: 50),
                  const Text('If you have an account, just ', style: TextStyle(color: Colors.black)),
                  GestureDetector(
                    onTap: onGoToLogin,
                    child: const Text(
                      'Sign in now!',
                      style: TextStyle(
                        color: Color(0xFF0C3D78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Image.asset('assets/left_character.png', width: 120, height: 180),
            ),
            Positioned(
              right: -20,
              bottom: -40,
              child: Image.asset('assets/right_character.png', width: 120, height: 180),
            ),
          ],
        ),
      ],
    );
  }
}
