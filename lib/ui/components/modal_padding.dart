import 'package:flutter/material.dart';

class ModalPadding extends StatelessWidget {
  final Widget child;

  const ModalPadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16, top: 24),
      child: child,
    );
  }
}