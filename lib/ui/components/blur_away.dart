import 'package:flutter/material.dart';

class BlurAway extends StatelessWidget {
  final Widget child;

  const BlurAway({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
