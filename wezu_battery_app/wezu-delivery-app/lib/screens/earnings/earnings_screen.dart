import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/transaction_model.dart';
import '../../repositories/earnings_repository.dart';
import '../../repositories/order_repository.dart';
import '../dashboard/dashboard_view_model.dart';

enum _ActivityType { trips, deliveries, promotions, other }

enum _ActivityFeature { extra, surge }

enum _DatePreset { custom, today, yesterday }

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _showActivity = false;

  DateTimeRange _customRange = _lastSevenDays();
  _DatePreset _datePreset = _DatePreset.custom;
  final Set<_ActivityType> _types = {};
  final Set<_ActivityFeature> _features = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<EarningsRepository>().fetchBalance();
      context.read<EarningsRepository>().fetchTransactions(Timeframe.monthly);
      context.read<OrderRepository>().fetchAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final earningsRepo = context.watch<EarningsRepository>();
    final ordersRepo = context.watch<OrderRepository>();
    final dashboard = context.watch<DashboardViewModel>();

    final period = _selectedRange;
    final periodLabel = _rangeLabel(period);

    final tripsCount = ordersRepo.orders.where((order) {
      if (order.status != OrderStatus.delivered) return false;
      return !order.timestamp.isBefore(period.start) &&
          !order.timestamp.isAfter(period.end.add(const Duration(days: 1)));
    }).length;

    final transactions = _applyFilters(earningsRepo.transactions);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _showActivity
            ? _buildActivityView(periodLabel, transactions)
            : RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([
                    context.read<EarningsRepository>().fetchBalance(),
                    context.read<EarningsRepository>().fetchTransactions(
                      Timeframe.monthly,
                    ),
                    context.read<OrderRepository>().fetchAssignments(),
                  ]);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Earnings',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 56,
                            letterSpacing: -1.8,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/help-support'),
                          icon: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.help_outline, color: Colors.black),
                              SizedBox(width: 4),
                              Text(
                                'Help',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      periodLabel,
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${earningsRepo.totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 58,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _metricRow('Online', dashboard.isOnline ? 'Live' : '0 s'),
                    _metricRow('Trips', '$tripsCount'),
                    _metricRow('Points', '0'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showActivity = true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF0F0F0),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'See details',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Wallet',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        letterSpacing: -1.4,
                        fontWeight: FontWeight.w900,
                        height: 0.95,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE6E6E6)),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance',
                            style: TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${earningsRepo.totalBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              letterSpacing: -1,
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your wallet reflects payout-ready balance and recent transactions.',
                            style: TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/wallet'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF0F0F0),
                                foregroundColor: Colors.black,
                                elevation: 0,
                              ),
                              child: const Text('View details'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildActivityView(
    String periodLabel,
    List<Transaction> transactions,
  ) {
    final start = DateFormat('d MMM yyyy').format(_selectedRange.start);
    final end = DateFormat('d MMM yyyy').format(_selectedRange.end);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showActivity = false),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              const Expanded(
                child: Text(
                  'Earnings activity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 38,
                    letterSpacing: -1,
                  ),
                ),
              ),
              IconButton(
                onPressed: _openFilters,
                icon: const Icon(Icons.filter_list, color: Colors.black),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _activityChip(
                'Type',
                isActive: _types.isNotEmpty,
                onTap: _openFilters,
              ),
              const SizedBox(width: 8),
              _activityChip(
                'Feature',
                isActive: _features.isNotEmpty,
                onTap: _openFilters,
              ),
              const SizedBox(width: 8),
              _activityChip(periodLabel, isActive: true, onTap: _openFilters),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: transactions.isEmpty
              ? Container(
                  width: double.infinity,
                  color: const Color(0xFFF5F5F5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          'No activities found between $start - $end. Please narrow your search.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton.icon(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.tune, color: Colors.black),
                        label: const Text(
                          'Edit filters',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    final isDebit = item.type == TransactionType.debit;
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF3F3F3),
                        child: Icon(
                          isDebit ? Icons.north_east : Icons.south_west,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('d MMM yyyy, hh:mm a').format(item.date),
                        style: const TextStyle(color: Color(0xFF787878)),
                      ),
                      trailing: Text(
                        item.formattedAmount,
                        style: TextStyle(
                          color: isDebit
                              ? const Color(0xFF444444)
                              : Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: transactions.length,
                ),
        ),
      ],
    );
  }

  Widget _metricRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFECECEC), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityChip(
    String label, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? Colors.black : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _FilterSheet(
          initialTypes: _types,
          initialFeatures: _features,
          initialPreset: _datePreset,
          initialRange: _customRange,
        );
      },
    );

    if (result == null) return;

    setState(() {
      _types
        ..clear()
        ..addAll(result.types);
      _features
        ..clear()
        ..addAll(result.features);
      _datePreset = result.preset;
      _customRange = result.customRange;
    });
  }

  DateTimeRange get _selectedRange {
    final now = DateTime.now();

    switch (_datePreset) {
      case _DatePreset.today:
        final day = DateUtils.dateOnly(now);
        return DateTimeRange(start: day, end: day);
      case _DatePreset.yesterday:
        final day = DateUtils.dateOnly(now.subtract(const Duration(days: 1)));
        return DateTimeRange(start: day, end: day);
      case _DatePreset.custom:
        return _customRange;
    }
  }

  static DateTimeRange _lastSevenDays() {
    final today = DateUtils.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 6));
    return DateTimeRange(start: start, end: today);
  }

  String _rangeLabel(DateTimeRange range) {
    final sameYear = range.start.year == range.end.year;
    final startFmt = DateFormat('d MMM').format(range.start);
    final endFmt = sameYear
        ? DateFormat('d MMM').format(range.end)
        : DateFormat('d MMM yyyy').format(range.end);
    return '$startFmt - $endFmt';
  }

  List<Transaction> _applyFilters(List<Transaction> source) {
    final range = _selectedRange;

    bool hasTypeFilter = _types.isNotEmpty;
    bool hasFeatureFilter = _features.isNotEmpty;

    return source.where((txn) {
      final date = DateUtils.dateOnly(txn.date);
      if (date.isBefore(range.start) || date.isAfter(range.end)) {
        return false;
      }

      final lower = txn.title.toLowerCase();
      final type = _mapType(lower);

      if (hasTypeFilter && !_types.contains(type)) {
        return false;
      }

      if (hasFeatureFilter) {
        final txnFeatures = _mapFeatures(lower);
        if (txnFeatures.isEmpty) return false;
        if (!_features.any(txnFeatures.contains)) return false;
      }

      return true;
    }).toList();
  }

  _ActivityType _mapType(String lowerTitle) {
    if (lowerTitle.contains('trip')) return _ActivityType.trips;
    if (lowerTitle.contains('deliver')) return _ActivityType.deliveries;
    if (lowerTitle.contains('promo') || lowerTitle.contains('bonus')) {
      return _ActivityType.promotions;
    }
    return _ActivityType.other;
  }

  Set<_ActivityFeature> _mapFeatures(String lowerTitle) {
    final result = <_ActivityFeature>{};
    if (lowerTitle.contains('surge')) {
      result.add(_ActivityFeature.surge);
    }
    if (lowerTitle.contains('tip') || lowerTitle.contains('extra')) {
      result.add(_ActivityFeature.extra);
    }
    return result;
  }
}

