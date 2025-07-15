import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/seller_auth_service.dart';
import '../viewProduct/ProductViewPage.dart';
import 'add_offer_controller.dart';
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


  List<dynamic> _postedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostedProducts();
  }

  Future<void> _loadPostedProducts() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    try {
      final products = await _authService.getPostedProducts(token, limit: 20);
      setState(() {
        _postedProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offer', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          children: [
            // Search Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _postedProducts.isEmpty
                  ? const Center(child: Text("No posted products found."))
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final productId = product['id'].toString();
    final productName = product['product_name'] ?? 'Unnamed';
    final productImage = product['product_image'] ?? '';
    final SellerAuthService _service = SellerAuthService();
    final details =  _service.getProductDetails(productId);

    return GestureDetector(
      onTap: () async {
        final service = SellerAuthService();
        try {
          final details = await service.getProductDetails(productId);

          if (details['data'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductViewPage(productDetails: details['data']),
              ),
            );
          } else {
            Get.snackbar('Error', 'Product details not found.');
          }

        } catch (e) {
          // 🔴 This is important to avoid crash on API failure or JSON issues
          Get.snackbar('Error', 'Failed to fetch product details: $e');
        }
      },



      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: productImage.isNotEmpty
                  ? Image.network(
                productImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset('assets/watch1.png', height: 60, width: 60),
              )
                  : Image.asset('assets/watch1.png', height: 60, width: 60),
            ),
            const SizedBox(width: 12),

            // Info + Button
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('View Details', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Exp: May 10, 2025  At 9:00 AM',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => OfferTypeDialog(
                            onSelected: (offerType) async {
                              Navigator.pop(context); // Close dialog
                              const discount = "25"; // You may replace with input
                              String? expiryDate;

                              if (offerType == 'regular') {
                                expiryDate = await selectExpiryDate(context);
                              }

                              await addOfferController.addOffer(
                                productId: productId,
                                discount: discount,
                                offerCategory: offerType,
                                expiryDate: expiryDate,
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE0B2),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        minimumSize: Size(screenWidth * 0.2, 32),
                      ),
                      child: const Text('Add Offer', style: TextStyle(fontSize: 12)),
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
}

/// Date picker for regular offer
Future<String?> selectExpiryDate(BuildContext context) async {
  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (pickedDate != null) {
    return "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
  }

  return null;
}

