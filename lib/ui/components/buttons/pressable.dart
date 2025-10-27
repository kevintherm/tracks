import 'package:flutter/material.dart';

/// A pressable wrapper that handles scale animation on tap.
/// Wraps any widget to make it respond to press gestures with scale animation.
class Pressable extends StatefulWidget {
  /// The widget to make pressable.
  final Widget child;

  /// The callback when the widget is tapped.
  final VoidCallback? onTap;
  final Duration? duration;

  /// Creates a pressable wrapper.
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.duration
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _isPressed ? 0.95 : 1.0;
    final bool isDisabled = widget.onTap == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : _onTapDown,
      onTapUp: isDisabled ? null : _onTapUp,
      onTapCancel: isDisabled ? null : _onTapCancel,
      child: AnimatedContainer(
        duration: widget.duration ?? const Duration(milliseconds: 75),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..scaleByDouble(scale, scale, 1, 1),
        transformAlignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
