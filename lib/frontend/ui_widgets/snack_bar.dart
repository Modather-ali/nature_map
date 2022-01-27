import 'package:flutter/material.dart';

SnackBar snackBar({
  required String message,
  required Color color,
}) {
  return SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    backgroundColor: color,
  );
}
