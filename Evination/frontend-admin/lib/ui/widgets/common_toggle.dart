import 'package:flutter/material.dart';

class CommonToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget child; // Usually an Icon
  final String? tooltip;

  const CommonToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final widget = InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: value ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: IconTheme(
          data: IconThemeData(
            size: 20,
            color: value ? Colors.black : Colors.grey[600],
          ),
          child: child,
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: widget);
    }
    return widget;
  }
}

class CommonToggleGroup<T> extends StatelessWidget {
  final List<CommonToggleGroupItem<T>> items;
  final List<T> selectedValues;
  final ValueChanged<List<T>> onChanged;
  final bool multiple;

  const CommonToggleGroup({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.multiple = false,
  });

  void _handleTap(T value) {
    if (multiple) {
      final newValues = List<T>.from(selectedValues);
      if (newValues.contains(value)) {
        newValues.remove(value);
      } else {
        newValues.add(value);
      }
      onChanged(newValues);
    } else {
      if (selectedValues.contains(value)) {
        onChanged([]); // Toggle off if already selected
      } else {
        onChanged([value]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        final isSelected = selectedValues.contains(item.value);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: CommonToggle(
            value: isSelected,
            onChanged: (_) => _handleTap(item.value),
            tooltip: item.tooltip,
            child: item.icon,
          ),
        );
      }).toList(),
    );
  }
}

class CommonToggleGroupItem<T> {
  final T value;
  final Widget icon;
  final String? tooltip;

  CommonToggleGroupItem({
    required this.value,
    required this.icon,
    this.tooltip,
  });
}
