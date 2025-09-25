import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

import '../product_details/product_details_controller.dart';
import '../product_details/product_details_view.dart';
import '../routes/app_routes.dart';
import '../storage/token_storage.dart';
import '../addOffer/AddOfferScreen.dart';
import '../createPost/CreatePostScreen.dart';
import '../profile/ProfileScreen.dart';
import '../service/seller_auth_service.dart';
import 'cards/dealCard.dart';
import 'cards/productCard.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController dashboardController = Get.put(
    DashboardController(),
  );
  final SellerAuthService _authService = SellerAuthService();

  /// Current deals shown at the top section.
  List<dynamic> _deals = [];
  bool _showAllDeals = false;

  void _openProductDetails(String productId) async {
    await Get.to(
      () => const ProductDetailsView(),
      arguments: {'product_id': productId},
      binding: BindingsBuilder(() {
        Get.put(ProductDetailsController());
      }),
    );
    await _refreshAll(); // <-- refresh after details page is popped
  }

  Future<void> _refreshAll() async {
    _showAllDeals = false;
    await _loadDeals();
    await dashboardController.loadPostedProducts(refresh: true);
  }

  @override
  void initState() {
    super.initState();
    dashboardController.loadPostedProducts();
    _loadDeals();
  }

  /// Delete a single deal (offer) then hide it from the Current Deal list.
  Future<void> _deleteDeal(String dealId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Error", "Login required");
      return;
    }

    // Helpful debug logs to ensure the ID we send matches what's in the list
    // (keep during dev; remove in prod if you want)
    // ignore: avoid_print
    print('Attempting to delete offer with id="$dealId"');
    for (final d in _deals) {
      // ignore: avoid_print
      print(
        'Deals in list -> id:${d['id']} product_id:${d['product_id']} offer_id:${d['offer_id']}',
      );
    }

    try {
      final result = await _authService.deleteItem(
        token: token,
        productId: dealId,
        item: 'offers',
      );

      // ignore: avoid_print
      print('DELETE response handled: $result');

      if (result['status'] == 'success') {
        setState(() {
          _deals.removeWhere((deal) {
            final dId = (deal['id'] ?? deal['product_id'] ?? deal['offer_id'])
                .toString();
            return dId == dealId;
          });
        });
        Get.snackbar("Deleted", result['message'] ?? "Deal removed");
      } else {
        Get.snackbar("Error", result['message'] ?? "Failed to delete deal");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// Delete all offers of a product and then delete the product.
  /// Updates both Current Deals and Products List.
  Future<void> _deleteProductAndOffers(String productId) async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar('Error', 'Login required');
      return;
    }

    try {
      final delOffers = await _authService.deleteItem(
        token: token,
        productId: productId,
        item: 'offers',
      );
      if (delOffers['status'] != 'success') {
        throw Exception(delOffers['message'] ?? 'Failed to delete offers');
      }

      final delProduct = await _authService.deleteItem(
        token: token,
        productId: productId,
        item: 'products',
      );
      if (delProduct['status'] != 'success') {
        throw Exception(delProduct['message'] ?? 'Failed to delete product');
      }

      setState(() {
        // Remove from Current Deals if present
        _deals.removeWhere((deal) {
          final dId = (deal['id'] ?? deal['product_id'] ?? deal['offer_id'])
              .toString();
          return dId == productId;
        });

        // Remove from Posted Products (GetX list)
        dashboardController.postedProducts.removeWhere(
          (p) => p['id'].toString() == productId,
        );
      });

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
      final deals = await _authService.getCurrentDeals(
        token,
        page: 1,
        limit: 5,
      );
      setState(() {
        _deals = List<dynamic>.from(deals);
        _showAllDeals = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error loading deals: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null, // No AppBar
      body: SafeArea(
        top: true,
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await _loadDeals();
            await dashboardController.loadPostedProducts(refresh: true);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top 3 buttons
                Row(
                  children: [
                    Expanded(
                      child: _dashboardIconButton(
                        Icons.add_circle_outline,
                        'Create',
                        Color(0xFFFFBC82),
                        onTap: () async {
                          await Get.to(() => const CreatePostScreen());
                          await _refreshAll(); // <-- refresh after returning
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _dashboardIconButton(
                        Icons.local_offer_outlined,
                        'Add Offer',
                        Color(0xFF82BCFF),
                        onTap: () async {
                          await Get.to(() => const AddOfferScreen());
                          await _refreshAll();
                        },
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: _dashboardIconButton(
                        Icons.person_outline,
                        'Profile',
                        Color(0xFF82FFCD),
                        onTap: () async {
                          Get.toNamed(AppRoutes.profile);

                          await _refreshAll();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Current Deal section
                // Current Deal section
                const Text(
                  'Current Deal',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                if (_deals.isEmpty)
                  const Text("No current deals available.")
                else ...[
                  // decide how many to show
                  Builder(
                    builder: (_) {
                      final visibleDeals = _showAllDeals
                          ? _deals
                          : _deals.take(2).toList();

                      return Column(
                        children: visibleDeals.map((deal) {
                          // use offer id (or fallback) for delete
                          final offerId = (deal['id'] ?? deal['offer_id'] ?? deal['product_id']).toString();
                          // use product_id for navigation
                          final productId = (deal['product_id'] ?? deal['id']).toString();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7.2),
                            child: dealCard(
                              deal,
                              onDelete: () async => _deleteDeal(offerId),
                              onTap: () => _openProductDetails(productId), // <-- NEW
                            ),
                          );
                        }).toList(),
                      );

                    },
                  ),

                  // “View all / View less” only when there are more than 2
                  if (_deals.length > 2)
                    Align(
                      alignment: Alignment.center,
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => _showAllDeals = !_showAllDeals),
                        icon: Icon(
                          _showAllDeals ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(_showAllDeals ? 'View less' : 'View all'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 32),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 16),

                // Product List section
                const Text(
                  'Products List',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Obx(() {
                  final products = dashboardController.postedProducts;
                  final isLoading = dashboardController.isLoading.value;

                  if (isLoading && products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (products.isEmpty) {
                    return const Center(child: Text('No products posted yet.'));
                  }

                  return Column(
                    children: [
                      ...products.map((product) {
                        final id = product['id'].toString();

                        return Slidable(
                          key: ValueKey(id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.30,
                            children: [
                              CustomSlidableAction(
                                onPressed: (_) async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                        'This will delete the product and all its offers. Continue?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;
                                  await _deleteProductAndOffers(id);
                                },
                                backgroundColor: Colors.white,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/delete_icon.png',
                                      width: 28,
                                      height: 28,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _openProductDetails(id),
                            child: productCard(product),
                          ),
                        );
                      }).toList(),
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
      ),
    );
  }

  Widget _dashboardIconButton(
    IconData icon,
    String label,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
