import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/time_utils.dart';
import '../providers/customer_provider.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});
  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _searchQuery = '';
  String _statusFilter = 'All';
  dynamic _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12;
    final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
        animation: _c,
        builder: (c, _) {
          final t = Curves.easeOut
              .transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
          return Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 16 * (1 - t)), child: child));
        });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerProvider);
    final allCustomers = state.customers;

    // KPI
    final total = allCustomers.length;
    final active =
        allCustomers.where((c) => c.status.toLowerCase() == 'active').length;
    final totalRentals =
        allCustomers.fold<int>(0, (sum, c) => sum + c.totalRentals);
    final avgRentals =
        total > 0 ? (totalRentals / total).toStringAsFixed(1) : '0';

    // Filter
    final filtered = allCustomers.where((c) {
      if (_statusFilter != 'All' &&
          c.status.toLowerCase() != _statusFilter.toLowerCase()) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c.name.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            c.phone.contains(q);
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPI Row
        _stagger(0,
            child: Row(children: [
              Expanded(
                  child: _KpiCard(
                      label: 'TOTAL CUSTOMERS',
                      value: '$total',
                      icon: LucideIcons.users,
                      accent: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'ACTIVE',
                      value: '$active',
                      icon: LucideIcons.userCheck,
                      accent: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'TOTAL RENTALS',
                      value: '$totalRentals',
                      icon: LucideIcons.repeat,
                      accent: AppColors.cyan)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'AVG RENTALS/USER',
                      value: avgRentals,
                      icon: LucideIcons.barChart2,
                      accent: AppColors.purple)),
            ])),
        const SizedBox(height: 20),

        // Search & Filter
        _stagger(1,
            child: Row(children: [
              Expanded(
                  flex: 3,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search by name, email, or phone...',
                      prefixIcon: const Icon(LucideIcons.search,
                          color: AppColors.textTertiary, size: 16),
                      filled: true,
                      fillColor: AppColors.pageBg,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  )),
              const SizedBox(width: 12),
              ...['All', 'Active', 'Inactive'].map((s) {
                final sel = _statusFilter == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _statusFilter = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.border),
                      ),
                      child: Text(s,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.textSecondary)),
                    ),
                  ),
                );
              }),
            ])),
        const SizedBox(height: 16),

        // Customers Table + Detail Panel
        _stagger(2,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: _selectedCustomer != null ? 3 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Customers (${filtered.length})',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700)),
                                    TextButton.icon(
                                        icon: const Icon(LucideIcons.refreshCw,
                                            size: 14),
                                        label: const Text('Refresh',
                                            style: TextStyle(fontSize: 12)),
                                        onPressed: () => ref
                                            .read(customerProvider.notifier)
                                            .refresh()),
                                  ])),
                          const Divider(height: 1),
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12)),
                            child: state.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Center(
                                        child: CircularProgressIndicator()))
                                : state.error != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Center(
                                            child: Text('Error: ${state.error}',
                                                style: const TextStyle(
                                                    color: AppColors.red))))
                                    : filtered.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(40),
                                            child: Center(
                                                child: Text(
                                                    'No customers found',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textSecondary))))
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStateProperty.all(
                                                      AppColors
                                                          .pageBg
                                                          .withValues(
                                                              alpha: 0.5)),
                                              columns: const [
                                                DataColumn(
                                                    label: Text('CUSTOMER',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('CONTACT',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('TOTAL RENTALS',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('STATUS',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('JOINED',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                              ],
                                              rows: filtered.map((c) {
                                                final isActive =
                                                    c.status.toLowerCase() ==
                                                        'active';
                                                final initials = c.name
                                                    .split(' ')
                                                    .map((w) => w.isNotEmpty
                                                        ? w[0]
                                                        : '')
                                                    .take(2)
                                                    .join()
                                                    .toUpperCase();
                                                final isSelected =
                                                    _selectedCustomer?.id ==
                                                        c.id;

                                                return DataRow(
                                                  selected: isSelected,
                                                  color: WidgetStateProperty
                                                      .resolveWith((states) =>
                                                          isSelected
                                                              ? AppColors
                                                                  .primary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.06)
                                                              : null),
                                                  onSelectChanged: (_) =>
                                                      setState(() =>
                                                          _selectedCustomer =
                                                              c),
                                                  cells: [
                                                    DataCell(Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor:
                                                                AppColors
                                                                    .primary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.12),
                                                            child: Text(
                                                                initials,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    color: AppColors
                                                                        .primary)),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(c.name,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            13)),
                                                                Text(c.email,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: AppColors
                                                                            .textTertiary)),
                                                              ]),
                                                        ])),
                                                    DataCell(Text(c.phone,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary,
                                                            fontFamily:
                                                                'monospace'))),
                                                    DataCell(Text(
                                                        '${c.totalRentals}',
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14))),
                                                    DataCell(Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: (isActive
                                                                ? AppColors
                                                                    .primary
                                                                : AppColors
                                                                    .textTertiary)
                                                            .withValues(
                                                                alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        border: Border.all(
                                                            color: (isActive
                                                                    ? AppColors
                                                                        .primary
                                                                    : AppColors
                                                                        .textTertiary)
                                                                .withValues(
                                                                    alpha:
                                                                        0.3)),
                                                      ),
                                                      child: Text(
                                                          c.status
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              color: isActive
                                                                  ? AppColors
                                                                      .primary
                                                                  : AppColors
                                                                      .textTertiary,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                    )),
                                                    DataCell(Text(
                                                        _formatJoinedDate(
                                                            c.joinedAt),
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textTertiary))),
                                                  ],
                                                );
                                              }).toList(),
                                            )),
                          ),
                        ]),
                  )),

              // Detail Side Panel
              if (_selectedCustomer != null) ...[
                const SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: _buildCustomerDetailPanel(_selectedCustomer!)),
              ],
            ])),
      ]),
    );
  }

  Widget _buildCustomerDetailPanel(dynamic customer) {
    final isActive = customer.status.toLowerCase() == 'active';
    final initials = customer.name
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(initials,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(customer.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('Joined ${_formatJoinedDate(customer.joinedAt)}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ])),
            IconButton(
                icon: const Icon(LucideIcons.x,
                    size: 16, color: AppColors.textTertiary),
                onPressed: () => setState(() => _selectedCustomer = null)),
          ]),
        ),
        const Divider(height: 1),

        // Body
        Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Contact Info
              const Text('CONTACT INFORMATION',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _infoRow(LucideIcons.mail, 'Email', customer.email),
              const SizedBox(height: 10),
              _infoRow(LucideIcons.phone, 'Phone', customer.phone),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(LucideIcons.activity,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 8),
                const Text('Status',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        (isActive ? AppColors.primary : AppColors.textTertiary)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(customer.status.toUpperCase(),
                      style: TextStyle(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 24),

              // Rental Stats
              const Text('RENTAL STATISTICS',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.pageBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    const Icon(LucideIcons.repeat,
                        size: 16, color: AppColors.cyan),
                    const SizedBox(height: 6),
                    Text('${customer.totalRentals}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Text('Total Rentals',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textTertiary)),
                  ]),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.pageBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border)),
                  child: Column(children: [
                    const Icon(LucideIcons.battery,
                        size: 16, color: AppColors.primary),
                    const SizedBox(height: 6),
                    const Text('—',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    const Text('Active Rentals',
                        style: TextStyle(
                            fontSize: 10, color: AppColors.textTertiary)),
                  ]),
                )),
              ]),
              const SizedBox(height: 24),

              // Actions
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  icon: const Icon(LucideIcons.mail, size: 14),
                  label: const Text('Email', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Email composer opened'),
                        backgroundColor: AppColors.primary));
                  },
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: ElevatedButton.icon(
                  icon: const Icon(LucideIcons.ban, size: 14),
                  label: Text(isActive ? 'Suspend' : 'Activate',
                      style: const TextStyle(fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Customer ${isActive ? 'suspended' : 'activated'}'),
                        backgroundColor: AppColors.primary));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isActive ? AppColors.amber : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12)),
                )),
              ]),
            ])),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textTertiary),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const Spacer(),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary)),
    ]);
  }

  String _formatJoinedDate(String? iso) {
    final formatted = TimeUtils.dateOnly(iso);
    return formatted == '—' ? 'N/A' : formatted;
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.accent});
  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.2)
                  : AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: widget.accent,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4),
                        blurRadius: 6)
                  ])),
          Row(children: [
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.6))),
          ]),
          const SizedBox(height: 12),
          Text(widget.value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5)),
        ]),
      ),
    );
  }
}
