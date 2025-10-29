import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/app_button.dart';
import 'package:tracks/utils/app_colors.dart';

/// Secondary button - uses the secondary coral/red color.
class SecondaryButton extends AppButton {
  /// Creates a secondary button.
  const SecondaryButton({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
  });

  @override
  Color get backgroundColor => AppColors.secondary;

  @override
  Color get shadowColor => Colors.transparent;

  @override
  Color get shadowColorPressed => Colors.transparent;
}
