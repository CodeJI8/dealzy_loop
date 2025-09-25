import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:seller_loop/auth/signin_screen.dart';
import '../../service/seller_auth_service.dart';
import '../widgets/card_shell.dart';
import '../widgets/details_step1.dart';
import '../widgets/phone_password_step.dart';
import '../widgets/signup_intro.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  final openingTimeController = TextEditingController(); // "hh:mm AM/PM"
  final closingTimeController = TextEditingController(); // "hh:mm AM/PM"
  final postalCodeController = TextEditingController();

  // state
  String selectedStoreType = 'Retail';
  String profileImagePath = '';
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  int stepIndex = 0;
  bool _isLoading = false;


  final SellerAuthService _authService = SellerAuthService();

  void nextStep() => setState(() => stepIndex = (stepIndex + 1).clamp(0, 3));
  void previousStep() => setState(() => stepIndex = (stepIndex - 1).clamp(0, 3));

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    storeNameController.dispose();
    emailController.dispose();
    storeAddressController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    postalCodeController.dispose();
    super.dispose();
  }

  void goToSignIn() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignInScreen()));
  }

  /// Parse "HH:MM" or "hh:mm AM/PM" into a TimeOfDay (24h internally).
  TimeOfDay? _parseDisplay(String input) {
    final s = input.trim().toUpperCase().replaceAll('.', '');
    if (s.isEmpty) return null;

    final r12 = RegExp(r'^(\d{1,2}):(\d{2})\s*(AM|PM)$');
    final m12 = r12.firstMatch(s);
    if (m12 != null) {
      int h = int.parse(m12.group(1)!);
      final m = int.parse(m12.group(2)!);
      final period = m12.group(3)!;
      if (h < 1 || h > 12 || m < 0 || m > 59) return null;
      if (period == 'AM') {
        if (h == 12) h = 0;
      } else {
        if (h != 12) h += 12;
      }
      return TimeOfDay(hour: h, minute: m);
    }

    final r24 = RegExp(r'^(\d{1,2}):(\d{2})$');
    final m24 = r24.firstMatch(s);
    if (m24 != null) {
      final h = int.parse(m24.group(1)!);
      final m = int.parse(m24.group(2)!);
      if (h < 0 || h > 23 || m < 0 || m > 59) return null;
      return TimeOfDay(hour: h, minute: m);
    }
    return null;
  }

  /// Convert display time to API "HH:mm:ss"
  String? _buildTimeFromDisplay(String display) {
    if (display.trim().isEmpty) return null;
    final t = _parseDisplay(display);
    if (t == null) throw 'Please use HH:MM or hh:mm AM/PM';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm:00';
  }

  String _formatTime12(TimeOfDay t) {
    final h12 = (t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod).toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h12:$mm $period';
  }

  Future<void> _pickTime({required bool isOpening}) async {
    final current = isOpening ? openingTimeController.text : closingTimeController.text;
    TimeOfDay initial = _parseDisplay(current) ?? TimeOfDay.now();

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted12 = _formatTime12(picked);
      if (isOpening) {
        openingTimeController.text = formatted12;
      } else {
        closingTimeController.text = formatted12;
      }
      setState(() {});
    }
  }

  Future<void> _submitDetailsStep() async {
    if (profileImagePath.isEmpty) {
      Get.snackbar('Error', 'Please select a profile image');
      return;
    }

    final postalRaw = postalCodeController.text.trim();
    if (postalRaw.isEmpty) {
      Get.snackbar('Missing field', 'Postal code is required');
      return;
    }

    // Basic UK postcode validation (accepts common formats like SW1A 1AA, W1D 3QF)
    final ukPostcodeRegex = RegExp(r'^[A-Za-z]{1,2}\d[A-Za-z\d]?\s?\d[A-Za-z]{2}$');
    if (!ukPostcodeRegex.hasMatch(postalRaw)) {
      Get.snackbar('Invalid postal code', 'Please enter a valid UK postcode (e.g., SW1A 1AA)');
      return;
    }

    // Normalize to uppercase and single space before sending (optional but tidy)
    final postal = postalRaw.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');

    String? openingTime;
    String? closingTime;
    try {
      openingTime = _buildTimeFromDisplay(openingTimeController.text);
      closingTime = _buildTimeFromDisplay(closingTimeController.text);
    } catch (e) {
      Get.snackbar('Invalid time', e.toString());
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _authService.registerSeller(
        name: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        storeName: storeNameController.text.trim(),
        storeType: selectedStoreType,
        email: emailController.text.trim(),
        address: storeAddressController.text.trim(),
        imagePath: profileImagePath,
        openingTime: openingTime,
        closingTime: closingTime,
        postalCode: postal,
      );

      // ---- Map backend postcode failure to a friendly snackbar ----
      final status = (response['status'] ?? '').toString().toLowerCase();
      final message = (response['message'] ?? '').toString();

      if (status != 'success') {
        if (message.toLowerCase().contains('cannot fetch postcode api')) {
          Get.snackbar('Invalid postal code', 'Please enter a valid UK postcode');
          return;
        }
        Get.snackbar('Failed', message.isNotEmpty ? message : 'Unknown error');
        return;
      }
      // -------------------------------------------------------------

      Get.snackbar('Success', 'Registration successful');
      Get.off(() => const SignInScreen());
    } catch (e) {
      // If your backend sometimes throws this exact message via non-200 paths, catch & map it here too.
      final msg = e.toString().toLowerCase();
      if (msg.contains('cannot fetch postcode api')) {
        Get.snackbar('Invalid postal code', 'Please enter a valid UK postcode');
        return;
      }
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (stepIndex > 0) {
          previousStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFF004D99),
        appBar:  AppBar(
          backgroundColor: const Color(0xFF004D99),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: previousStep,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final kb = MediaQuery.of(context).viewInsets.bottom;
            const double baseTop = 140.0;
            const double minTop = 24.0;
            final double maxShift = baseTop - minTop;
            final double shiftUp = kb.clamp(0.0, maxShift);

            return SafeArea(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (stepIndex == 2 || stepIndex == 1) ...[
                    // --- For DetailsStep1: Logo overlaps the card ---
                    Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Card pushed down a bit
                            Container(
                              margin: const EdgeInsets.only(top: 40, left: 10, right: 10), // 👈 add side margin
                              child: CardShell(
                                maxHeight: constraints.maxHeight - 100,
                                child: _buildStepView(),
                              ),
                            ),

                            // Logo overlaps top of the card
                            Positioned(
                              top: -50,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Image.asset(
                                  'assets/ic_shopcenter.png',
                                  width: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]
                  else ...[
                    // --- Default flow for step 0 & 1 ---
                    Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedScale(
                        scale: kb > 0 ? 0.9 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        child: Image.asset(
                          'assets/ic_shopcenter.png',
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: baseTop,
                      left: 10,
                      right: 10,
                      child: Transform.translate(
                        offset: Offset(0, -shiftUp),
                        child: CardShell(
                          maxHeight: constraints.maxHeight - (baseTop - shiftUp) - 24,
                          child: _buildStepView(),
                        ),
                      ),
                    ),
                  ]
                ],
              )
              ,
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepView() {
    switch (stepIndex) {
      case 0:
        return SignUpIntro(
          onSignUpTap: nextStep,
          onLoginTap: goToSignIn,
        );
      case 1:
        return PhonePasswordStep(
          phoneController: phoneController,
          passwordController: passwordController,
          confirmPasswordController: confirmPasswordController,
          openingTimeController: openingTimeController,
          closingTimeController: closingTimeController,
          hidePassword: _hidePassword,
          hideConfirmPassword: _hideConfirmPassword,
          onToggleHidePassword: () => setState(() => _hidePassword = !_hidePassword),
          onToggleHideConfirmPassword: () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
          onPickOpeningTime: () => _pickTime(isOpening: true),
          onPickClosingTime: () => _pickTime(isOpening: false),
          onConfirm: nextStep,
          onGoToLogin: goToSignIn,
        );
      case 2:
        return DetailsStep1(
          profileImagePath: profileImagePath,
          onPickImage: (path) => setState(() => profileImagePath = path),
          usernameController: usernameController,
          emailController: emailController,
          storeNameController: storeNameController,
          storeAddressController: storeAddressController,
          postalCodeController: postalCodeController,
          selectedStoreType: selectedStoreType,
          onStoreTypeChanged: (v) => setState(() => selectedStoreType = v),
          onSubmit: _submitDetailsStep,
          isLoading: _isLoading,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
