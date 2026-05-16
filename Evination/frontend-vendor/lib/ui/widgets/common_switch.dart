import 'package:flutter/material.dart';

class CommonSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const CommonSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black,
        ),
        if (label != null) ...[
          const SizedBox(width: 8),
          Text(label!),
        ],
      ],
    );
  }
}
