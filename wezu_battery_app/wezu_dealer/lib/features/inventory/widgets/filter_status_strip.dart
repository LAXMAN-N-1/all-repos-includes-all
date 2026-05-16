import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/inventory_provider.dart';

/// Zone 3 — Filter & Status Strip
/// Status pills, sort dropdown, view toggle, row count, column picker.
class FilterStatusStrip extends ConsumerStatefulWidget {
  const FilterStatusStrip({super.key});

  @override
  ConsumerState<FilterStatusStrip> createState() => _FilterStatusStripState();
}

class _FilterStatusStripState extends ConsumerState<FilterStatusStrip> {
  String _activeStatus = 'all';
  String _sortBy = 'health';
  bool _sortAsc = true;

  final _statuses = const [
    {'key': 'all', 'label': 'All'},
    {'key': 'available', 'label': 'Available'},
    {'key': 'reserved', 'label': 'Reserved'},
    {'key': 'maintenance', 'label': 'Maintenance'},
    {'key': 'defective', 'label': 'Damaged'},
  ];

  void _onPillTap(String status) {
    setState(() => _activeStatus = status);
    ref.read(inventoryBatteriesProvider.notifier).setFilter(
          status == 'all' ? null : status,
        );
  }

  void _onSortChanged(String? val) {
    if (val == _sortBy) {
      setState(() => _sortAsc = !_sortAsc);
    } else {
      setState(() {
        _sortBy = val!;
        _sortAsc = true;
      });
    }
    ref.read(inventoryBatteriesProvider.notifier).setSort(
      _sortBy,
      sortOrder: _sortAsc ? 'asc' : 'desc',
    );
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(inventoryBatteriesProvider);
    final metricsOutput = ref.watch(inventoryMetricsProvider).data;
    final showing = listState.items.length;
    final total = listState.total;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.pageBg,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Left — Status Pills (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: List.generate(_statuses.length, (i) {
                  final st = _statuses[i];
                  final isActive = _activeStatus == st['key'];
                  
                  // Only attach the count to 'defective' ('Damaged') to match user request
                  final count = st['key'] == 'defective' ? metricsOutput.damaged : null;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _StatusPill(
                      label: st['label'] as String,
                      count: count,
                      isActive: isActive,
                      onTap: () => _onPillTap(st['key'] as String),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Sort dropdown
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                icon: Icon(
                  _sortAsc ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                dropdownColor: AppColors.cardBg,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'health',
                    child: Text('Sort: Health'),
                  ),
                  DropdownMenuItem(
                    value: 'charge',
                    child: Text('Sort: Charge'),
                  ),
                  DropdownMenuItem(
                    value: 'serial',
                    child: Text('Sort: Battery ID'),
                  ),
                  DropdownMenuItem(
                    value: 'status',
                    child: Text('Sort: Status'),
                  ),
                ],
                onChanged: _onSortChanged,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Row count
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Showing $showing of $total',
              key: ValueKey('total-$total-$showing'),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatefulWidget {
  final String label;
  final int? count;
  final bool isActive;
  final VoidCallback onTap;

  const _StatusPill({
    required this.label,
    this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_StatusPill> createState() => _StatusPillState();
}

class _StatusPillState extends State<_StatusPill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : (_hovered ? AppColors.cardBgHover : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
              ),
              if (widget.count != null && widget.count! > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
              // Sliding underline indicator — now horizontal, not below
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 2,
                width: widget.isActive ? 16 : 0,
                margin: EdgeInsets.only(left: widget.isActive ? 6 : 0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
