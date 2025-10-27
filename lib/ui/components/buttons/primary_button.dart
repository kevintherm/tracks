import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/app_button.dart';
import 'package:tracks/utils/app_colors.dart';

/// Primary button - uses the primary teal color.
class PrimaryButton extends AppButton {
  /// Creates a primary button.
  const PrimaryButton({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
  });

  @override
  Color get backgroundColor => AppColors.primary;

  @override
  Color get shadowColor => Colors.grey.withValues(alpha: 0.2);

  @override
  Color get shadowColorPressed => Colors.grey.withValues(alpha: 0.15);
}
