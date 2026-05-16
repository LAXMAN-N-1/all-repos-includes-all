import 'package:flutter/material.dart';

class CommonSelect<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? placeholder;
  final String? label;

  const CommonSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              hint: placeholder != null ? Text(placeholder!, style: TextStyle(color: Colors.grey[400])) : null,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