class _FilterResult {
  final Set<_ActivityType> types;
  final Set<_ActivityFeature> features;
  final _DatePreset preset;
  final DateTimeRange customRange;

  const _FilterResult({
    required this.types,
    required this.features,
    required this.preset,
    required this.customRange,
  });
}

class _FilterSheet extends StatefulWidget {
  final Set<_ActivityType> initialTypes;
  final Set<_ActivityFeature> initialFeatures;
  final _DatePreset initialPreset;
  final DateTimeRange initialRange;

  const _FilterSheet({
    required this.initialTypes,
    required this.initialFeatures,
    required this.initialPreset,
    required this.initialRange,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<_ActivityType> _types;
  late Set<_ActivityFeature> _features;
  late _DatePreset _preset;
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    _types = {...widget.initialTypes};
    _features = {...widget.initialFeatures};
    _preset = widget.initialPreset;
    _range = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    final rangeLabel =
        '${DateFormat('dd/MM').format(_range.start)} - ${DateFormat('dd/MM').format(_range.end)}';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _types.clear();
                      _features.clear();
                      _preset = _DatePreset.custom;
                      _range = _EarningsScreenState._lastSevenDays();
                    });
                  },
                  child: const Text(
                    'Clear all',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Trip types',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _checkTile(
              title: 'Trips',
              icon: Icons.directions_car_outlined,
              checked: _types.contains(_ActivityType.trips),
              onTap: () => _toggleType(_ActivityType.trips),
            ),
            _checkTile(
              title: 'Deliveries',
              icon: Icons.shopping_bag_outlined,
              checked: _types.contains(_ActivityType.deliveries),
              onTap: () => _toggleType(_ActivityType.deliveries),
            ),
            _checkTile(
              title: 'Promotions',
              icon: Icons.local_offer_outlined,
              checked: _types.contains(_ActivityType.promotions),
              onTap: () => _toggleType(_ActivityType.promotions),
            ),
            _checkTile(
              title: 'Other',
              icon: Icons.grid_view,
              checked: _types.contains(_ActivityType.other),
              onTap: () => _toggleType(_ActivityType.other),
            ),
            const SizedBox(height: 10),
            const Text(
              'Trip features',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            _checkTile(
              title: 'Extra added by customer',
              icon: Icons.add_circle_outline,
              checked: _features.contains(_ActivityFeature.extra),
              onTap: () => _toggleFeature(_ActivityFeature.extra),
            ),
            _checkTile(
              title: 'Surge',
              icon: Icons.bolt_outlined,
              checked: _features.contains(_ActivityFeature.surge),
              onTap: () => _toggleFeature(_ActivityFeature.surge),
            ),
            const SizedBox(height: 10),
            const Text(
              'Dates',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _dateChip(
                  label: rangeLabel,
                  selected: _preset == _DatePreset.custom,
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now(),
                      initialDateRange: _range,
                    );
                    if (picked == null) return;
                    setState(() {
                      _range = picked;
                      _preset = _DatePreset.custom;
                    });
                  },
                  icon: Icons.calendar_today_outlined,
                ),
                _dateChip(
                  label: 'Today',
                  selected: _preset == _DatePreset.today,
                  onTap: () => setState(() => _preset = _DatePreset.today),
                ),
                _dateChip(
                  label: 'Yesterday',
                  selected: _preset == _DatePreset.yesterday,
                  onTap: () => setState(() => _preset = _DatePreset.yesterday),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _FilterResult(
                      types: _types,
                      features: _features,
                      preset: _preset,
                      customRange: _range,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Apply', style: TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _checkTile({
    required String title,
    required IconData icon,
    required bool checked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.black,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.black : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleType(_ActivityType type) {
    setState(() {
      if (_types.contains(type)) {
        _types.remove(type);
      } else {
        _types.add(type);
      }
    });
  }

  void _toggleFeature(_ActivityFeature feature) {
    setState(() {
      if (_features.contains(feature)) {
        _features.remove(feature);
      } else {
        _features.add(feature);
      }
    });
  }
}
