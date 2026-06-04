import 'package:flutter/material.dart';

class XPBar extends StatelessWidget {
  final double value;

  const XPBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      minHeight: 12,
      borderRadius: BorderRadius.circular(20),
    );
  }
}
