import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/signin_screen.dart';
import '../storage/token_storage.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
        Get.back(); // close dialog
        _logout();
      },
      onCancel: () {
        Get.back(); // just close dialog
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('9:41', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/profile_avatar.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              'hfouzia27',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Where Quality Meets Affordability.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Divider(),
            _infoRow(Icons.store, 'yellow fashion'),
            _infoRow(Icons.location_on, 'jalalabad, sylhet'),
            _infoRow(Icons.phone, '+88 016 4738 723'),
            _infoRow(Icons.category, 'clothing and electrical device'),
            _timingRow(),
            const Spacer(),

            // Logout with confirmation
            GestureDetector(
              onTap: _confirmLogout,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _timingRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.access_time, color: Colors.black),
          SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '10:00 am '),
                  TextSpan(text: '(open)', style: TextStyle(color: Colors.green)),
                  TextSpan(text: ' to 9:30 pm '),
                  TextSpan(text: '(close)', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
