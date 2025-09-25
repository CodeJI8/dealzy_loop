// lib/product_details/widgets/update_product_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../service/seller_auth_service.dart';
import '../../storage/token_storage.dart';

Future<void> openUpdateProductSheet({
  required BuildContext context,
  required String productId,
  required double initialPrice,
  required int initialStock,
  VoidCallback? onSuccess, // e.g. reload details after success
}) async {
  final priceCtrl = TextEditingController(text: initialPrice.toStringAsFixed(0));
  final stockCtrl = TextEditingController(text: initialStock.toString());
  final formKey = GlobalKey<FormState>();
  bool isSaving = false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets; // for keyboard
      return Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16, bottom: 16 + viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            Future<void> _submit() async {
              if (!formKey.currentState!.validate()) return;

              final token = await TokenStorage.getToken();
              if (token == null) {
                Get.snackbar('Error', 'Please login first');
                return;
              }

              final price = double.parse(priceCtrl.text.trim());
              final stock = int.parse(stockCtrl.text.trim());

              setState(() => isSaving = true);
              try {
                final api = SellerAuthService();
                final res = await api.updateProduct(
                  token: token,
                  productId: productId,
                  stock: stock,
                  price: price,
                );

                if ((res['status'] as String?)?.toLowerCase() == 'success') {
                  Get.snackbar('Updated', res['message'] ?? 'Product updated');
                  Navigator.pop(ctx); // close sheet
                  onSuccess?.call();   // e.g. controller.refresh
                } else {
                  Get.snackbar('Error', res['message'] ?? 'Update failed');
                }
              } catch (e) {
                Get.snackbar('Error', e.toString());
              } finally {
                if (ctx.mounted) setState(() => isSaving = false);
              }
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12, borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text('Update Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Price',
                          suffixText: 'GBP',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) {
                          final p = double.tryParse(v?.trim() ?? '');
                          if (p == null || p <= 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (v) {
                          final s = int.tryParse(v?.trim() ?? '');
                          if (s == null || s < 0) return 'Enter a valid stock';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF124A89),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                            : const Text('Save', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
