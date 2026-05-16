import 'package:flutter/material.dart';

class CommonDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget>? actions;

  const CommonDialog({
    super.key,
    required this.title,
    required this.content,
    this.actions,
  });

  static Future<T?> show<T>(BuildContext context, {required String title, required Widget content, List<Widget>? actions}) {
    return showDialog<T>(
      context: context,
      builder: (context) => CommonDialog(title: title, content: content, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(child: SingleChildScrollView(child: content)),
            if (actions != null) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!.map((a) => Padding(padding: const EdgeInsets.only(left: 8), child: a)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
