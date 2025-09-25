import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../createPost/create_post_controller.dart';
import '../widgets/category_dropdown_item.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final CreatePostController controller = Get.put(CreatePostController());
  final TextEditingController _variantCtrl = TextEditingController();

  static const List<String> _allColors = [
    'Black', 'Blue', 'Red', 'Green', 'White', 'Yellow', 'Orange'
  ];

  InputDecoration buildInputDecoration(
      String label, {
        String? suffixText,
        String? hint,            // NEW
        bool alignHintTop = false, // NEW
      }) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBDBDBD), width: 1.2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF607D8B), width: 1.6),
      ),
      suffixText: suffixText,
      // more top padding when aligning hint to top
      contentPadding: EdgeInsets.fromLTRB(12, alignHintTop ? 12 : 12, 12, 12),
      alignLabelWithHint: alignHintTop, // helps label alignment on multiline
    );
  }


  void _chooseImageSource(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take Photo (Camera)'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImageForSlot(index, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImageForSlot(index, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showColorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Select Colors'),
          content: Obx(
                () => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _allColors
                    .map(
                      (c) => CheckboxListTile(
                    value: controller.selectedColors.contains(c),
                    title: Text(c),
                    onChanged: (_) => controller.toggleColor(c),
                  ),
                )
                    .toList(),
              ),
            ),
          ),
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

  Future<void> _onRefresh() async {
    await controller.loadCategories();
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
        if (controller.isLoadingCategories.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width * 0.06,
              vertical: 12,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Images section: full width when 0, two-column when ≥1 ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final spacing = 12.0;
                        final half = (constraints.maxWidth - spacing) / 2;

                        return Obx(() {
                          final images = controller.selectedImages;

                          if (images.isEmpty) {
                            // Full-width dotted placeholder
                            return _AddDottedTile(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth * 0.56,
                              onTap: () => _chooseImageSource(context, 0),
                            );
                          }

                          // ≥1 image: show each image (half width), then a half-width Add tile
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              for (int i = 0; i < images.length; i++)
                                _SelectedImageTile(
                                  file: images[i],
                                  width: half,
                                  height: half,
                                  onTapReplace: () =>
                                      _chooseImageSource(context, i),
                                  onDelete: () => controller.removeImage(i),
                                ),
                              _AddDottedTile(
                                width: half,
                                height: half,
                                onTap: () => _chooseImageSource(
                                  context,
                                  images.length, // append
                                ),
                              ),
                            ],
                          );
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Form fields ──────────────────────────────────────
                    TextField(
                      decoration: buildInputDecoration('Product Name'),
                      onChanged: (v) => controller.productName.value = v,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      decoration: buildInputDecoration('category'),
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
                      onChanged: (val) =>
                      controller.selectedCategory.value = val ?? '',
                    ),
                    const SizedBox(height: 12),

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
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => controller.price.value = v,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: buildInputDecoration('Stock'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.stock.value = v,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      decoration: buildInputDecoration('Color'),
                      readOnly: true,
                      onTap: () => _showColorDialog(context),
                    ),
                    const SizedBox(height: 6),

                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: controller.selectedColors
                            .map(
                              (c) => InputChip(
                            label: Text(c),
                            onDeleted: () => controller.toggleColor(c),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: _variantCtrl,
                      decoration:
                      buildInputDecoration('Variant (press Enter to add)'),
                      onSubmitted: (v) {
                        final t = v.trim();
                        if (t.isNotEmpty) {
                          controller.addVariant(t);
                          _variantCtrl.clear();
                        }
                      },
                    ),
                    const SizedBox(height: 6),

                    Obx(
                          () => Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: controller.variants
                            .map(
                              (v) => InputChip(
                            label: Text(v),
                            onDeleted: () => controller.removeVariant(v),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      decoration: buildInputDecoration(
                        'Description',
                        hint: 'Write a short description...', // custom hint text
                        alignHintTop: true,                    // align label/hint to top
                      ),
                      maxLines: 4,
                      // THIS aligns the typing & hint vertically to the top
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (v) => controller.description.value = v,
                    ),


                    const SizedBox(height: 20),

                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 160),
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.submitProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D3B66),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                              : const Text('upload',
                              style: TextStyle(color: Colors.white)),
                        ),
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

/// Dotted “Add Image” tile (rounded).
class _AddDottedTile extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _AddDottedTile({
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: height,
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(8),
          dashPattern: const [6, 3],
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circle + icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 28, color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Add Image",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      )

    );
  }
}

/// Selected image tile with rounded corners and delete button.
class _SelectedImageTile extends StatelessWidget {
  final File file;
  final double width;
  final double height;
  final VoidCallback? onTapReplace;
  final VoidCallback? onDelete;

  const _SelectedImageTile({
    required this.file,
    required this.width,
    required this.height,
    this.onTapReplace,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapReplace,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.file(file, width: width, height: height, fit: BoxFit.cover),
            Positioned(
              top: 6,
              right: 6,
              child: InkWell(
                onTap: onDelete,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.clear, size: 18, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
