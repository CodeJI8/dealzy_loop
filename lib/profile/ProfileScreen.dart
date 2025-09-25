// lib/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/signin_screen.dart';
import '../storage/token_storage.dart';
import 'ProfileController.dart';
import 'models/SellerProfile.dart';

/// Use GetView so controller is not created inside build().
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({Key? key}) : super(key: key);

  ProfileController get ctrl => controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final err = ctrl.errorMessage.value;
        if (err != null && err.isNotEmpty) {
          return _ErrorView(
            message: err,
            onRetry: ctrl.loadProfile, // make sure controller exposes this
          );
        }

        final p = ctrl.profile.value;
        if (p == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ─── Avatar + Name ────────────────────────────────
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _Avatar(url: p.proPath),
                        Positioned(
                          bottom: -2,
                          right: -2,
                          child: GestureDetector(
                            onTap: _pickSourceSheet,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.asset('assets/profile/update_profile.png', width: 28, height: 28),
                                Obx(() => ctrl.isUploading.value
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                                    : const SizedBox.shrink()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
            
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
            
                // ─── Info Rows ─────────────────────────────────────
                _infoRow('assets/profile/store_name.png', p.storeName),
                _infoRow('assets/profile/store_location.png', p.address),
                _infoRow('assets/profile/call.png', p.phone),
                _infoRow('assets/profile/store_type.png', p.storeType),
            
                const SizedBox(height: 16),
            
                // ─── Opening Hours (dynamic) ───────────────────────
                Row(
                  children: [
                    Image.asset('assets/profile/store_time.png', width: 20, height: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OpeningHours(open: p.openingTime, close: p.closingTime),
                    ),
                  ],
                ),
            
                SizedBox(height: 70.h),
            
                // ─── Log Out ───────────────────────────────────────
                GestureDetector(
                  onTap: _confirmLogout,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Log Out',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(width: 10),
                      Image.asset('assets/profile/logout_icon.png', width: 32, height: 32),
                    ],
                  ),
                ),
            
                const SizedBox(height: 24),
            
                // ─── Danger Zone: Delete Account ───────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danger Zone',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.delete_forever, color: Color(0xFFB91C1C)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Delete Account',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Obx(() {
                            final deleting = ctrl.isDeleting.value;
                            return ElevatedButton(
                              onPressed: deleting
                                  ? null
                                  : () => _showDeleteDialog(Get.context!, ctrl, ctrl.profile.value!.storeName),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                              ),
                              child: deleting
                                  ? const SizedBox(
                                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Text('Delete'),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'This permanently deletes your account and data. This action cannot be undone.',
                        style: TextStyle(color: Color(0xFF991B1B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ───────────────────────── Helpers ─────────────────────────

  void _pickSourceSheet() {
    final ctx = Get.context!;
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                ctrl.changeProfilePhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                ctrl.changeProfilePhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: 'Confirm Logout',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Yes',
      textCancel: 'No',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        await TokenStorage.clearToken();
        Get.offAll(() => const SignInScreen());
      },
      onCancel: () => Get.back(),
    );
  }

  void _showDeleteDialog(BuildContext context, ProfileController ctrl, String storeName) {
    final tc = TextEditingController();
    bool canDelete = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            void _onChanged(String val) {
              final want = storeName.trim().toLowerCase();
              final got = val.trim().toLowerCase();
              setState(() => canDelete = got.isNotEmpty && got == want);
            }

            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action is permanent. To confirm, type your store name exactly:\n\n"$storeName"',
                    style: const TextStyle(height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tc,
                    autofocus: true,
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      labelText: 'Store name',
                      hintText: storeName,
                      border: const OutlineInputBorder(),
                      errorText: (tc.text.isEmpty || canDelete) ? null : 'Name does not match',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                // Single Obx that reads the reactive deleting flag at build time
                Obx(() {
                  final deleting = ctrl.isDeleting.value;
                  final enabled = canDelete && !deleting;

                  return ElevatedButton.icon(
                    onPressed: enabled
                        ? () async {
                      Navigator.of(ctx).pop();
                      await ctrl.deleteAccount();
                    }
                        : null,
                    icon: const Icon(Icons.delete_forever),
                    label: deleting
                        ? const SizedBox(
                        width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  Widget _infoRow(String assetPath, String text) {
    final safe = (text).trim().isEmpty ? '—' : text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Image.asset(assetPath, width: 20, height: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              safe,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final hasUrl = url.trim().isNotEmpty;
    if (!hasUrl) {
      return const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('assets/profile/profile_avatar.png'),
      );
    }
    return CircleAvatar(
      radius: 40,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
    );
  }
}

class _OpeningHours extends StatelessWidget {
  const _OpeningHours({this.open, this.close});
  final String? open;
  final String? close;

  String _formatTime(BuildContext ctx, String raw) {
    try {
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(raw)) {
        final p = raw.split(':');
        final dt = DateTime(1970, 1, 1, int.parse(p[0]), int.parse(p[1]));
        return TimeOfDay(hour: dt.hour, minute: dt.minute).format(ctx);
      }
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(raw)) {
        final p = raw.split(':');
        return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1])).format(ctx);
      }
      if (RegExp(r'^\d{1,2}:\d{2}\s?(AM|PM|am|pm)$').hasMatch(raw)) {
        return raw.toUpperCase();
      }
    } catch (_) {}
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final hasOpen = (open ?? '').trim().isNotEmpty;
    final hasClose = (close ?? '').trim().isNotEmpty;

    if (!hasOpen && !hasClose) {
      return const Text('Opening hours not set', style: TextStyle(fontSize: 14, color: Colors.grey));
    }

    final openText = hasOpen ? _formatTime(context, open!.trim()) : 'Not set';
    final closeText = hasClose ? _formatTime(context, close!.trim()) : 'Not set';

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: [
          const TextSpan(text: 'Open: '),
          TextSpan(text: '$openText  ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green)),
          const TextSpan(text: 'to '),
          TextSpan(text: closeText, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
      ]),
    );
  }
}
