import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../createPost/create_post_controller.dart';
import '../widgets/category_dropdown_item.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());

  static const List<String> _allColors = [
    'Black', 'Blue', 'Red', 'Green', 'White', 'Yellow', 'Orange'
  ];

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


  void _showColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Select Colors'),
          content: Obx(() => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _allColors.map((c) {
                return CheckboxListTile(
                  value: controller.selectedColors.contains(c),
                  title: Text(c),
                  onChanged: (_) => controller.toggleColor(c),
                );
              }).toList(),
            ),
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }


  /// Called on pull-to-refresh
  Future<void> _onRefresh() async {
    // reload categories
    await controller.loadCategories();
    // clear all images
    controller.selectedImages
        .asMap()
        .forEach((i, _) => controller.selectedImages[i] = null);
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Upload', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        // 1. Show spinner while categories load
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Pull-to-refresh + form
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Image Grid with delete icons ────────────────────
                    LayoutBuilder(builder: (context, constraints) {
                      final spacing = 12.0;
                      final itemWidth = (constraints.maxWidth - spacing) / 2;

                      return Obx(() {
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: List.generate(controller.selectedImages.length, (index) {
                            final File? file = controller.selectedImages[index];

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: controller.isLoading.value
                                      ? null
                                      : () => controller.pickImage(index),
                                  child: Container(
                                    width: itemWidth,
                                    height: itemWidth,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    clipBehavior: Clip.hardEdge, // <-- clip to radius
                                    child: file != null
                                        ? Image.file(
                                      file,
                                      width: itemWidth,
                                      height: itemWidth,
                                      fit: BoxFit.cover,
                                    )
                                        : const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_circle_outline, size: 30),
                                          SizedBox(height: 8),
                                          Text("Add Image"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // delete “×” icon
                                if (file != null)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: controller.isLoading.value
                                          ? null
                                          : () => controller.removeImage(index),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        );
                      });
                    }),


                    const SizedBox(height: 20),

                    // ── Product Name ───────────────────────────────────
                    TextField(
                      decoration: buildInputDecoration('Product Name'),
                      onChanged: (v) =>
                      controller.productName.value = v,
                    ),
                    const SizedBox(height: 12),

                    // ── Category Dropdown ────────────────────────────────
                    DropdownButtonFormField<String>(
                      decoration: buildInputDecoration('Category'),
                      value: controller.selectedCategory.value.isEmpty
                          ? null
                          : controller.selectedCategory.value,
                      hint: const Text('Select a category'),
                      items: controller.categories
                          .map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['id'].toString(),
                          child: CategoryDropdownItem(category: cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        controller.selectedCategory.value = val ?? '';
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Brand, Model, Price, Stock ───────────────────────
                    TextField(
                      decoration: buildInputDecoration('Brand'),
                      onChanged: (v) => controller.brand.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: buildInputDecoration('Model'),
                      onChanged: (v) => controller.model.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration:
                      buildInputDecoration('Price', suffixText: 'GBP'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.price.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: buildInputDecoration('Stock'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.stock.value = v,
                    ),
                    const SizedBox(height: 12),


// ── Colors ───────────────────────────────────────────────
                    Text(
                      'Colors',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),

// show selected color tags
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: controller.selectedColors.map((c) {
                        return InputChip(
                          label: Text(c),
                          onDeleted: () => controller.toggleColor(c),
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 6),

// read-only TextField to open dialog
                    TextField(
                      decoration: buildInputDecoration('Select colors'),
                      readOnly: true,
                      onTap: () => _showColorDialog(context),
                    ),
                    const SizedBox(height: 12),
// ── Variants ─────────────────────────────────────────────
                    Text('Variants', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),

// text field for entering one variant at a time
                    TextField(
                      decoration: buildInputDecoration('Add variant and press Enter'),
                      onSubmitted: (v) {
                        final trimmed = v.trim();
                        if (trimmed.isNotEmpty) {
                          controller.addVariant(trimmed);
                        }
                      },
                    ),

                    const SizedBox(height: 6),
// show variant tags
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: controller.variants.map((v) {
                        return InputChip(
                          label: Text(v),
                          onDeleted: () => controller.removeVariant(v),
                        );
                      }).toList(),
                    )),

                    const SizedBox(height: 12),


                    // ── Description ──────────────────────────────────────
                    TextField(
                      decoration: buildInputDecoration('Description'),
                      maxLines: 4,
                      onChanged: (v) =>
                      controller.description.value = v,
                    ),
                    const SizedBox(height: 20),

                    // ── Submit Button ────────────────────────────────────
                    ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.submitProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                          : const Text(
                        'Upload',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
