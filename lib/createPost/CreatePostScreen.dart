import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../service/seller_auth_service.dart';
import '../storage/token_storage.dart';
import 'AddOfferScreen.dart';
import '../widgets/category_dropdown_item.dart';
import 'create_post_controller.dart';

class CreatePostScreen extends StatefulWidget {
  CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());

  final SellerAuthService _authService = SellerAuthService();

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double spacing = 12;
                    final double totalSpacing = spacing;
                    final double availableWidth = constraints.maxWidth;
                    final double itemWidth =
                        (availableWidth - totalSpacing) / 2;

                    return Obx(
                      () => Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: List.generate(
                          controller.selectedImages.length,
                          (index) {
                            final file = controller.selectedImages[index];

                            return GestureDetector(
                              onTap: () => controller.pickImage(index),
                              child: Container(
                                width: itemWidth,
                                height: itemWidth, // keep it square
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                  image: file != null
                                      ? DecorationImage(
                                          image: FileImage(file),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: file == null
                                    ? const Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline,
                                              size: 30,
                                            ),
                                            SizedBox(height: 8),
                                            Text("Add Image"),
                                          ],
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Form fields
                TextField(
                  decoration: buildInputDecoration('Product Name'),
                  onChanged: (value) =>
                      controller.productNameController.value = value,
                ),

                const SizedBox(height: 12),

                Obx(
                  () => DropdownButtonFormField<String>(
                    decoration: buildInputDecoration('Category'),
                    value: controller.selectedCategory.value.isEmpty
                        ? null
                        : controller.selectedCategory.value,

                    hint: const Text('Select a category'),
                    items: controller.categories.map<DropdownMenuItem<String>>((
                      cat,
                    ) {
                      return DropdownMenuItem<String>(
                        value: cat['id'].toString(),
                        child: CategoryDropdownItem(category: cat),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.selectedCategory.value = value!;
                    },

                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                    decoration: buildInputDecoration('Brand'),
                    onChanged: (value) =>
          controller.brandController.value = value,


                ),
                const SizedBox(height: 12),
                TextField(decoration: buildInputDecoration('Model'),
                  onChanged: (value) =>
                  controller.modelController.value = value,

                ),
                const SizedBox(height: 12),

                TextField(
                  decoration: buildInputDecoration('Price', suffixText: 'GBP'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                  controller.priceController.value = value,

                ),
                const SizedBox(height: 12),

                TextField(
                  decoration: buildInputDecoration('Stock'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) =>
                  controller.stockController.value = value,
                ),
                const SizedBox(height: 12),


                TextField(decoration: buildInputDecoration('Color'),
                  onChanged: (value) =>
                  controller.colorController.value = value,),
                const SizedBox(height: 12),
                TextField(decoration: buildInputDecoration('Variant'),

                  onChanged: (value) =>
                  controller.variantController.value = value,),
                const SizedBox(height: 12),

                TextField(
                  decoration: buildInputDecoration('Description'),
                  onChanged: (value) =>
                  controller.descriptionController.value = value,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),

                // Upload button
                ElevatedButton(
                  // ✅ REPLACE WITH:
                  onPressed: () {
                    controller.submitProduct();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Upload',
                    style: TextStyle(color: Colors.white),
                  ),
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
