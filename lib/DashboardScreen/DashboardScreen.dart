

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../createPost/AddOfferScreen.dart';
import '../createPost/CreatePostScreen.dart';
import '../profile/ProfileScreen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 10,
        title: Row(
          children: const [

            SizedBox(width: 10),
            Text('9:41', style: TextStyle(color: Colors.black))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dashboardIconButton(
                  Icons.add_circle_outline,
                  'CreatePost',
                  Colors.deepOrange,
                  onTap: () => Get.to(() => const CreatePostScreen()),
                ),

                _dashboardIconButton(Icons.local_offer_outlined, 'add offer', Colors.lightBlue, onTap: () => Get.to(() => const AddOfferScreen())),
                _dashboardIconButton(Icons.person_outline, 'profile', Colors.lightGreen, onTap: () => Get.to(() => const ProfileScreen())),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Current Deal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _dealCard(),
            const SizedBox(height: 5),
            _dealCard(),
            const Align(
              alignment: Alignment.centerRight,
              child: Text('View all ▼', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            const Text('Products List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (_, index) => _productCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardIconButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _dealCard() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset('assets/watch1.png', width: 40, height: 40),
      title: const Text('Fossil Grant Chronograph...', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Exp May 10, 2025 at 9:00 AM'),
      trailing: const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('\$45  ', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
          Text('\$34', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          Icon(Icons.close, size: 18, color: Colors.black),
        ],
      ),
    );
  }

  Widget _productCard() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.asset('assets/watch1.png', width: 40, height: 40),
      title: const Text('Fossil Neutra Chronograph Ocean'),
      subtitle: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('\$34  ', style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.star, color: Colors.orange, size: 16),
              Text(' 4.5 Rating')
            ],
          ),
          Text('May 10, 2025 at 9:00 AM'),
        ],
      ),
    );
  }
}
