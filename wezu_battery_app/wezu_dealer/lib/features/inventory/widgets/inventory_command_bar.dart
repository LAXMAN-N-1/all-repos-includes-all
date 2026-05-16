import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';

class InventoryCommandBar extends ConsumerStatefulWidget {
  const InventoryCommandBar({super.key});

  @override
  ConsumerState<InventoryCommandBar> createState() => _InventoryCommandBarState();
}

class _InventoryCommandBarState extends ConsumerState<InventoryCommandBar> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _searchFocused = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          _searchFocusNode.requestFocus();
        },
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          border: Border(
            bottom: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Center — Global Search
            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: _searchFocused ? 420 : 320,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _searchFocused
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Focus(
                    onFocusChange: (focused) {
                      setState(() => _searchFocused = focused);
                    },
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search batteries, stations, customers...',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          LucideIcons.search,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        suffixIcon: !_searchFocused
                            ? Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.pageBg,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.border,
                                  ),
                                ),
                                child: const Text(
                                  'Ctrl K',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (val) {
                        // Trigger search
                        if (val.isNotEmpty) {
                          ref.read(inventoryBatteriesProvider.notifier).setSearch(val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Right — Controls
            // Refresh
            _CommandBarIconButton(
              icon: LucideIcons.refreshCw,
              tooltip: 'Refresh data',
              onTap: () {
                ref.read(inventoryMetricsProvider.notifier).refresh();
                ref.read(inventoryBatteriesProvider.notifier).fetchPage();
              },
            ),
            const SizedBox(width: 8),
            // Export
            _CommandBarIconButton(
              icon: LucideIcons.download,
              tooltip: 'Export inventory',
              onTap: () => _showExportPanel(context),
            ),
            const SizedBox(width: 8),
            // Notification bell
            Stack(
              children: [
                _CommandBarIconButton(
                  icon: LucideIcons.bell,
                  tooltip: 'Notifications',
                  onTap: () {},
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportPanel(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(900, 56, 0, 0),
      color: AppColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      items: [
        _exportMenuItem(LucideIcons.fileSpreadsheet, 'Export All as CSV'),
        _exportMenuItem(LucideIcons.filter, 'Export Filtered View (CSV)'),
        _exportMenuItem(LucideIcons.fileText, 'Export as PDF Report'),
        _exportMenuItem(LucideIcons.calendar, 'Schedule Auto-Export'),
      ],
    );
  }

  PopupMenuItem _exportMenuItem(IconData icon, String label) {
    return PopupMenuItem(
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandBarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CommandBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_CommandBarIconButton> createState() => _CommandBarIconButtonState();
}

class _CommandBarIconButtonState extends State<_CommandBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hovered ? AppColors.cardBgHover : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _hovered ? AppColors.border : Colors.transparent,
              ),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
