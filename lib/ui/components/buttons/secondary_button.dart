import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/app_button.dart';
import 'package:tracks/utils/app_colors.dart';

/// Secondary button - uses the secondary coral/red color.
class SecondaryButton extends AppButton {
  final Color color = AppColors.secondary;

  /// Creates a secondary button.
  const SecondaryButton({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
  });

  @override
  Color get backgroundColor => color;
}
