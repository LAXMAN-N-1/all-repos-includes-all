import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/colors.dart';
import '../providers/sales_provider.dart';
import '../../stations/providers/stations_provider.dart';

class TransactionFilterDrawer extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic> filters) onApply;
  final VoidCallback onReset;

  const TransactionFilterDrawer({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  @override
  ConsumerState<TransactionFilterDrawer> createState() =>
      _TransactionFilterDrawerState();
}

class _TransactionFilterDrawerState
    extends ConsumerState<TransactionFilterDrawer> {
  DateTime? _fromDate;
  DateTime? _toDate;
  final List<String> _selectedTypes = [];
  final List<String> _selectedStatuses = [];
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();
  final TextEditingController _batteryIdController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  String? _selectedStationId;

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    _batteryIdController.dispose();
    _customerNameController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedTypes.clear();
      _selectedStatuses.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
      _batteryIdController.clear();
      _customerNameController.clear();
      _selectedStationId = null;
    });
    widget.onReset();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 380,
      backgroundColor: AppColors.cardBg,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Date Range'),
                  _buildDateRangePicker(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Transaction Types'),
                  _buildCheckboxes([
                    'Rental Income',
                    'Commission',
                    'Refund',
                    'Penalty',
                    'Bonus',
                    'Adjustment'
                  ], _selectedTypes),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Status'),
                  _buildCheckboxes(['Success', 'Pending', 'Failed', 'Refunded'],
                      _selectedStatuses),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Amount Range'),
                  _buildAmountRange(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Technical Details'),
                  _buildDynamicSelector('Battery ID', 'Select Battery',
                      _batteryIdController, _getUniqueBatteryIds()),
                  const SizedBox(height: 16),
                  _buildDynamicSelector('Customer Name', 'Select Customer',
                      _customerNameController, _getUniqueCustomerNames()),
                  const SizedBox(height: 16),
                  _buildStationSelector(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 16, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Advanced Filters',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8),
      ),
    );
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textTertiary, fontSize: 13),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangePicker() {
    return Row(
      children: [
        Expanded(child: _buildDateInput(_fromDate, 'From')),
        const SizedBox(width: 12),
        Expanded(child: _buildDateInput(_toDate, 'To')),
      ],
    );
  }

  Widget _buildDateInput(DateTime? date, String label) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            if (label == 'From')
              _fromDate = picked;
            else
              _toDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
            color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
        child: Text(
          date == null ? label : DateFormat('dd MMM, yyyy').format(date),
          style: TextStyle(
              color: date == null ? AppColors.textTertiary : Colors.white,
              fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildCheckboxes(List<String> options, List<String> selected) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected)
                selected.remove(option);
              else
                selected.add(option);
            });
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(LucideIcons.check,
                        size: 12, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(option,
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountRange() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildTextField('Min (₹)', '0', _minAmountController)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildTextField(
                    'Max (₹)', '1,00,000+', _maxAmountController)),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _reset,
              child: const Text('Reset',
                  style: TextStyle(color: AppColors.textTertiary)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                final mappedTypes = _selectedTypes.map((t) {
                  switch (t) {
                    case 'Rental Income':
                      return 'RENTAL_INCOME';
                    case 'Commission':
                      return 'COMMISSION';
                    case 'Refund':
                      return 'REFUND';
                    case 'Penalty':
                      return 'PENALTY';
                    case 'Bonus':
                      return 'BONUS';
                    case 'Adjustment':
                      return 'ADJUSTMENT';
                    default:
                      return t.toUpperCase();
                  }
                }).toList();

                final mappedStatuses = _selectedStatuses.map((s) {
                  switch (s) {
                    case 'Success':
                      return 'SUCCESS';
                    case 'Pending':
                      return 'PENDING';
                    case 'Failed':
                      return 'FAILED';
                    case 'Refunded':
                      return 'REFUNDED';
                    default:
                      return s.toUpperCase();
                  }
                }).toList();

                widget.onApply({
                  'fromDate': _fromDate,
                  'toDate': _toDate,
                  'types': mappedTypes,
                  'statuses': mappedStatuses,
                  'minAmount': _minAmountController.text,
                  'maxAmount': _maxAmountController.text,
                  'batteryId': _batteryIdController.text,
                  'customerName': _customerNameController.text,
                  'stationId': _selectedStationId,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Apply Filters',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getUniqueBatteryIds() {
    final transactions = ref.read(salesProvider).transactions;
    return transactions
        .map((t) => t.batteryId)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  List<String> _getUniqueCustomerNames() {
    final transactions = ref.read(salesProvider).transactions;
    return transactions
        .map((t) => t.customerName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  Widget _buildDynamicSelector(String label, String hint,
      TextEditingController controller, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(controller.text) ? controller.text : null,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textTertiary),
              hint: Text(hint,
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 13)),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                DropdownMenuItem(value: '', child: Text('Clear $label')),
                ...options.map(
                    (opt) => DropdownMenuItem(value: opt, child: Text(opt))),
              ],
              onChanged: (v) => setState(() => controller.text = v ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationSelector() {
    final stationsState = ref.watch(stationsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Station',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
              color: AppColors.inputBg, borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStationId,
              isExpanded: true,
              dropdownColor: AppColors.cardBg,
              icon: const Icon(LucideIcons.chevronDown,
                  size: 16, color: AppColors.textTertiary),
              hint: const Text('Select Station',
                  style:
                      TextStyle(color: AppColors.textTertiary, fontSize: 13)),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('All Stations')),
                ...stationsState.stations.map((s) =>
                    DropdownMenuItem(value: s.name, child: Text(s.name))),
              ],
              onChanged: (v) => setState(() => _selectedStationId = v),
            ),
          ),
        ),
      ],
    );
  }
}
