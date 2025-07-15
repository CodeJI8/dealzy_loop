import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:seller_loop/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../service/seller_auth_service.dart';

class SignUpScreen extends StatefulWidget {


  const SignUpScreen({super.key});




  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final storeNameController = TextEditingController();
  final storeAddressController = TextEditingController();
  String selectedStoreType = 'Retail';
  String profileImagePath = ''; // Set this via I

  final SellerAuthService _authService = SellerAuthService();
// magePicker


  int stepIndex = 0;

  void nextStep() {
    setState(() {
      if (stepIndex < 3) stepIndex++;
    });
  }

  void previousStep() {
    setState(() {
      if (stepIndex > 0) stepIndex--;
    });
  }

  void goToSignIn() {
    // Change this to navigate to your actual SignInScreen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (stepIndex > 0) {
          previousStep();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF004D99),
        appBar: stepIndex == 0
            ? null
            : AppBar(
          backgroundColor: const Color(0xFF004D99),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: previousStep,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: SafeArea( // 👈 avoids status bar overlap
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Image.asset('assets/ic_shopcenter.png', width: 200 ,

                        fit: BoxFit.cover,),


                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: buildStepView(),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),


      ),
    );
  }

  Widget buildStepView() {
    switch (stepIndex) {
    case 0:
      return buildIntro();
      case 1:
        return buildPhonePassword();
      case 2:
        return buildDetailsStep1();
      // case 3:
        // return buildDetailsStep2();
      default:
        return Container();
    }
  }

  Widget buildIntro() {
    return Container(

      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/discount_icon.png', height: 80),
              const SizedBox(height: 16),
              const Text(
                "LocalLoop helps you save money by showing real-time deals from nearby local shops on expiring, overstocked, and discounted items — reducing food waste while supporting your community.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3D78),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sign Up"),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: goToSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(45),
                    foregroundColor: const Color(0xFF0C3D78),
                    side: const BorderSide(color: Color(0xFFCCCCCC)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Log In"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget buildPhonePassword() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const Text(
          "Get exclusive local deals before they're gone.\nSign up now!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // White Box + Characters in Stack
        Stack(
          clipBehavior: Clip.none,
          children: [
            // White Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  const TextField(
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Enter your phone number',
                      labelStyle: TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    obscureText: true,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Create a password',
                      labelStyle: TextStyle(fontSize: 14),
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    obscureText: true,
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelText: 'Confirm password',
                      labelStyle: TextStyle(fontSize: 14),
                      suffixIcon: Icon(Icons.visibility_off),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0C3D78),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(180, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
                  const SizedBox(height: 50), // leave space for characters
                  const Text(
                    'If you have an account, just ',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: goToSignIn,
                    child: const Text(
                      'Sign in now!',
                      style: TextStyle(
                        color: Color(0xFF0C3D78),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Left character - overlapping outside
            Positioned(
              left: -20,
              bottom: -40,
              child: Image.asset(
                'assets/left_character.png',
                width: 120,
                height: 180,
              ),
            ),

            // Right character - overlapping outside
            Positioned(
              right: -20,
              bottom: -40,
              child: Image.asset(
                'assets/right_character.png',
                width: 120,
                height: 180,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget buildDetailsStep1() {
    return Column(
      children: [
        // Profile Picture with "Add Image" icon
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: profileImagePath.isNotEmpty
                  ? FileImage(File(profileImagePath))
                  : null,
              child: profileImagePath.isEmpty
                  ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                  : null,
            ),

            Positioned(
              bottom: 0,
              right: 4,
              child: InkWell(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      profileImagePath = picked.path;
                    });
                  }
                },

                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Username
        TextField(
          controller: usernameController,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Phone number
        TextField(
          controller: phoneController,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            labelText: 'Enter your phone number',
            labelStyle: TextStyle(fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Store name
         TextField(
           controller: storeNameController,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Store name',
            labelStyle: TextStyle(fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Store address
         TextField(
           controller: storeAddressController,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Store address',
            labelStyle: TextStyle(fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Store type dropdown
        DropdownButtonFormField<String>(
          value: selectedStoreType,
          decoration: const InputDecoration(
            labelText: 'Store type',
            labelStyle: TextStyle(fontSize: 14),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
          items: ['Retail', 'Wholesale', 'Service']
              .map((e) => DropdownMenuItem<String>(
            value: e,
            child: Text(e),
          ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedStoreType = value;
              });
            }
          },
        ),


        const SizedBox(height: 24),

        // Confirm Button
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (profileImagePath.isEmpty) {
                Get.snackbar('Error', 'Please select a profile image');
                return;
              }

              try {
                final response = await _authService.registerSeller(
                  name: usernameController.text.trim(),
                  phone: phoneController.text.trim(),
                  password: passwordController.text,
                  storeName: storeNameController.text.trim(),
                  storeType: selectedStoreType,
                  address: storeAddressController.text.trim(),
                  imagePath: profileImagePath,
                );

                if (response['status'] == 'success') {
                  Get.snackbar('Success', 'Registration successful');
                  Get.off(() => const SignInScreen());
                } else {
                  Get.snackbar('Failed', response['message'] ?? 'Unknown error');
                }
              } catch (e) {
                Get.snackbar('Error', e.toString());
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C3D78),
              foregroundColor: Colors.white,
              minimumSize: const Size(180, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirm'),
          ),

        ),
      ],
    );
  }


  // Widget buildDetailsStep2() {
  //   return Column(
  //     children: [
  //       CircleAvatar(
  //         radius: 32,
  //         backgroundColor: Colors.grey[300],
  //         child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
  //       ),
  //       const SizedBox(height: 20),
  //       const TextField(
  //         decoration: InputDecoration(
  //           labelText: 'Username',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       const TextField(
  //         decoration: InputDecoration(
  //           labelText: 'Phone number',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       const TextField(
  //         decoration: InputDecoration(
  //           labelText: 'Store name',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       const TextField(
  //         decoration: InputDecoration(
  //           labelText: 'Store address',
  //           border: OutlineInputBorder(),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       DropdownButtonFormField<String>(
  //         decoration: const InputDecoration(
  //           labelText: 'Store type',
  //           border: OutlineInputBorder(),
  //         ),
  //         items: [
  //           'Retail',
  //           'Wholesale',
  //           'Service',
  //         ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  //         onChanged: (_) {},
  //       ),
  //       const SizedBox(height: 24),
  //       Center(
  //         child: ElevatedButton(
  //           onPressed: () {
  //             Get.to(() => const CreatePostScreen());
  //           },
  //           child: const Text('Confirm'),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}