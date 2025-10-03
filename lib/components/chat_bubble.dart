import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  const ChatBubble({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
