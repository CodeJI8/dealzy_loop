// import 'package:flutter/material.dart';
// import 'RegularPriceDialog.dart';
//
//
// class DiscountDialog extends StatelessWidget {
//   const DiscountDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       insetPadding: const EdgeInsets.symmetric(horizontal: 24),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFBACEDF).withOpacity(0.90),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.blue, width: 1),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     'What is the discount price percentage?',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => Navigator.pop(context),
//                   child: const Icon(Icons.close, size: 18, color: Colors.black),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 style: const TextStyle(fontSize: 12),
//                 decoration: InputDecoration(
//                   hintText: 'Discount Price',
//                   hintStyle: const TextStyle(fontSize: 12),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 10),
//
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 style: const TextStyle(fontSize: 12),
//                 decoration: InputDecoration(
//                   hintText: 'Discount By Expiring',
//                   hintStyle: const TextStyle(fontSize: 12),
//                   suffixIcon: const Icon(Icons.calendar_today, size: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context); // Close this DiscountDialog
//
//                 // Open the RegularPriceDialog
//                 showDialog(
//                   context: context,
//                   builder: (_) => const RegularPriceDialog(),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue[900],
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               ),
//               child: const Text(
//                 'Confirm',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
