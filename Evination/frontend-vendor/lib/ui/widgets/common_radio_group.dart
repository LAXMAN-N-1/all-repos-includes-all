import 'package:flutter/material.dart';

class CommonRadioGroup<T> extends StatelessWidget {
  final T groupValue;
  final ValueChanged<T?> onChanged;
  final List<CommonRadioOption<T>> options;

  const CommonRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        return RadioListTile<T>(
          title: Text(option.label, style: const TextStyle(fontSize: 14)),
          value: option.value,
          groupValue: groupValue,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          activeColor: Colors.black,
          dense: true,
        );
      }).toList(),
    );
  }
}

class CommonRadioOption<T> {
  final String label;
  final T value;

  CommonRadioOption({required this.label, required this.value});
}
