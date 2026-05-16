import 'package:flutter/material.dart';

class CommonProgress extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;

  const CommonProgress({super.key, required this.value, this.height = 4.0});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: height,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
      ),
    );
  }
}
