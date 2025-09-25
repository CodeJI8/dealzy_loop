// lib/dashboard/cards/dealCard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget dealCard(
    Map<String, dynamic> deal, {
      VoidCallback? onDelete,   // delete callback
      VoidCallback? onTap,      // open details callback
    }) {
  final expiry = DateTime.tryParse(deal['expiry_date'] ?? '');
  final formattedExpiry = expiry != null
      ? DateFormat('MMM d, yyyy').format(expiry)
      : null; // null means no valid date

  final productName = (deal['product_name'] ?? 'No name').toString();

  // numeric parsing with safety
  final originalPrice = (deal['price'] is num)
      ? (deal['price'] as num).toDouble()
      : double.tryParse('${deal['price']}');
  final discountPrice = (deal['discount_price'] is num)
      ? (deal['discount_price'] as num).toDouble()
      : double.tryParse('${deal['discount_price']}');

  return InkWell(
    onTap: onTap, // 👈 tap anywhere on card to open details
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              deal['product_image'] ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset('assets/watch1.png', width: 40, height: 40, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 10),

          // title + expiry
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedExpiry != null
                      ? 'Exp $formattedExpiry'
                      : 'No expiry date',
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),

          // price block
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (originalPrice != null)
                Text(
                  '\£${originalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              if (discountPrice != null)
                Text(
                  '\£${discountPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // delete button (doesn't trigger onTap)
          IconButton(
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Remove this deal',
          ),
        ],
      ),
    ),
  );
}
