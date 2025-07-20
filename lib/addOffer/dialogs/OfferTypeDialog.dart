import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../AddOfferScreen.dart';
import '../add_offer_controller.dart';

class OfferTypeDialog extends StatefulWidget {
  final String productId;
  final AddOfferController controller;

  const OfferTypeDialog({
    super.key,
    required this.productId,
    required this.controller,
  });

  @override
  State<OfferTypeDialog> createState() => _OfferTypeDialogState();
}

class _OfferTypeDialogState extends State<OfferTypeDialog> {
  String? selectedOfferType;
  String? expiryDate;
  final TextEditingController discountController = TextEditingController();
  bool isSecondStep = false;
  bool isLoading = false;

  void _goToNextStep() {
    if (selectedOfferType == null) {
      Get.snackbar("Error", "Please select an offer type.");
      return;
    }
    setState(() => isSecondStep = true);
  }

  Future<void> _submit() async {
    final discount = discountController.text.trim();

    if (discount.isEmpty) {
      Get.snackbar("Error", "Please enter discount.");
      return;
    }

    if (selectedOfferType!.toLowerCase() != 'regular' && expiryDate == null) {
      Get.snackbar("Error", "Please select an expiry date.");
      return;
    }

    setState(() => isLoading = true);

    // 🔍 Debug prints
    print('🔍 DEBUG SUBMIT OFFER');
    print('productId: ${widget.productId}');
    print('discount: $discount');
    print('offerType: $selectedOfferType');
    print('expiryDate: $expiryDate');

    if (widget.productId.isEmpty) {
      Get.snackbar("Error", "Product ID is missing.");
      setState(() => isLoading = false);
      return;
    }

    await widget.controller.addOffer(
      productId: widget.productId,
      discount: discount,
      offerCategory: selectedOfferType!,
      expiryDate: expiryDate,
    );

    setState(() => isLoading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
    backgroundColor:  const Color(0xFFBACEDF).withOpacity(0.90),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    isSecondStep
                        ? 'What is the  discount price percentage?'
                        : 'What type of offer would you like to include?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Step 1: Offer Type
            if (!isSecondStep) ...[
              _buildOptionButton('regular'),
              const SizedBox(height: 8),
              _buildOptionButton('expiring_soon'),
              const SizedBox(height: 8),
              _buildOptionButton('clearance'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _goToNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ],

            // Step 2: Discount + Expiry
            if (isSecondStep) ...[
              _buildTextField('Discount Price', discountController, Icons.percent),
              const SizedBox(height: 12),

              if (selectedOfferType?.toLowerCase() != 'regular')
                GestureDetector(
                  onTap: () async {
                    final picked = await selectExpiryDate(context);
                    if (picked != null) {
                      setState(() => expiryDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          expiryDate != null ? 'Expiry: $expiryDate' : 'Expiry Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Confirm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(String type) {
    final isSelected = selectedOfferType == type;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedOfferType = type;
          if (type.toLowerCase() == 'regular') expiryDate = null;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Colors.blue : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
        foregroundColor: Colors.black,
      ),
      child: Text(type),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: const TextStyle(fontSize: 12),
    );
  }
}
