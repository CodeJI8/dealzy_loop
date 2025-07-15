import 'package:flutter/material.dart';

import '../viewProduct/ProductViewPage.dart';
import 'dialogs/OfferTypeDialog.dart';

class AddOfferScreen extends StatelessWidget {
  const AddOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offer', style: TextStyle(color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Column(
          children: [
            // Search Field
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search',
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: 2,
                itemBuilder: (context, index) => const ProductItemCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductItemCard extends StatelessWidget {
  const ProductItemCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductViewPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Static Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/watch1.png', // Static image path
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Text and Button Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fossil Neutra Chronograph',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Text('View Details', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Exp: May 10, 2025  At 9:00 Am',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => OfferTypeDialog(
                            onSelected: (offerType) {
                              print('Selected offer type: $offerType');
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE0B2),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                        minimumSize: Size(screenWidth * 0.2, 32),
                      ),
                      child: const Text('Add Offer', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
