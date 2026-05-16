import 'package:flutter/material.dart';

class CommonSheet extends StatelessWidget {
  final Widget child;
  final String title;

  const CommonSheet({super.key, required this.child, required this.title});

  static Future<void> show(BuildContext context, {required String title, required Widget child}) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 350,
            child: Material(
              child: CommonSheet(title: title, child: child),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}
