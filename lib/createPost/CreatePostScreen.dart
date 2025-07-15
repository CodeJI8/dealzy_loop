import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import 'AddOfferScreen.dart';

class CreatePostScreen  extends StatelessWidget {
   CreatePostScreen({super.key});
  final SellerAuthService _authService = SellerAuthService();

  Future<void> _loadCategories() async {
    final token = await TokenStorage.getToken(); // You can also pass token manually
    if (token == null) {
      Get.snackbar("Login Required", "Please login first");
      return;
    }

    try {
      final categories = await _authService.getAllCategories(token);
      print(categories); // Use this to display categories in your UI
    } catch (e) {
      print("Error loading categories: $e");
      Get.snackbar("Error", e.toString());
    }
  }



  // Reusable method for consistent InputDecoration
  InputDecoration buildInputDecoration(String label, {String? suffixText}) {
    return InputDecoration(
      labelText: label,
      hintText: label,
      border: const OutlineInputBorder(),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.5),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blueGrey, width: 2),
      ),
      suffixText: suffixText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: width * 0.06, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: () {
                    // TODO: Add image picker logic
                  },
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 30),
                          SizedBox(height: 8),
                          Text("Add Image"),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form fields
                TextField(
                  decoration: buildInputDecoration('Product Name'),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: buildInputDecoration('Category'),
                  items: ['Electronics', 'Fashion', 'Sports']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {},
                ),
                const SizedBox(height: 12),

                TextField(decoration: buildInputDecoration('Brand')),
                const SizedBox(height: 12),
                TextField(decoration: buildInputDecoration('Model')),
                const SizedBox(height: 12),

                TextField(
                  decoration: buildInputDecoration('Price', suffixText: 'GBP'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                TextField(decoration: buildInputDecoration('Color')),
                const SizedBox(height: 12),
                TextField(decoration: buildInputDecoration('Variant')),
                const SizedBox(height: 12),

                TextField(
                  decoration: buildInputDecoration('Description'),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                // Upload button
                ElevatedButton(
                  onPressed: () {
                    Get.to(() => const AddOfferScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Upload', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
