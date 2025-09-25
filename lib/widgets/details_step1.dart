import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

import '../terms_and_condition/user_agreement_page.dart';

class DetailsStep1 extends StatefulWidget {
  final String profileImagePath;
  final void Function(String path) onPickImage;

  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController storeNameController;
  final TextEditingController storeAddressController;
  final TextEditingController postalCodeController;

  final String selectedStoreType;
  final void Function(String value) onStoreTypeChanged;

  final VoidCallback onSubmit;
  final bool isLoading; // 👈 ADD THIS

  const DetailsStep1({
    super.key,
    required this.profileImagePath,
    required this.onPickImage,
    required this.usernameController,
    required this.emailController,
    required this.storeNameController,
    required this.storeAddressController,
    required this.postalCodeController,
    required this.selectedStoreType,
    required this.onStoreTypeChanged,
    required this.onSubmit,
    this.isLoading = false, // 👈 default value
  });

  @override
  State<DetailsStep1> createState() => _DetailsStep1State();
}


class _DetailsStep1State extends State<DetailsStep1> {
  bool _agreed = false;

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) widget.onPickImage(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile image picker
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.profileImagePath.isNotEmpty
                  ? FileImage(File(widget.profileImagePath))
                  : null,
              child: widget.profileImagePath.isEmpty
                  ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 4,
              child: InkWell(
                onTap: _pickFromGallery,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Username
        TextField(
          controller: widget.usernameController,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(fontSize: 14),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        const SizedBox(height: 12),

        // Email
        TextField(
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'example@domain.com',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        const SizedBox(height: 12),

        // Store name
        TextField(
          controller: widget.storeNameController,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Store name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        const SizedBox(height: 12),

        // Store address
        TextField(
          controller: widget.storeAddressController,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Store address',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        const SizedBox(height: 12),

        // Postal code
        TextField(
          controller: widget.postalCodeController,
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
            LengthLimitingTextInputFormatter(8),
          ],
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Postal code',
            hintText: 'e.g., SW1A 1AA',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
        ),
        const SizedBox(height: 12),

        // Store type dropdown
        DropdownButtonFormField<String>(
          value: widget.selectedStoreType,
          decoration: const InputDecoration(
            labelText: 'Store type',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
          items: const ['Retail', 'Wholesale', 'Service']
              .map((e) =>
              DropdownMenuItem<String>(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) widget.onStoreTypeChanged(value);
          },
        ),
        const SizedBox(height: 16),

        // Terms & Conditions Checkbox
        // Terms & Conditions Checkbox + Link
        Row(
          children: [
            Checkbox(
              value: _agreed,
              onChanged: (val) {
                setState(() {
                  _agreed = val ?? false;
                });
              },
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    const TextSpan(text: 'I agree to the '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to your T&C page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DealzyloopUserAgreementPage(),
                            ),
                          );

                        },
                        child: const Text(
                          'Terms & Conditions',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Confirm button
        Center(
          child: Center(
            child: Center(
              child: ElevatedButton(
                onPressed: (_agreed && !widget.isLoading) ? widget.onSubmit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3D78),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 45),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: widget.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Confirm'),
              ),
            )

          ),


        ),
      ],
    );
  }
}
