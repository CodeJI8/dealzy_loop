import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../addOffer/AddOfferScreen.dart';
import '../createPost/CreatePostScreen.dart';
import '../profile/ProfileScreen.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController dashboardController = Get.put(DashboardController());
  final SellerAuthService _authService = SellerAuthService();
  List<dynamic> _deals = [];

  @override
  void initState() {
    super.initState();
    dashboardController.loadPostedProducts();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }
    try {
      final deals = await _authService.getCurrentDeals(token, page: 1, limit: 5);
      setState(() {
        _deals = deals;
      });
    } catch (e) {
      print("Error loading deals: $e");
      Get.snackbar("Error", e.toString());
    }
  }

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
            Text('9:41', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadDeals();
          await dashboardController.loadPostedProducts(refresh: true);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top 3 buttons (each ~10% smaller)
              Row(
                children: [
                  Expanded(
                    child: _dashboardIconButton(
                      Icons.add_circle_outline,
                      'Create Post',
                      Colors.deepOrange,
                      onTap: () => Get.to(() => CreatePostScreen()),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _dashboardIconButton(
                      Icons.local_offer_outlined,
                      'Add Offer',
                      Colors.lightBlue,
                      onTap: () => Get.to(() => const AddOfferScreen()),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: _dashboardIconButton(
                      Icons.person_outline,
                      'Profile',
                      Colors.lightGreen,
                      onTap: () => Get.to(() => const ProfileScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18), // was 20

              // Current Deal section
              const Text(
                'Current Deal',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // was 16
              ),
              const SizedBox(height: 9), // was 10
              _deals.isEmpty
                  ? const Text("No current deals available.")
                  : Column(
                children: _deals
                    .map((deal) => Padding(
                  padding: const EdgeInsets.only(bottom: 7.2), // was 8.0
                  child: _dealCard(deal),
                ))
                    .toList(),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('View all ▼', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 18), // was 20

              // Product List section
              const Text(
                'Products List',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // was 16
              ),
              const SizedBox(height: 9), // was 10

              Obx(() {
                if (dashboardController.isLoading.value &&
                    dashboardController.postedProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(28.8), // was 32
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (dashboardController.postedProducts.isEmpty) {
                  return const Text('No products posted yet.');
                }

                return Column(
                  children: [
                    ...dashboardController.postedProducts
                        .map((product) => _productCard(product)),
                    if (dashboardController.isLoading.value)
                      const Padding(
                        padding: EdgeInsets.all(14.4), // was 16
                        child: CircularProgressIndicator(),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardIconButton(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90, // was 100
        padding: const EdgeInsets.symmetric(vertical: 14), // was 16
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9), // was 10
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.black), // default icon ~24 -> 22
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 13), // default ~14
            ),
          ],
        ),
      ),
    );
  }

  Widget _dealCard(dynamic deal) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        deal['product_image'] ?? '',
        width: 36, // was 40
        height: 36, // was 40
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/watch1.png', width: 36, height: 36),
      ),
      title: Text(
        deal['product_name'] ?? 'No name',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(
        'Exp ${deal['expiry_date'] ?? ''}',
        style: const TextStyle(fontSize: 13),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\৳${deal['price'] ?? ''}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
              fontSize: 12, // was default ~13
            ),
          ),
          Text(
            '\৳${deal['discount_price'] ?? ''}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(dynamic product) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        product['product_image'] ?? '',
        width: 54, // was 60
        height: 54, // was 60
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/watch1.png', width: 54, height: 54),
      ),
      title: Text(
        product['product_name'] ?? 'Unnamed',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '৳${product['price'] ?? '0'}',
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
