import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/dashboard_provider.dart';
import '../models/dashboard_state.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    if (dashboardState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (dashboardState.error != null && dashboardState.metrics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle,
                  color: AppColors.red, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              dashboardState.error!,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
              onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    final data = dashboardState.metrics ?? const DashboardMetrics();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Non-blocking error banner (when stale data exists)
          if (dashboardState.error != null && dashboardState.metrics != null)
            _stagger(0, child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
              ),
              child: Row(children: [
                const Icon(LucideIcons.alertTriangle, size: 14, color: AppColors.amber),
                const SizedBox(width: 10),
                Expanded(child: Text('Dashboard data may be outdated. ${dashboardState.error}',
                    style: const TextStyle(fontSize: 12, color: AppColors.amber))),
                TextButton(
                  onPressed: () => ref.read(dashboardProvider.notifier).refresh(),
                  child: const Text('Retry', style: TextStyle(fontSize: 11, color: AppColors.amber)),
                ),
              ]),
            )),

          // ── KPI Cards ───────────────────────────────────
          _stagger(
            0,
            child: Row(
              children: [
                Expanded(
                  child: _KPICard(
                    label: 'TOTAL REVENUE',
                    value: data.revenueThisMonth.toInt(),
                    suffix: '₹',
                    delta: '+0%', // Backend doesn't provide delta yet
                    icon: LucideIcons.indianRupee,
                    accentColor: AppColors.primary,
                    controller: _entranceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    label: 'TOTAL SALES',
                    value: data.totalSales,
                    suffix: '',
                    delta: '+0%',
                    icon: LucideIcons.trendingUp,
                    accentColor: AppColors.cyan,
                    controller: _entranceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    label: 'ACTIVE RENTALS',
                    value: data.activeRentals,
                    suffix: '',
                    delta: '+0%',
                    icon: LucideIcons.repeat,
                    accentColor: AppColors.amber,
                    controller: _entranceController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _KPICard(
                    label: 'BATTERY USAGE',
                    value: 0, // Placeholder as batteryUsageStats is String
                    customValue: data.batteryUsageStats ?? 'N/A',
                    suffix: '',
                    delta: '0',
                    icon: LucideIcons.batteryCharging,
                    accentColor: AppColors.red,
                    controller: _entranceController,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Charts + Activity ───────────────────────────
          _stagger(
            1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Revenue Chart
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 380,
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Revenue Analytics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                _StatPill(
                                  '₹${data.revenueThisMonth.toInt()}',
                                  'This Month',
                                  AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                _StatPill(
                                  '${data.customerSatisfaction}',
                                  'Rating',
                                  AppColors.amber,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: _WeeklyBarChart(
                            controller: _entranceController,
                            values: data.weeklyRevenue,
                            days: data.weeklyDays,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Activity Feed
                Expanded(
                  child: Container(
                    height: 380,
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: dashboardState.activityFeed.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No recent activity',
                                    style: TextStyle(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: dashboardState.activityFeed.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    final item =
                                        dashboardState.activityFeed[index];
                                    return _ActivityItem(
                                      title: item.title,
                                      subtitle: item.message,
                                      time: _formatTime(item.createdAt),
                                      color: _getActivityColor(item.type),
                                      icon: _getActivityIcon(item.type),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Quick Actions ──────────────────────────────
          _stagger(
            2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _QuickAction(
                        icon: LucideIcons.plus,
                        label: 'Add Station',
                        color: AppColors.primary,
                      ),
                      _QuickAction(
                        icon: LucideIcons.packagePlus,
                        label: 'Add Battery',
                        color: AppColors.cyan,
                      ),
                      _QuickAction(
                        icon: LucideIcons.megaphone,
                        label: 'New Campaign',
                        color: AppColors.purple,
                      ),
                      _QuickAction(
                        icon: LucideIcons.download,
                        label: 'Export Report',
                        color: AppColors.amber,
                      ),
                      _QuickAction(
                        icon: LucideIcons.userPlus,
                        label: 'Invite User',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hrs ago';
      return '${diff.inDays} days ago';
    } catch (e) {
      return 'Recently';
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'low_stock':
        return AppColors.amber;
      case 'maintenance':
        return AppColors.cyan;
      case 'ticket':
        return AppColors.red;
      case 'rental':
        return AppColors.primary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'low_stock':
        return LucideIcons.alertTriangle;
      case 'maintenance':
        return LucideIcons.settings;
      case 'ticket':
        return LucideIcons.headphones;
      case 'rental':
        return LucideIcons.repeat;
      default:
        return LucideIcons.bell;
    }
  }

  Widget _stagger(int index, {required Widget child}) {
    final begin = index * 0.15;
    final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, _) {
        final t = Curves.easeOut.transform(
          ((_entranceController.value - begin) / (end - begin)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      );
}

// ═══════════════════════════════════════════════════════════════
// KPI CARD with count-up animation and accent top border
// ═══════════════════════════════════════════════════════════════

class _KPICard extends StatelessWidget {
  final String label;
  final int value;
  final String? customValue;
  final String suffix;
  final String delta;
  final IconData icon;
  final Color accentColor;
  final AnimationController controller;

  const _KPICard({
    required this.label,
    required this.value,
    this.customValue,
    required this.suffix,
    required this.delta,
    required this.icon,
    required this.accentColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeOut.transform(controller.value.clamp(0.0, 1.0));
        final currentValue = (value * t).toInt();
        final isPositive = delta.startsWith('+');
        final trendColor = isPositive ? AppColors.primary : AppColors.red;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent line
              Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 16, color: accentColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  customValue ?? '$suffix${_formatNumber(currentValue)}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.9,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  delta,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${n ~/ 1000},${(n % 1000).toString().padLeft(3, '0')}';
    }
    return n.toString();
  }
}

// ═══════════════════════════════════════════════════════════════
// ANIMATED BAR CHART
// ═══════════════════════════════════════════════════════════════

class _WeeklyBarChart extends StatelessWidget {
  final AnimationController controller;
  final List<double> values;
  final List<String> days;

  const _WeeklyBarChart({
    required this.controller,
    required this.values,
    required this.days,
  });

  static const _defaultDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    // If API returned no data, show empty state
    if (values.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.barChart3, size: 32, color: AppColors.textMuted),
            SizedBox(height: 10),
            Text('No revenue data available',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final count = values.length.clamp(1, 14);
    final displayValues = values.take(count).toList();
    final maxVal = displayValues
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final displayDays = days.isNotEmpty
        ? days.take(count).toList()
        : List.generate(count, (i) {
            final dayIndex = (DateTime.now().weekday - count + i + 7) % 7;
            return _defaultDays[dayIndex];
          });

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(count, (i) {
            final delay = 0.2 + i * 0.06;
            final t = Curves.easeOutCubic.transform(
              ((controller.value - delay) / 0.5).clamp(0.0, 1.0),
            );
            final isLatest = i == count - 1;
            final val = displayValues[i];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Opacity(
                      opacity: t,
                      child: Text(
                        val >= 1000
                            ? '₹${(val * t / 1000).toStringAsFixed(1)}k'
                            : '₹${(val * t).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isLatest
                              ? AppColors.primaryHover
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: (val / maxVal) * 200 * t,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isLatest
                              ? [
                                  AppColors.primary.withValues(alpha: 0.6),
                                  AppColors.primary
                                ]
                              : [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.35)
                                ],
                        ),
                        boxShadow: isLatest
                            ? [
                                BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, -2))
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      i < displayDays.length ? displayDays[i] : '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isLatest ? FontWeight.w700 : FontWeight.w400,
                        color: isLatest
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ACTIVITY FEED ITEM
// ═══════════════════════════════════════════════════════════════

class _ActivityItem extends StatefulWidget {
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  State<_ActivityItem> createState() => _ActivityItemState();
}

class _ActivityItemState extends State<_ActivityItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.shellBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(widget.icon, size: 14, color: widget.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              widget.time,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAT PILL & QUICK ACTION
// ═══════════════════════════════════════════════════════════════

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatPill(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withValues(alpha: 0.08)
              : AppColors.pageBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 14, color: widget.color),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    _hovered ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
