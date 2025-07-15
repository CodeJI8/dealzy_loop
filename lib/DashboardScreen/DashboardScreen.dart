

  import 'package:flutter/material.dart';
  import 'package:get/get.dart';

  import '../createPost/AddOfferScreen.dart';
  import '../createPost/CreatePostScreen.dart';
  import '../profile/ProfileScreen.dart';
  import '../service/seller_auth_service.dart';
  import '../storage/token_storage.dart';


  class DashboardScreen extends StatefulWidget {


     DashboardScreen({super.key});

    @override
    State<DashboardScreen> createState() => _DashboardScreenState();
  }

  class _DashboardScreenState extends State<DashboardScreen> {
    final SellerAuthService _authService = SellerAuthService();
    List<dynamic> _deals = [];

    @override
    void initState() {
      super.initState();
      _loadDeals();
    }

    Future<void> _loadDeals() async {
      final token = await TokenStorage.getToken();

      if (token == null) {
        Get.snackbar("Login Required", "Please login first");
        return;
      }

      try {
        final deals = await _authService.getCurrentDeals(token, page: 1, limit: 5);
        setState(() {
          _deals = deals;
        });
      } catch (e) {
        print("Error loading deals: $e");
        Get.snackbar("Error", e.toString());
      }
    }



    //Widget starts from here


    @override
    Widget build(BuildContext context) {



      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 10,
          title: Row(
            children: const [

              SizedBox(width: 10),
              Text('9:41', style: TextStyle(color: Colors.black))
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dashboardIconButton(
                    Icons.add_circle_outline,
                    'CreatePost',
                    Colors.deepOrange,
                    onTap: () => Get.to(() =>  CreatePostScreen()),
                  ),

                  _dashboardIconButton(Icons.local_offer_outlined, 'add offer', Colors.lightBlue, onTap: () => Get.to(() => const AddOfferScreen())),
                  _dashboardIconButton(Icons.person_outline, 'profile', Colors.lightGreen, onTap: () => Get.to(() => const ProfileScreen())),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Current Deal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              _deals.isEmpty
                  ? const Text("No current deals available.")
                  : Column(
                children: _deals
                    .map((deal) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _dealCard(deal),
                ))
                    .toList(),
              ),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('View all ▼', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 20),
              const Text('Products List', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (_, index) => _productCard(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _dashboardIconButton(IconData icon, String label, Color color, {VoidCallback? onTap}) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
      );
    }

    Widget _dealCard(dynamic deal) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Image.asset('assets/watch1.png', width: 40, height: 40), // Replace with `deal['image']` if dynamic
        title: Text(deal['title'] ?? 'No title', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Exp ${deal['expiry_date'] ?? ''}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$${deal['old_price'] ?? ''}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
            Text('\$${deal['new_price'] ?? ''}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const Icon(Icons.close, size: 18, color: Colors.black),
          ],
        ),
      );
    }

    Widget _productCard() {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Image.asset('assets/watch1.png', width: 40, height: 40),
        title: const Text('Fossil Neutra Chronograph Ocean'),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('\$34  ', style: TextStyle(fontWeight: FontWeight.bold)),
                Icon(Icons.star, color: Colors.orange, size: 16),
                Text(' 4.5 Rating')
              ],
            ),
            Text('May 10, 2025 at 9:00 AM'),
          ],
        ),
      );
    }
  }
