import 'package:flutter/material.dart';

class SafeKeyboard extends StatelessWidget {
  final Widget child;

  const SafeKeyboard({super.key, required this.child});

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
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 100),
            child: IntrinsicHeight(child: child),
          ),
        );
      },
    );
  }
}
