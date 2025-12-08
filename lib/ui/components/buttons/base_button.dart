import 'package:flutter/material.dart';
import 'package:tracks/ui/components/buttons/app_button.dart';

/// Primary button - uses the primary teal color.
class BaseButton extends AppButton {
  /// Creates a primary button.
  const BaseButton({
    super.key,
    required super.child,
    super.onTap,
    super.padding,
  });

  @override
  Color get backgroundColor => Colors.white;
}
