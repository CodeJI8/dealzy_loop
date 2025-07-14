import 'package:get/get.dart';

class HomeController extends GetxController {
  final categories = ['Watch', 'Clothing', 'Face', 'Electrical', 'Shoes'];
  final regularOffers = [
    {'name': 'Gaming Keyboard', 'price': '\$20'},
    {'name': 'Gaming Mouse', 'price': '\$20'},
  ];
  final expiringOffers = [
    {'name': 'Tomato', 'price': '\$20  \$15'},
    {'name': 'Potatoes', 'price': '\$30  \$15'},
  ];
  final clearanceOffers = [
    {'name': 'T-shirt', 'price': '\$20'},
    {'name': 'Sneakers', 'price': '\$20'},
  ];
}
