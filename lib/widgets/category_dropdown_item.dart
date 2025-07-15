import 'package:flutter/material.dart';

class CategoryDropdownItem extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryDropdownItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            category['img_path'],
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, size: 24),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          category['category'],
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
