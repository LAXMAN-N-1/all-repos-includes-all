import 'package:flutter/material.dart';

class MenuInfoScreen extends StatelessWidget {
  final String title;
  final String description;

  const MenuInfoScreen({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1A1A1A),
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
