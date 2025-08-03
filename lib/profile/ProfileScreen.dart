// lib/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/signin_screen.dart';
import '../storage/token_storage.dart';
import 'ProfileController.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProfileController());

    Future<void> _logout() async {
      await TokenStorage.clearToken();
      Get.offAll(() => const SignInScreen());
    }

    void _confirmLogout() {
      Get.defaultDialog(
        title: 'Confirm Logout',
        middleText: 'Are you sure you want to log out?',
        textConfirm: 'Yes',
        textCancel: 'No',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          _logout();
        },
        onCancel: () => Get.back(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMessage.value != null) {
          return Center(child: Text(ctrl.errorMessage.value!));
        }
        final p = ctrl.profile.value!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Avatar + Username & Tagline ───────────────────
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(p.proPath),
                        onBackgroundImageError: (_, __) =>
                        const AssetImage('assets/profile_avatar.png')
                        as ImageProvider,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name, // replace with p.name if that is the username
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Where Quality Meets Affordability.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // ─── Info Rows ─────────────────────────────────────
              _infoRow(Icons.store, p.storeName),
              _infoRow(Icons.location_on, p.address),
              _infoRow(Icons.phone, p.phone),
              _infoRow(Icons.category, p.storeType),

              const SizedBox(height: 16),

              // ─── Opening Hours ──────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        children: [
                          const TextSpan(text: '10:00 am '),
                          TextSpan(
                            text: '(open)',
                            style: const TextStyle(color: Colors.green),
                          ),
                          const TextSpan(text: ' to 9:30 pm '),
                          TextSpan(
                            text: '(close)',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ─── Log Out ────────────────────────────────────────
              GestureDetector(
                onTap: _confirmLogout,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.logout, color: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
