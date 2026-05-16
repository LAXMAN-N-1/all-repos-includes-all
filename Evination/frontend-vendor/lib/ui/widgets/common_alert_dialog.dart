import 'package:flutter/material.dart';

class CommonAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;

  const CommonAlertDialog({
    super.key,
    required this.title,
    required this.description,
    this.cancelText = 'Cancel',
    this.confirmText = 'Continue',
    required this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onConfirm,
    String cancelText = 'Cancel',
    String confirmText = 'Continue',
    Color? confirmButtonColor,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CommonAlertDialog(
        title: title,
        description: description,
        onConfirm: onConfirm,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmButtonColor: confirmButtonColor,
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      content: Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmButtonColor ?? Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
