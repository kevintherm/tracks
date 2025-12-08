import 'package:flutter/material.dart';

class SafeKeyboard extends StatelessWidget {
  final Widget child;

  final offsetBottom;

  const SafeKeyboard({super.key, required this.child, this.offsetBottom = 100});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          // Add bottom padding so keyboard doesn't cause overflow
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - offsetBottom,
            ),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
