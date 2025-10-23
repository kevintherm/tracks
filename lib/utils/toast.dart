import 'package:flutter/material.dart';
import 'package:tracks/utils/consts.dart';

class Toast {
  final BuildContext context;

  Toast(this.context);

  ScaffoldMessengerState get _scm => ScaffoldMessenger.of(context);

  void success({required Widget content, Duration duration = snackBarShort}) {
    _scm.showSnackBar(
      SnackBar(
        duration: duration,
        content: content,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void error({required Widget content, Duration duration = snackBarShort}) {
    _scm.showSnackBar(
      SnackBar(
        duration: duration,
        content: content,
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void neutral({required Widget content, Duration duration = snackBarShort}) {
    _scm.showSnackBar(
      SnackBar(
        duration: duration,
        content: content,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
