import 'package:flutter/material.dart';

class CommonForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;

  const CommonForm({super.key, required this.formKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: child,
    );
  }
}

class CommonFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? errorText;

  const CommonFormField({
    super.key,
    required this.label,
    required this.child,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        child,
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: const TextStyle(fontSize: 12, color: Colors.red)),
        ],
      ],
    );
  }
}
