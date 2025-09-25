import 'package:flutter/material.dart';

class CardShell extends StatelessWidget {
  final double maxHeight;
  final Widget child;

  const CardShell({
    super.key,
    required this.maxHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
        ),
      ),
    );
  }
}
