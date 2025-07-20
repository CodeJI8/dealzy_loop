import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../addOffer/AddOfferScreen.dart';
import '../createPost/CreatePostScreen.dart';
import '../profile/ProfileScreen.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import '../viewProduct/ProductViewPage.dart';
import 'cards/dealCard.dart';
import 'cards/productCard.dart';
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
                  child: dealCard(deal),
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
                    ...dashboardController.postedProducts.map((product) {
                      return InkWell(
                        onTap: () async {
                          try {
                            final resp = await SellerAuthService()
                                .getProductDetails(product['id'].toString());
                            final data = resp['data'] as Map<String, dynamic>?;
                            if (data != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductViewPage(productDetails: data),
                                ),
                              );
                            } else {
                              Get.snackbar('Error', 'Product details not found.');
                            }
                          } catch (e) {
                            Get.snackbar('Error', 'Failed to fetch product details.');
                          }
                        },
                        child: productCard(product),
                      );
                    }).toList(),



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



}
