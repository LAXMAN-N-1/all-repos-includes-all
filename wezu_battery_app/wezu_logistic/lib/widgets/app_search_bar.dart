import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';

/// Standardised search bar used across all screens.
///
/// Features:
/// - 300ms debounce on [onChanged] to avoid excessive API calls
/// - Built-in clear button when text is non-empty
/// - Optional [onSubmitted] for explicit submit actions
/// - Optional [initialValue] to pre-populate from provider state
class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? initialValue;
  final Duration debounceDuration;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(covariant AppSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if the external value actually changed and it's not what we already have
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // Rebuild to show/hide clear button
    
    // Cancel the previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    // Start a new timer
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(value);
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasText = _controller.text.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: SearchBar(
        controller: _controller,
        hintText: widget.hintText,
        hintStyle: WidgetStatePropertyAll(
          AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
        ),
        leading: Icon(Icons.search, color: AppColors.textSecondary),
        trailing: [
          if (hasText)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: AppColors.textSecondary,
              onPressed: _clear,
              splashRadius: 18,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
        ],
        onChanged: _onChanged,
        onSubmitted: widget.onSubmitted,
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textStyle: WidgetStatePropertyAll(
          AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
