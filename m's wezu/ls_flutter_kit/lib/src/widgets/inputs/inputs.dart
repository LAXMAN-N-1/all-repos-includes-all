import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated search bar that expands on focus.
class AnimatedSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const AnimatedSearchBar({super.key, this.hintText = 'Search...', this.onChanged, this.onClear, this.controller});

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(() => setState(() => _hasText = _ctrl.text.isNotEmpty));
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _ctrl.clear();
                  widget.onClear?.call();
                  widget.onChanged?.call('');
                },
              )
            : null,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// OTP / PIN code input widget with auto-focus advancing.
class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final bool obscure;

  const OtpInput({super.key, this.length = 6, required this.onCompleted, this.obscure = false});

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focuses;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focuses = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focuses) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 48,
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focuses[i],
            textAlign: TextAlign.center,
            obscureText: widget.obscure,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && i < widget.length - 1) {
                _focuses[i + 1].requestFocus();
              }
              if (_code.length == widget.length) widget.onCompleted(_code);
            },
          ),
        );
      }),
    );
  }
}

/// Phone number input with country code prefix.
class PhoneInput extends StatelessWidget {
  final TextEditingController? controller;
  final String countryCode;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PhoneInput({super.key, this.controller, this.countryCode = '+91', this.validator, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: validator,
      onChanged: onChanged,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
      decoration: InputDecoration(
        hintText: 'Phone number',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(countryCode, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Container(width: 1, height: 24, color: Theme.of(context).dividerColor),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
