import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget productCard(Map<String, dynamic> product) {
  // parse & format timestamp
  final createdAt = DateTime.tryParse(product['created_at'] ?? '') ?? DateTime.now();
  final date = DateFormat('MMM d, yyyy').format(createdAt);  // e.g. “Jun 30, 2025”
  final time = DateFormat('h:mm a').format(createdAt);       // e.g. “8:28 AM”

  // rating (nullable)
  final double? rating = product['average_rating'] != null
      ? (product['average_rating'] as num).toDouble()
      : null;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      children: [
        // image
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product['product_image'] ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Image.asset('assets/watch1.png', width: 60, height: 60, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        // text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              Text(
                product['product_name'] ?? 'Unnamed',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              // price + star + rating
              // … inside your Column’s children …

// Price + (always) star + rating or “No rating”
              Row(
                children: [
                  Text(
                    '£${product['price'] ?? '0'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),


                ],
              ),

              const SizedBox(height: 4),
              // date + time
              Row(
                children: [
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4), // smaller spacing
                  const Text(
                    'at',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              )

            ],
          ),
        ),
      ],
    ),
  );
}