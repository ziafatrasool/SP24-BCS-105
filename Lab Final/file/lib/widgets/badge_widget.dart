import 'package:flutter/material.dart';

class BadgeWidget extends StatelessWidget {
  final String title;

  const BadgeWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(title));
  }
}
