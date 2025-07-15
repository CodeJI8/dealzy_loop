import 'package:flutter/material.dart';

import '../createPost/DiscountDialog.dart';

class OfferTypeDialog extends StatelessWidget {
  final void Function(String) onSelected;
  const OfferTypeDialog({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(

      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFBACEDF).withOpacity(0.90),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'What type of offer would you like to include?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black, // Changed to black
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildOptionButton(context, 'Regular'),
            const SizedBox(height: 12),
            _buildOptionButton(context, 'Expiring Soon'),
            const SizedBox(height: 12),
            _buildOptionButton(context, 'Clearance'),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String text) {
    return OutlinedButton(
      onPressed: () {
        onSelected(text);
        Navigator.pop(context);

        // Show the DiscountDialog
        showDialog(
          context: context,
          builder: (_) => const DiscountDialog(),
        );
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black, width: 1), // Border color black
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        foregroundColor: Colors.black, // Text/icon color black
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, color: Colors.black), // Text color black
      ),
    );
  }
}
