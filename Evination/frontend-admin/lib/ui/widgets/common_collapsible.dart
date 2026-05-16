import 'package:flutter/material.dart';

class CommonCollapsible extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final bool initiallyExpanded;

  const CommonCollapsible({
    super.key,
    required this.trigger,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<CommonCollapsible> createState() => _CommonCollapsibleState();
}

class _CommonCollapsibleState extends State<CommonCollapsible> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.trigger,
              const SizedBox(width: 4),
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(),
          secondChild: widget.content,
          crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
