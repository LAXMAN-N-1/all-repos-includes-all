import 'package:flutter/material.dart';

class CommonToast {
  static void show(BuildContext context, String message, {
    String? description,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onUndo,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
            if (description != null)
              Text(description, style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.black87,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onUndo != null
            ? SnackBarAction(label: 'Undo', textColor: Colors.white, onPressed: onUndo)
            : null,
      ),
    );
  }
}
