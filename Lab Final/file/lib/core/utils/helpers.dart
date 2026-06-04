import 'package:flutter/material.dart';

int calculateLevel(int points) {
  return (points ~/ 500) + 1;
}

class Helpers {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
