import 'package:flutter/material.dart';
import 'package:tracks/utils/app_colors.dart';

class SecondaryButton extends StatefulWidget {
  /// The text to display inside the button.
  final Widget child;
  final EdgeInsets? padding;

  /// The callback that is called when the button is tapped.
  final VoidCallback? onTap;

  /// Creates a primary button.
  ///
  /// The [text] argument must not be null.
  const SecondaryButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  _SecondaryButtonState createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  /// Tracks the pressed state to drive the animation.
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
    // Trigger the external onTap callback if provided.
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define animated properties based on the pressed state.
    final double scale = _isPressed ? 0.95 : 1.0;
    final double elevation = _isPressed ? 2.0 : 4.0;
    final Color shadowColor = _isPressed
        ? AppColors.darkSecondary.withValues(alpha: 0.2) // Lighter shadow when pressed
        : AppColors.darkSecondary.withValues(alpha: 0.5); // 0.5 opacity

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        // Apply the scale transformation
        transform: Matrix4.identity()..scaleByDouble(scale, scale, 1, 1),
        transformAlignment: Alignment.center,
        child: Card(
          margin: EdgeInsets.zero,
          color: AppColors.secondary,
          elevation: elevation, // Animated elevation
          shadowColor: shadowColor, // Animated shadow color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}