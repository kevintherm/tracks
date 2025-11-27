import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/pressable.dart';

/// Abstract parent class for all app buttons.
/// Provides common functionality like styling and colors.
abstract class AppButton extends StatelessWidget {
  /// The widget to display inside the button.
  final Widget child;

  /// Custom padding for the button content.
  /// Defaults to [EdgeInsets.symmetric(vertical: 8, horizontal: 16)]
  final EdgeInsets? padding;

  /// The callback that is called when the button is tapped.
  final VoidCallback? onTap;

  /// Creates an app button.
  const AppButton({super.key, required this.child, this.onTap, this.padding});

  /// Returns the button's background color.
  Color get backgroundColor;

  /// Returns true if the button is disabled (onTap is null).
  bool get isDisabled => onTap == null;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
        child: Pressable(
          onTap: isDisabled ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
