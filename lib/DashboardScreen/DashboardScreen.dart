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
              // Top 3 buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dashboardIconButton(
                    Icons.add_circle_outline,
                    'CreatePost',
                    Colors.deepOrange,
                    onTap: () => Get.to(() => CreatePostScreen()),
                  ),
                  _dashboardIconButton(
                    Icons.local_offer_outlined,
                    'add offer',
                    Colors.lightBlue,
                    onTap: () => Get.to(() => const AddOfferScreen()),
                  ),
                  _dashboardIconButton(
                    Icons.person_outline,
                    'profile',
                    Colors.lightGreen,
                    onTap: () => Get.to(() => const ProfileScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Current Deal section
              const Text('Current Deal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _deals.isEmpty
                  ? const Text("No current deals available.")
                  : Column(
                children: _deals
                    .map((deal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _dealCard(deal),
                ))
                    .toList(),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('View all ▼', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),

              // Product List section
              const Text('Products List',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              Obx(() {
                if (dashboardController.isLoading.value &&
                    dashboardController.postedProducts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
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
                        padding: EdgeInsets.all(16),
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

  Widget _dealCard(dynamic deal) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Image.network(
        deal['product_image'] ?? '',
        width: 40,
        height: 40,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/watch1.png', width: 40, height: 40),
      ),
      title: Text(
        deal['product_name'] ?? 'No name',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Exp ${deal['expiry_date'] ?? ''}'),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\৳${deal['price'] ?? ''}',
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
          Text(
            '\৳${deal['discount_price'] ?? ''}',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
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
        width: 60,
        height: 60,
        errorBuilder: (_, __, ___) => Image.asset('assets/watch1.png'),
      ),
      title: Text(product['product_name'] ?? 'Unnamed'),
      subtitle: Text('৳${product['price'] ?? '0'}'),
    );
  }
}
