// lib/controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';

class ProductController extends GetxController {
  final SellerAuthService _service = SellerAuthService();

  Future<void> showUpdateDialog(BuildContext context, String productId) async {
    final stockCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Update Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Stock'),
            ),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Price'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await TokenStorage.getToken();
              if (token == null) {
                Get.snackbar('Error', 'Please log in first');
                return;
              }
              final stock = int.tryParse(stockCtrl.text.trim());
              final price = double.tryParse(priceCtrl.text.trim());
              if (stock == null || price == null) {
                Get.snackbar('Error', 'Invalid stock or price');
                return;
              }
              Navigator.pop(context); // close dialog
              try {
                final res = await _service.updateProduct(
                  token: token,
                  productId: productId,
                  stock: stock,
                  price: price,
                );
                if (res['status'] == 'success') {
                  Get.snackbar('Success', res['message'] ?? 'Updated');
                  // optionally refresh the view...
                } else {
                  Get.snackbar('Failed', res['message'] ?? 'Update failed');
                }
              } catch (e) {
                Get.snackbar('Error', e.toString());
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
