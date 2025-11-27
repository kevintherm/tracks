import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/app_button.dart';

/// Tertiary button - uses a lighter color for cancel, back, dismiss actions.
class TertiaryButton extends AppButton {
  /// Creates a tertiary button.
  const TertiaryButton({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
  });

  @override
  Color get backgroundColor => Colors.grey[200]!;
}
