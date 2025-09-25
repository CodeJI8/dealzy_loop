import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? selectedOfferLabel;  // UI label: 'Regular', 'Expiring Soon', etc.
  String? expiryDate;          // format: YYYY-MM-DD
  final TextEditingController discountController = TextEditingController();
  bool isSecondStep = false;
  bool isLoading = false;

  // --- Mapping: UI label -> backend key ---
  String? get _offerCategoryKey => selectedOfferLabel == null ? null : _toBackendKey(selectedOfferLabel!);

  String _toBackendKey(String label) {
    switch (label.trim().toLowerCase()) {
      case 'regular': return 'regular';
      case 'expiring soon': return 'expiring_soon';
      case 'clearance': return 'clearance';
      case 'seasonal': return 'seasonal';
      case 'service special': return 'service_special';
      default: return label.trim().toLowerCase();
    }
  }

  // ---- Category helpers (based on backend key) ----
  bool get _isExpiringSoon     => _offerCategoryKey == 'expiring_soon';
  bool get _isRegular          => _offerCategoryKey == 'regular';
  bool get _isClearance        => _offerCategoryKey == 'clearance';
  bool get _isSeasonal         => _offerCategoryKey == 'seasonal';
  bool get _isServiceSpecial   => _offerCategoryKey == 'service_special';

  // expiry_date rules
  bool get _requiresExpiryDate => _isExpiringSoon || _isSeasonal;               // required
  bool get _showExpiryField    => _requiresExpiryDate || _isClearance;          // show (required/optional)
  bool get _mustOmitExpiry     => _isRegular || _isServiceSpecial;              // never send

  void _goToNextStep() {
    if (selectedOfferLabel == null) {
      Get.snackbar("Error", "Please select an offer type.");
      return;
    }
    if (_mustOmitExpiry) {
      expiryDate = null; // not applicable for regular or service_special
    }
    setState(() => isSecondStep = true);
  }

  Future<void> _submit() async {
    final discount = discountController.text.trim();

    if (discount.isEmpty) {
      Get.snackbar("Error", "Please enter discount (percentage).");
      return;
    }

    // Optional: guard discount range 1..100 (percentage)
    final pct = int.tryParse(discount);
    if (pct == null || pct <= 0 || pct > 100) {
      Get.snackbar("Invalid discount", "Enter a whole number between 1 and 100.");
      return;
    }

    if (_offerCategoryKey == null) {
      Get.snackbar("Error", "Offer category is missing.");
      return;
    }

    // Require expiry for expiring_soon & seasonal
    if (_requiresExpiryDate && (expiryDate == null || expiryDate!.isEmpty)) {
      Get.snackbar("Error", "Please select an expiry date.");
      return;
    }

    setState(() => isLoading = true);

    if (widget.productId.isEmpty) {
      Get.snackbar("Error", "Product ID is missing.");
      setState(() => isLoading = false);
      return;
    }

    final String? dateToSend;
    if (_mustOmitExpiry) {
      dateToSend = null; // never send
    } else if (_requiresExpiryDate) {
      dateToSend = expiryDate; // required & non-null by validation above
    } else if (_isClearance) {
      dateToSend = (expiryDate != null && expiryDate!.isNotEmpty) ? expiryDate : null; // optional
    } else {
      dateToSend = null;
    }

    await widget.controller.addOffer(
      productId: widget.productId,
      discount: discount,
      offerCategory: _offerCategoryKey!, // 'regular' | 'expiring_soon' | 'clearance' | 'seasonal' | 'service_special'
      expiryDate: dateToSend,
    );

    setState(() => isLoading = false);
    if (mounted) Navigator.pop(context);
  }

  // --- Helper: Show a date picker and return YYYY-MM-DD ---
  Future<String?> _pickExpiryDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now, // no past dates
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return null;
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFBACEDF).withOpacity(0.90),
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
                        ? 'What is the discount?'
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
              _buildOptionButton('Regular'),
              const SizedBox(height: 8),
              _buildOptionButton('Expiring Soon'),
              const SizedBox(height: 8),
              _buildOptionButton('Clearance'),
              const SizedBox(height: 8),
              _buildOptionButton('Seasonal'),
              const SizedBox(height: 8),
              _buildOptionButton('Service Special'),
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

            // Step 2: Discount + Expiry (required/optional/hidden per rules)
            if (isSecondStep) ...[
              _buildDiscountField('Enter the amount', discountController),
              const SizedBox(height: 12),

              if (_showExpiryField)
                GestureDetector(
                  onTap: () async {
                    final picked = await _pickExpiryDate(context);
                    if (!mounted) return;
                    if (picked != null) setState(() => expiryDate = picked);
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
                          expiryDate != null
                              ? 'Expiry: $expiryDate'
                              : _isClearance
                              ? 'Expiry Date (optional)'
                              : 'Expiry Date *',
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

  Widget _buildOptionButton(String label) {
    final isSelected = selectedOfferLabel == label;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedOfferLabel = label;
          // Clear expiry when not applicable
          if (_mustOmitExpiry) expiryDate = null;
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isSelected ? Colors.blue : Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: isSelected ? Colors.blue.withOpacity(0.2) : null,
        foregroundColor: Colors.black,
      ),
      child: Text(label),
    );
  }

  Widget _buildDiscountField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')), // allows decimals
      ],

      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: const TextStyle(fontSize: 12),
    );
  }
}
