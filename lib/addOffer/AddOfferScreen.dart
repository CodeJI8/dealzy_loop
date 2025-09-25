// lib/addOffer/add_offer_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../product_details/product_details_controller.dart';
import '../product_details/product_details_view.dart';
import '../service/seller_auth_service.dart';

import 'add_offer_controller.dart' hide SellerAuthService;
import 'dialogs/OfferTypeDialog.dart';
import '../storage/token_storage.dart';

class AddOfferScreen extends StatefulWidget {
  const AddOfferScreen({super.key});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final AddOfferController addOfferController = Get.put(AddOfferController());
  final SellerAuthService _authService = SellerAuthService();

  List<dynamic> _allProducts = [];     // full list
  List<dynamic> _postedProducts = [];  // filtered list
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostedProducts();
  }

  Future<void> _loadPostedProducts() async {
    final token = await TokenStorage.getToken();
    if (!mounted) return;
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    try {
      final products = await _authService.getPostedProducts(token, limit: 20);
      setState(() {
        _allProducts = products;
        _postedProducts = products; // initially show all
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _postedProducts = _allProducts);
    } else {
      setState(() {
        _postedProducts = _allProducts.where((p) {
          final name = (p['product_name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.05;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30), // reduce height (default ~56)
        child: AppBar(
          title: const Text(
            'Add Offer',
            style: TextStyle(color: Colors.black, fontSize: 16), // slightly smaller
          ),
          centerTitle: false,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),

      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          children: [
            // 🔍 Search Field
            TextField(
              onChanged: _filterProducts, // call filter
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _postedProducts.isEmpty
                  ? const Center(child: Text("No products found."))
                  : ListView.builder(
                itemCount: _postedProducts.length,
                itemBuilder: (context, index) {
                  final product = _postedProducts[index];
                  return ProductItemCard(
                    product: product,
                    addOfferController: addOfferController,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItemCard extends StatelessWidget {
  final dynamic product;
  final AddOfferController addOfferController;

  const ProductItemCard({
    super.key,
    required this.product,
    required this.addOfferController,
  });

  String _buildDateTimeText(BuildContext context) {
    final created = (product['created_at'] ??
        product['date'] ??
        product['posted_at'])
        ?.toString();
    final timeRaw = (product['time'] ?? product['posted_time'])?.toString();

    String fmtDate(String raw) {
      final d = DateTime.tryParse(raw);
      return d != null ? DateFormat('MMM d, yyyy').format(d) : raw;
    }

    String? fmtTime(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      final hhmm = RegExp(r'^\d{2}:\d{2}(:\d{2})?$');
      if (hhmm.hasMatch(raw)) {
        try {
          final parts = raw.split(':');
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final tod = TimeOfDay(hour: h, minute: m);
          return tod.format(Get.context ?? context);
        } catch (_) {
          return raw;
        }
      }
      return raw;
    }

    final timeText = fmtTime(timeRaw);

    if (created != null && created.isNotEmpty) {
      final dateText = fmtDate(created);
      final at = timeText != null ? '  At $timeText' : '';
      return '$dateText$at';
    }
    return '';
  }

  void _openDetails(String productId) {
    Get.to(
          () => const ProductDetailsView(),
      binding: BindingsBuilder(() {
        Get.put(ProductDetailsController(productId: productId));
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productId = product['id'].toString();
    final productName = (product['product_name'] ?? 'Unnamed').toString();
    final productImage = (product['product_image'] ?? '').toString();
    final metaLine = _buildDateTimeText(context);

    return InkWell(
      onTap: () => _openDetails(productId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: productImage.isNotEmpty
                  ? Image.network(
                productImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Image.asset('assets/watch1.png', height: 60, width: 60),
              )
                  : Image.asset('assets/watch1.png', height: 60, width: 60),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16, color: Colors.black87),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (metaLine.isNotEmpty)
                    Text(metaLine,
                        style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Add Offer button
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => OfferTypeDialog(
                    productId: productId,
                    controller: addOfferController,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFBC82),
                foregroundColor: Colors.black,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                minimumSize: const Size(90, 36),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Add Offer', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
