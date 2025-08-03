import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import '../storage/token_storage.dart';
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

    Future<void> _deleteProductAndOffers(String productId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar('Error', 'Login required');
      return;
    }

    try {
      // 1️⃣ Delete all offers (affects Current Deals)
      final delOffers = await _authService.deleteItem(
        token: token,
        productId: productId,
        item: 'offers',
      );
      if (delOffers['status'] != 'success') {
        throw Exception(delOffers['message'] ?? 'Failed to delete offers');
      }

      // 2️⃣ Delete the product itself (affects Products List)
      final delProduct = await _authService.deleteItem(
        token: token,
        productId: productId,
        item: 'products',
      );
      if (delProduct['status'] != 'success') {
        throw Exception(delProduct['message'] ?? 'Failed to delete product');
      }

      // 3️⃣ Update your local UI state
      //    • Remove from Current Deals
      setState(() {
        _deals.removeWhere((deal) => deal['id'].toString() == productId);
      });
      //    • Remove from Products List
      dashboardController.postedProducts
          .removeWhere((p) => p['id'].toString() == productId);

      Get.snackbar('Deleted', delProduct['message'] ?? 'Item removed');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
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
      final products = dashboardController.postedProducts;
      final isLoading = dashboardController.isLoading.value;

      // 1. Show loader if first‐load is in progress
      if (isLoading && products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      // 2. No products to show
      if (products.isEmpty) {
        return const Center(child: Text('No products posted yet.'));
      }

      // 3. Display the list
      return Column(
        children: [
          ...products.map((product) {
            final id = product['id'].toString();

            return Slidable(
              key: ValueKey(id),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) async {
                      // 1️⃣ confirm deletion
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: const Text(
                              'This will delete the product and all its offers. Continue?'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirm != true) return;

                      // 2️⃣ run your two‐step delete
                      await _deleteProductAndOffers(id);
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => product(product['id'].toString()), // or navigate to detail page
                child: productCard(product),
              ),
            );
          }).toList(),

          // 4. Show a loader at the bottom if more pages are loading
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
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


