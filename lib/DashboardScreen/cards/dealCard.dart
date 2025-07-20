import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget dealCard(Map<String, dynamic> deal) {
  // parse & format expiry date
  final expiry = DateTime.tryParse(deal['expiry_date'] ?? '');
  final formattedExpiry = expiry != null
      ? DateFormat('MMM d, yyyy').format(expiry)
      : deal['expiry_date'] ?? '';

  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: ClipRRect(
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
    title: Text(
      // truncate long names
      '${deal['product_name'] ?? 'No name'}',
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    subtitle: Text(
      'Exp $formattedExpiry',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black,
      ),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // original & discounted prices
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '৳${deal['price'] ?? ''}',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            Text(
              // round to 2 decimals
              '৳${(deal['discount_price'] as num).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        // little spacing
        const SizedBox(width: 8),
        // close icon
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.close, size: 20, color: Colors.black54),
          onPressed: () {
            // TODO: handle remove deal
          },
        ),
      ],
    ),
  );
}