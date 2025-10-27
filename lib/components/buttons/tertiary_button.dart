import 'package:flutter/material.dart';
import 'package:tracks/components/buttons/app_button.dart';

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
  Color get backgroundColor => Colors.grey[500]!;

  @override
  Color get shadowColor => Colors.transparent;

  @override
  Color get shadowColorPressed => Colors.transparent;
}
