import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset('assets/home_logo.png', width: 120),
            ),
            const SizedBox(height: 16),

            Center(
              child: Text(
                'Dealzyloop Seller App',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Version 1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'About Dealzyloop Seller App',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This is the official Seller/Vendor application of Dealzyloop. '
                  'It allows shop owners and vendors to create and manage their deals and products directly from their mobile device.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            Text(
              'Key Features for Sellers:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _bullet('Upload and add new products quickly.'),
            _bullet('Edit and manage your existing products.'),
            _bullet('Track status of submitted products.'),
            _bullet('Products are reviewed and approved by Dealzyloop Admin Panel before appearing to customers.'),
            _bullet('Once approved, your deals/products become visible to customers in the Dealzyloop Customer App.'),

            const SizedBox(height: 24),
            Text(
              'Why Dealzyloop?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dealzyloop connects local shops and vendors with customers looking for deals, clearance items, and surplus stock. '
                  'Our seller app gives you the tools to reach more customers and keep your product listings up to date with ease.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                '© 2025 Dealzyloop Ltd. All rights reserved.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
