// lib/auth/app_start_gate.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../storage/token_storage.dart';

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  @override
  void initState() {
    super.initState();
    _routeFromGate();
  }

  Future<void> _routeFromGate() async {
    try {
      // 1) First launch? -> Signup (and mark launched)
      if (await TokenStorage.isFirstLaunch()) {
        await TokenStorage.markLaunched();
        if (!mounted) return;
        Get.offAllNamed(AppRoutes.signup);
        return;
      }

      // 2) Not first launch: check token
      final token = await TokenStorage.getToken();
      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.dashboard); // ensure you have this route
      } else {
        Get.offAllNamed(AppRoutes.signIn);
      }
    } catch (e) {
      // Fallback to sign in on any unexpected error
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simple splash while deciding
    return const Scaffold(
      backgroundColor: Color(0xFF004D99),
      body: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
