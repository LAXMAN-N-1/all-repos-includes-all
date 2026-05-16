import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/colors.dart';

class ConfirmationModal extends StatefulWidget {
  final String title;
  final String description;
  final String confirmText;
  final String? requireMatch;
  final VoidCallback onConfirm;
  final bool isDanger;

  const ConfirmationModal({
    super.key,
    required this.title,
    required this.description,
    required this.confirmText,
    this.requireMatch,
    required this.onConfirm,
    this.isDanger = true,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String description,
    required String confirmText,
    String? requireMatch,
    required VoidCallback onConfirm,
    bool isDanger = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (c) => ConfirmationModal(
        title: title,
        description: description,
        confirmText: confirmText,
        requireMatch: requireMatch,
        onConfirm: onConfirm,
        isDanger: isDanger,
      ),
    );
  }

  @override
  State<ConfirmationModal> createState() => _ConfirmationModalState();
}

class _ConfirmationModalState extends State<ConfirmationModal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final TextEditingController _matchController = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..forward();
    _canConfirm = widget.requireMatch == null;
  }

  @override
  void dispose() {
    _c.dispose();
    _matchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.95,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: _c,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.isDanger
                        ? AppColors.red.withValues(alpha: 0.1)
                        : AppColors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isDanger
                        ? LucideIcons.alertOctagon
                        : LucideIcons.alertTriangle,
                    color: widget.isDanger ? AppColors.red : AppColors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                if (widget.requireMatch != null) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Type "${widget.requireMatch}" to confirm:',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _matchController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: widget.isDanger
                              ? AppColors.red
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    onChanged: (v) =>
                        setState(() => _canConfirm = v == widget.requireMatch),
                  ),
                  const SizedBox(height: 24),
                ],

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: AppColors.textSecondary,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canConfirm
                            ? () {
                                Navigator.of(context).pop();
                                widget.onConfirm();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: widget.isDanger
                              ? AppColors.red
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: widget.isDanger
                              ? AppColors.red.withValues(alpha: 0.3)
                              : AppColors.primary.withValues(alpha: 0.3),
                          disabledForegroundColor: Colors.white.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        child: Text(widget.confirmText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
