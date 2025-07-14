import 'package:seller_loop/splash/welcome_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class WelcomeView extends StatelessWidget {
  final controller = Get.put(WelcomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B4A8C),
      body: SafeArea(
        child: Obx(() {
          return Center(
            child: controller.step.value == 1
                ? _buildWelcomeCard()
                : _buildLocationCard(),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/ic_shopcenter.png',
        fit: BoxFit.cover,
        ),
        const SizedBox(height: 10),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "welcome",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Discover real-time deals from nearby grocery and convenience stores. Save money, reduce food waste, and support your local shops — all in one loop.\n\nLet’s shop smarter, together.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.nextStep,
                  style: _buttonStyle(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Next", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                )

              ),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildLocationCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/mask_group.png',
                    width: 300,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Image.asset(
                    'assets/location.png',
                    width: 60,
                    height: 60,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Allow us to access your location to provide better service and accurate results.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.requestLocationPermission,
                  style: _buttonStyle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Get Location",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.location_on),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );


  }


  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0B4A8C),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
