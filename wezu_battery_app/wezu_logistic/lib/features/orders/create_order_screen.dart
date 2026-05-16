import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../models/battery_model.dart';
import '../../models/driver_model.dart';
import '../../models/order_model.dart';
import '../../utils/battery_identity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../fleet/providers/logistics_providers.dart';
import '../inventory/providers/inventory_providers.dart';
import 'providers/orders_providers.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _unitsController = TextEditingController();
  final _destinationController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _trackingNumberController = TextEditingController();
  final _totalValueController = TextEditingController();
  final _notesController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingBatteries = false;
  bool _isLoadingDrivers = false;

  List<BatteryModel> _availableBatteries = const [];
  List<String> _selectedBatteryIds = [];
  List<DriverModel> _availableDrivers = const [];

  OrderPriority _selectedPriority = OrderPriority.normal;
  int? _selectedDriverId;
  DateTime? _orderDate;
  DateTime? _dispatchDate;
  DateTime? _estimatedDelivery;

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchAvailableDrivers);
  }

  @override
  void dispose() {
    _unitsController.dispose();
    _destinationController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _trackingNumberController.dispose();
    _totalValueController.dispose();
    _notesController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableDrivers({bool force = false}) async {
    if (_isLoadingDrivers) return;
    if (!force && _availableDrivers.isNotEmpty) return;

    setState(() => _isLoadingDrivers = true);
    final result = await ref
        .read(driverRepositoryProvider)
        .fetchDrivers(status: DriverStatus.available);

    if (!mounted) return;
    setState(() {
      _isLoadingDrivers = false;
      if (result.isSuccess) {
        _availableDrivers =
            (result.dataOrNull ?? const [])
                .where((driver) => _parseDriverId(driver.id) != null)
                .toList()
              ..sort(
                (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
        if (_selectedDriverId != null &&
            !_availableDrivers.any(
              (driver) => _parseDriverId(driver.id) == _selectedDriverId,
            )) {
          _selectedDriverId = null;
        }
      }
    });

    if (result.isFailure) {
      _showSnack(
        result.error ?? 'Failed to load drivers.',
        backgroundColor: AppColors.warning,
      );
    }
  }

  Future<void> _fetchAvailableBatteries({bool force = false}) async {
    if (_isLoadingBatteries) return;
    if (!force && _availableBatteries.isNotEmpty) return;

    setState(() => _isLoadingBatteries = true);
    final result = await ref
        .read(inventoryRepositoryProvider)
        .fetchBatteries(
          filter: BatteryStatus.available,
          pageSize: 500,
          sortBy: 'id',
          sortOrder: 'asc',
        );

    if (!mounted) return;
    setState(() {
      _isLoadingBatteries = false;
      if (result.isSuccess) {
        _availableBatteries =
            (result.dataOrNull ?? const [])
                .where((battery) => battery.serialNumber.trim().isNotEmpty)
                .toList()
              ..sort(
                (a, b) => normalizeBatterySerial(
                  a.serialNumber,
                ).compareTo(normalizeBatterySerial(b.serialNumber)),
              );
      }
    });

    if (result.isFailure) {
      _showSnack(
        result.error ?? 'Failed to load available batteries.',
        backgroundColor: AppColors.warning,
      );
    }
  }

  void _trimSelectedByUnits() {
    final units = int.tryParse(_unitsController.text.trim()) ?? 0;
    if (units <= 0) return;
    if (_selectedBatteryIds.length > units) {
      setState(() {
        _selectedBatteryIds = _selectedBatteryIds.take(units).toList();
      });
    }
  }

  Future<void> _showBatterySelectionSheet() async {
    await _fetchAvailableBatteries();
    if (!mounted) return;

    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _BatterySelectionSheet(
        batteries: _availableBatteries,
        initialSelected: _selectedBatteryIds,
        unitsLimit: int.tryParse(_unitsController.text.trim()) ?? 0,
      ),
    );

    if (!mounted || result == null) return;
    final normalized = normalizeBatterySerials(result);
    final units = int.tryParse(_unitsController.text.trim()) ?? 0;
    final capped = units > 0 ? normalized.take(units).toList() : normalized;
    setState(() {
      _selectedBatteryIds = capped;
    });
  }

  Widget _buildResponsiveFieldRow({
    required Widget left,
    required Widget right,
    double breakpoint = 640,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(children: [left, AppSpacing.gapH16, right]);
        }
        return Row(
          children: [
            Expanded(child: left),
            AppSpacing.gapW16,
            Expanded(child: right),
          ],
        );
      },
    );
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final current = initial ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: now.subtract(const Duration(days: 365 * 2)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null || !mounted) {
      return null;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current),
    );
    if (pickedTime == null) {
      return DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        current.hour,
        current.minute,
      );
    }

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  int? _parseDriverId(String rawId) {
    final trimmed = rawId.trim();
    if (trimmed.isEmpty) return null;

    final direct = int.tryParse(trimmed);
    if (direct != null && direct > 0) return direct;

    final match = RegExp(r'(\d+)$').firstMatch(trimmed);
    if (match == null) return null;
    final parsed = int.tryParse(match.group(1)!);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  double? _parseDecimal(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    final units = int.tryParse(_unitsController.text.trim());
    if (units == null || units <= 0) {
      _showSnack(
        'Units must be greater than 0.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final destination = _destinationController.text.trim();
    final normalizedAssignedBatteryIds = normalizeBatterySerials(
      _selectedBatteryIds,
    );

    if (normalizedAssignedBatteryIds.isEmpty) {
      _showSnack(
        'Select at least one battery before creating the order.',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (normalizedAssignedBatteryIds.length != units) {
      _showSnack(
        'Units must equal assigned batteries ($units required, ${normalizedAssignedBatteryIds.length} selected).',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final hasLat = _latController.text.trim().isNotEmpty;
    final hasLng = _lngController.text.trim().isNotEmpty;
    if (hasLat != hasLng) {
      _showSnack(
        'Enter both latitude and longitude, or leave both empty.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final latitude = _parseDecimal(_latController.text);
    final longitude = _parseDecimal(_lngController.text);
    if (hasLat && (latitude == null || longitude == null)) {
      _showSnack(
        'Latitude and longitude must be valid numbers.',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (latitude != null && (latitude < -90 || latitude > 90)) {
      _showSnack(
        'Latitude must be between -90 and 90.',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (longitude != null && (longitude < -180 || longitude > 180)) {
      _showSnack(
        'Longitude must be between -180 and 180.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final customerPhone = _customerPhoneController.text.trim();
    final phoneDigits = customerPhone.replaceAll(RegExp(r'\D'), '');
    if (customerPhone.isNotEmpty &&
        (phoneDigits.length < 10 || phoneDigits.length > 15)) {
      _showSnack(
        'Customer phone must contain 10 to 15 digits.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final totalValue = _parseDecimal(_totalValueController.text);
    if (_totalValueController.text.trim().isNotEmpty && totalValue == null) {
      _showSnack(
        'Total value must be a valid number.',
        backgroundColor: AppColors.warning,
      );
      return;
    }
    if (totalValue != null && totalValue < 0) {
      _showSnack(
        'Total value must be greater than or equal to 0.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    if (_dispatchDate != null &&
        _orderDate != null &&
        _dispatchDate!.isBefore(_orderDate!)) {
      _showSnack(
        'Dispatch date must be greater than or equal to order date.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    final earliestDeliveryDate = _dispatchDate ?? _orderDate;
    if (_estimatedDelivery != null &&
        earliestDeliveryDate != null &&
        _estimatedDelivery!.isBefore(earliestDeliveryDate)) {
      _showSnack(
        'Estimated delivery must be after dispatch/order date.',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(createOrderProvider.notifier)
        .createOrder(
          units: units,
          destination: destination,
          assignedBatteryIds: normalizedAssignedBatteryIds,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          customerName: _customerNameController.text.trim().isEmpty
              ? null
              : _customerNameController.text.trim(),
          customerPhone: customerPhone.isEmpty ? null : customerPhone,
          priority: _selectedPriority,
          totalValue: totalValue,
          trackingNumber: _trackingNumberController.text.trim().isEmpty
              ? null
              : _trackingNumberController.text.trim(),
          assignedDriverId: _selectedDriverId,
          orderDate: _orderDate,
          dispatchDate: _dispatchDate,
          estimatedDelivery: _estimatedDelivery,
          latitude: latitude,
          longitude: longitude,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSubmitting = false);
    if (result.isSuccess) {
      _showSnack(
        'Order created successfully.',
        backgroundColor: AppColors.success,
      );
      context.pop();
      return;
    }

    _showSnack(
      result.error ?? 'Failed to create order. Please try again.',
      backgroundColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = int.tryParse(_unitsController.text.trim()) ?? 0;
    final selectedCount = _selectedBatteryIds.length;
    final hasExactMatch = units > 0 && selectedCount == units;

    return AppScaffold(
      appBar: AppBar(title: const Text('Create Order')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: AppSpacing.screenPadding,
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildTopBanner(theme, units, selectedCount, hasExactMatch),
                    AppSpacing.gapH16,
                    _buildShipmentCard(),
                    AppSpacing.gapH16,
                    _buildBatteryCard(units, selectedCount, hasExactMatch),
                    AppSpacing.gapH16,
                    _buildCustomerAndAssignmentCard(),
                    AppSpacing.gapH16,
                    _buildSchedulingAndLocationCard(),
                    AppSpacing.gapH16,
                    _buildNotesCard(),
                    AppSpacing.gapH24,
                    AppButton(
                      label: 'Create Order',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _submit,
                      isLoading: _isSubmitting,
                    ),
                    const SizedBox(height: 28),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(
    ThemeData theme,
    int units,
    int selectedCount,
    bool hasExactMatch,
  ) {
    final progress = units <= 0
        ? 0.0
        : (selectedCount / units).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.14),
            theme.colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Logistics Order',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fill shipment details and assign exact batteries before submission.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: hasExactMatch
                  ? AppColors.success
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            units <= 0
                ? 'Enter units and assign batteries.'
                : '$selectedCount / $units batteries assigned',
            style: theme.textTheme.labelMedium?.copyWith(
              color: hasExactMatch
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentCard() {
    return _SectionCard(
      title: 'Shipment Details',
      subtitle: 'Core fields required by backend create-order contract.',
      child: Column(
        children: [
          _buildResponsiveFieldRow(
            left: AppTextField(
              controller: _unitsController,
              label: 'Units',
              hint: 'e.g. 4',
              prefixIcon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Units are required';
                final parsed = int.tryParse(trimmed);
                if (parsed == null || parsed <= 0) {
                  return 'Units must be greater than 0';
                }
                return null;
              },
              onChanged: (_) => _trimSelectedByUnits(),
            ),
            right: _PriorityField(
              value: _selectedPriority,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedPriority = value);
              },
            ),
          ),
          AppSpacing.gapH16,
          AppTextField(
            controller: _destinationController,
            label: 'Destination',
            hint: 'Dealer/Hub name and locality',
            prefixIcon: Icons.place_rounded,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return 'Destination is required';
              if (trimmed.length > 255) {
                return 'Destination must be 255 characters or less';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryCard(int units, int selectedCount, bool hasExactMatch) {
    final theme = Theme.of(context);
    final helperColor = hasExactMatch
        ? AppColors.success
        : (selectedCount > units && units > 0
              ? AppColors.error
              : AppColors.textSecondary);

    return _SectionCard(
      title: 'Battery Assignment',
      subtitle: 'assigned_battery_ids is mandatory. Units must match exactly.',
      trailing: TextButton.icon(
        onPressed: _showBatterySelectionSheet,
        icon: const Icon(Icons.tune_rounded),
        label: const Text('Manage'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedCount == 0
                      ? 'No batteries selected'
                      : '$selectedCount batteries selected',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              if (_selectedBatteryIds.isNotEmpty)
                TextButton(
                  onPressed: () => setState(() => _selectedBatteryIds = []),
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            units <= 0
                ? 'Set units first to enforce selection limit.'
                : 'Required: $units • Selected: $selectedCount',
            style: theme.textTheme.bodySmall?.copyWith(
              color: helperColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_selectedBatteryIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _selectedBatteryIds.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final serial = _selectedBatteryIds[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: const Icon(
                          Icons.battery_5_bar_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        serial,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                      trailing: IconButton(
                        tooltip: 'Remove',
                        onPressed: () {
                          setState(() {
                            _selectedBatteryIds.remove(serial);
                          });
                        },
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _showBatterySelectionSheet,
            icon: const Icon(Icons.battery_charging_full_rounded),
            label: Text(
              _isLoadingBatteries
                  ? 'Loading available batteries...'
                  : 'Choose Batteries',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAndAssignmentCard() {
    final mappedDrivers = _availableDrivers
        .map((driver) {
          final driverId = _parseDriverId(driver.id);
          if (driverId == null) return null;
          return (
            id: driverId,
            label:
                '${driver.name} (${driver.vehicleType}${driver.vehiclePlate.trim().isEmpty ? '' : ' • ${driver.vehiclePlate}'})',
          );
        })
        .whereType<({int id, String label})>()
        .toList();

    return _SectionCard(
      title: 'Customer & Assignment',
      subtitle:
          'Optional fields for richer order payload and dispatch clarity.',
      trailing: IconButton(
        tooltip: 'Refresh drivers',
        icon: _isLoadingDrivers
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh_rounded),
        onPressed: _isLoadingDrivers
            ? null
            : () => _fetchAvailableDrivers(force: true),
      ),
      child: Column(
        children: [
          AppTextField(
            controller: _customerNameController,
            label: 'Customer Name',
            hint: 'Walk-in Customer',
            prefixIcon: Icons.person_outline_rounded,
            textCapitalization: TextCapitalization.words,
            maxLength: 120,
          ),
          AppSpacing.gapH16,
          AppTextField(
            controller: _customerPhoneController,
            label: 'Customer Phone',
            hint: '10 to 15 digits',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
          ),
          AppSpacing.gapH16,
          _buildResponsiveFieldRow(
            left: AppTextField(
              controller: _totalValueController,
              label: 'Total Value',
              hint: 'e.g. 12500',
              prefixIcon: Icons.currency_rupee_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            right: AppTextField(
              controller: _trackingNumberController,
              label: 'Tracking Number',
              hint: 'Optional',
              prefixIcon: Icons.route_outlined,
              maxLength: 64,
            ),
          ),
          AppSpacing.gapH16,
          _DriverDropdown(
            value: _selectedDriverId,
            items: mappedDrivers,
            isLoading: _isLoadingDrivers,
            onChanged: (value) => setState(() => _selectedDriverId = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulingAndLocationCard() {
    return _SectionCard(
      title: 'Schedule & Location',
      subtitle: 'Optional operational fields with backend guardrails.',
      child: Column(
        children: [
          _DateTimeFieldTile(
            label: 'Order Date',
            value: _orderDate,
            icon: Icons.event_note_rounded,
            onPick: () async {
              final picked = await _pickDateTime(_orderDate);
              if (picked == null || !mounted) return;
              setState(() => _orderDate = picked);
            },
            onClear: _orderDate == null
                ? null
                : () => setState(() => _orderDate = null),
          ),
          AppSpacing.gapH12,
          _DateTimeFieldTile(
            label: 'Dispatch Date',
            value: _dispatchDate,
            icon: Icons.local_shipping_outlined,
            onPick: () async {
              final picked = await _pickDateTime(_dispatchDate ?? _orderDate);
              if (picked == null || !mounted) return;
              setState(() => _dispatchDate = picked);
            },
            onClear: _dispatchDate == null
                ? null
                : () => setState(() => _dispatchDate = null),
          ),
          AppSpacing.gapH12,
          _DateTimeFieldTile(
            label: 'Estimated Delivery',
            value: _estimatedDelivery,
            icon: Icons.schedule_send_outlined,
            onPick: () async {
              final picked = await _pickDateTime(
                _estimatedDelivery ?? _dispatchDate ?? _orderDate,
              );
              if (picked == null || !mounted) return;
              setState(() => _estimatedDelivery = picked);
            },
            onClear: _estimatedDelivery == null
                ? null
                : () => setState(() => _estimatedDelivery = null),
          ),
          AppSpacing.gapH16,
          _buildResponsiveFieldRow(
            left: AppTextField(
              controller: _latController,
              label: 'Latitude',
              hint: 'e.g. 12.9716',
              prefixIcon: Icons.place_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
            right: AppTextField(
              controller: _lngController,
              label: 'Longitude',
              hint: 'e.g. 77.5946',
              prefixIcon: Icons.place_outlined,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _SectionCard(
      title: 'Notes',
      subtitle: 'Optional instructions for operations or delivery staff.',
      child: AppTextField(
        controller: _notesController,
        label: 'Notes',
        hint: 'Special handling instructions, contact notes, etc.',
        prefixIcon: Icons.sticky_note_2_outlined,
        maxLines: 4,
        maxLength: 2000,
        textCapitalization: TextCapitalization.sentences,
        validator: (value) {
          final length = value?.trim().length ?? 0;
          if (length > 2000) {
            return 'Notes must be 2000 characters or less';
          }
          return null;
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _BatterySelectionSheet extends StatefulWidget {
  const _BatterySelectionSheet({
    required this.batteries,
    required this.initialSelected,
    required this.unitsLimit,
  });

  final List<BatteryModel> batteries;
  final List<String> initialSelected;
  final int unitsLimit;

  @override
  State<_BatterySelectionSheet> createState() => _BatterySelectionSheetState();
}

class _BatterySelectionSheetState extends State<_BatterySelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  late final List<String> _workingSelected;

  String _searchQuery = '';
  String? _limitMessage;

  @override
  void initState() {
    super.initState();
    _workingSelected = normalizeBatterySerials(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBattery(String serial) {
    final isSelected = _workingSelected.contains(serial);
    if (isSelected) {
      setState(() {
        _workingSelected.remove(serial);
        _limitMessage = null;
      });
      return;
    }

    final normalized = normalizeBatterySerials([..._workingSelected, serial]);
    if (widget.unitsLimit > 0 && normalized.length > widget.unitsLimit) {
      setState(() {
        _limitMessage =
            'Units is ${widget.unitsLimit}. Increase units to select more batteries.';
      });
      return;
    }

    setState(() {
      _workingSelected
        ..clear()
        ..addAll(normalized);
      _limitMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredBatteries = widget.batteries.where((battery) {
      if (normalizedQuery.isEmpty) return true;
      final serial = normalizeBatterySerial(battery.serialNumber).toLowerCase();
      return serial.contains(normalizedQuery) ||
          battery.model.toLowerCase().contains(normalizedQuery) ||
          battery.manufacturer.toLowerCase().contains(normalizedQuery);
    }).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: SizedBox(
        height: mediaQuery.size.height * 0.82,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Assign Batteries',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () =>
                        Navigator.of(context).pop(_workingSelected),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: AppTextField(
                controller: _searchController,
                label: 'Search batteries',
                hint: 'Serial, model, manufacturer',
                prefixIcon: Icons.search_rounded,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_workingSelected.length} selected',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  Text(
                    'Available: ${filteredBatteries.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: _limitMessage == null
                  ? const SizedBox(height: 8)
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _limitMessage!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
            ),
            if (filteredBatteries.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'No matching available batteries.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  itemCount: filteredBatteries.length,
                  itemBuilder: (context, index) {
                    final theme = Theme.of(context);
                    final battery = filteredBatteries[index];
                    final serial = normalizeBatterySerial(battery.serialNumber);
                    final isSelected = _workingSelected.contains(serial);
                    final charge = battery.chargePercentage;
                    final chargeColor = charge >= 60
                        ? AppColors.success
                        : (charge >= 30 ? AppColors.warning : AppColors.error);
                    final borderColor = isSelected
                        ? AppColors.primary.withValues(alpha: 0.45)
                        : theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () => _toggleBattery(serial),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.08)
                                  : theme.colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.45),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : theme.colorScheme.outline,
                                    ),
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.14,
                                          )
                                        : Colors.transparent,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 16,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        serial,
                                        style: theme.textTheme.labelLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${battery.model} • ${battery.manufacturer}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: chargeColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$charge%',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: chargeColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: AppButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(_workingSelected),
                icon: Icons.check_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityField extends StatelessWidget {
  const _PriorityField({required this.value, required this.onChanged});

  final OrderPriority value;
  final ValueChanged<OrderPriority?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: Theme.of(context).textTheme.labelLarge),
        AppSpacing.gapH8,
        DropdownButtonFormField<OrderPriority>(
          key: ValueKey<OrderPriority>(value),
          initialValue: value,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.flag_outlined),
          ),
          onChanged: onChanged,
          items: OrderPriority.values
              .map(
                (priority) => DropdownMenuItem<OrderPriority>(
                  value: priority,
                  child: Text(priority.label),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _DriverDropdown extends StatelessWidget {
  const _DriverDropdown({
    required this.value,
    required this.items,
    required this.isLoading,
    required this.onChanged,
  });

  final int? value;
  final List<({int id, String label})> items;
  final bool isLoading;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assigned Driver (Optional)',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        AppSpacing.gapH8,
        DropdownButtonFormField<int?>(
          key: ValueKey<int?>(value),
          initialValue: value,
          isExpanded: true,
          onChanged: isLoading ? null : onChanged,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_pin_circle_outlined),
            helperText: isLoading
                ? 'Loading available drivers...'
                : 'Leave empty to assign later.',
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('No driver assigned'),
            ),
            ...items.map(
              (item) => DropdownMenuItem<int?>(
                value: item.id,
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateTimeFieldTile extends StatelessWidget {
  const _DateTimeFieldTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onPick,
    required this.onClear,
  });

  final String label;
  final DateTime? value;
  final IconData icon;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value == null ? 'Not set' : formatter.format(value!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: value == null ? AppColors.textSecondary : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: value == null ? 'Pick date & time' : 'Clear',
              onPressed: value == null ? onPick : onClear,
              icon: Icon(
                value == null
                    ? Icons.edit_calendar_rounded
                    : Icons.clear_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
