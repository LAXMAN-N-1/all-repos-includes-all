import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../../../core/theme/colors.dart';
import '../../stations/models/station_state.dart';
import '../../stations/providers/stations_provider.dart';

class RequestBatteriesScreen extends ConsumerStatefulWidget {
  const RequestBatteriesScreen({super.key});

  @override
  ConsumerState<RequestBatteriesScreen> createState() =>
      _RequestBatteriesScreenState();
}

class _RequestBatteriesScreenState
    extends ConsumerState<RequestBatteriesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _destinationController = TextEditingController();
  final _customerNameController =
      TextEditingController(text: 'Walk-in Customer');
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSubmitting = false;
  bool _isLoadingRequests = false;
  bool _isLoadingWarehouses = false;
  bool _isLoadingInventoryModels = false;
  String? _requestsError;
  String? _inventoryModelsError;
  int? _selectedStationId;
  int? _selectedWarehouseId;
  String _priority = 'normal';
  List<Map<String, dynamic>> _recentRequests = const [];
  List<Map<String, dynamic>> _warehouses = const [];
  List<_InventoryModelOption> _availableInventoryModels = const [];
  List<_RequestedModelLineDraft> _requestedItems = [];

  @override
  void initState() {
    super.initState();
    _requestedItems = [_RequestedModelLineDraft()];
    _loadRecentRequests();
    _loadWarehouses();
    _loadInventoryModels();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    for (final item in _requestedItems) {
      item.dispose();
    }
    super.dispose();
  }

  StationDto? _findStationById(List<StationDto> stations, int? id) {
    if (id == null) return null;
    for (final station in stations) {
      if (station.id == id) return station;
    }
    return null;
  }

  String _stationDestinationLabel(StationDto station) {
    final city = station.city.trim();
    if (city.isEmpty) return station.name;
    return '${station.name} - $city';
  }

  void _ensureSelectedStation(List<StationDto> stations) {
    if (stations.isEmpty) return;
    final alreadySelected = _selectedStationId != null &&
        stations.any((station) => station.id == _selectedStationId);
    if (alreadySelected) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final first = stations.first;
      setState(() {
        _selectedStationId = first.id;
        _destinationController.text = _stationDestinationLabel(first);
      });
    });
  }

  Future<void> _loadRecentRequests() async {
    setState(() {
      _isLoadingRequests = true;
      _requestsError = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(
        ApiConstants.deliveries,
        queryParameters: const {
          'limit': 20,
          'sort_order': 'desc',
        },
      );
      final rows = ApiResponse.asList(response.data)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
      if (!mounted) return;
      setState(() {
        _recentRequests = rows;
        _isLoadingRequests = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRequests = false;
        _requestsError = ApiResponse.errorMessage(
          e,
          fallback: 'Failed to load requests',
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingRequests = false;
        _requestsError = 'Failed to load requests';
      });
    }
  }

  Future<void> _loadWarehouses() async {
    setState(() => _isLoadingWarehouses = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.dealerWarehouses);
      final raw = response.data;
      List rawList = [];
      if (raw is Map) {
        final inner = raw['data'];
        if (inner is List) rawList = inner;
      } else if (raw is List) {
        rawList = raw;
      }
      if (!mounted) return;
      setState(() {
        _warehouses = rawList
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _isLoadingWarehouses = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingWarehouses = false);
    }
  }

  Future<void> _loadInventoryModels({bool force = false}) async {
    if (_isLoadingInventoryModels) return;
    if (!force && _availableInventoryModels.isNotEmpty) return;
    setState(() {
      _isLoadingInventoryModels = true;
      _inventoryModelsError = null;
    });
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.inventoryModels);
      final rows = _extractInventoryModelRows(response.data);
      final parsed = rows
          .whereType<Map>()
          .map((row) =>
              _InventoryModelOption.fromMap(Map<String, dynamic>.from(row)))
          .whereType<_InventoryModelOption>()
          .where((item) => item.isActive)
          .toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _availableInventoryModels = parsed;
        _isLoadingInventoryModels = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingInventoryModels = false;
        final message = ApiResponse.errorMessage(
          e,
          fallback: 'Failed to load battery models',
        );
        _inventoryModelsError = message.toLowerCase().contains('token_invalid')
            ? 'Session expired. Please log in again to load battery models.'
            : message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingInventoryModels = false;
        _inventoryModelsError = 'Failed to load battery models';
      });
    }
  }

  List<dynamic> _extractInventoryModelRows(dynamic payload) {
    final unwrapped = ApiResponse.unwrap(payload);
    if (unwrapped is List) return unwrapped;
    if (unwrapped is Map) {
      final data = Map<String, dynamic>.from(unwrapped);
      final directModels = data['models'];
      if (directModels is List) return directModels;
      final directItems = data['items'];
      if (directItems is List) return directItems;
      final nestedData = data['data'];
      if (nestedData is Map) {
        final nested = Map<String, dynamic>.from(nestedData);
        final nestedModels = nested['models'];
        if (nestedModels is List) return nestedModels;
        final nestedItems = nested['items'];
        if (nestedItems is List) return nestedItems;
      }
    }
    return ApiResponse.asList(payload);
  }

  int _derivedUnits() {
    return _requestedItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity.clamp(0, 1000000).toInt(),
    );
  }

  String? _validateRequestedItems() {
    if (_requestedItems.isEmpty) {
      return 'At least one requested model is required';
    }
    final seen = <int>{};
    for (final item in _requestedItems) {
      final modelId = item.batteryModelId;
      if (modelId == null || modelId <= 0) {
        return 'Select a battery model for each requested item';
      }
      if (item.quantity <= 0) {
        return 'Each requested quantity must be greater than 0';
      }
      if (!seen.add(modelId)) {
        return 'Duplicate battery models are not allowed';
      }
    }
    if (_derivedUnits() <= 0) {
      return 'Requested quantity must be greater than 0';
    }
    return null;
  }

  void _addRequestedItem() {
    setState(() {
      _requestedItems = [..._requestedItems, _RequestedModelLineDraft()];
    });
  }

  void _removeRequestedItem(int index) {
    if (_requestedItems.length <= 1) return;
    final toDispose = _requestedItems[index];
    setState(() {
      _requestedItems = List<_RequestedModelLineDraft>.from(_requestedItems)
        ..removeAt(index);
    });
    toDispose.dispose();
  }

  String _statusLabel(dynamic rawStatus) {
    final normalized =
        (rawStatus ?? '').toString().replaceAll('_', ' ').trim().toLowerCase();
    if (normalized.isEmpty) return 'Unknown';
    return normalized
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Color _statusColor(dynamic rawStatus) {
    final status = (rawStatus ?? '').toString().toLowerCase();
    if (status.contains('rejected') || status.contains('failed')) {
      return AppColors.red;
    }
    if (status.contains('pending')) {
      return AppColors.amber;
    }
    if (status.contains('approved') ||
        status.contains('assigned') ||
        status.contains('out_for_delivery')) {
      return AppColors.cyan;
    }
    if (status.contains('delivered') || status.contains('complete')) {
      return AppColors.primary;
    }
    return AppColors.textSecondary;
  }

  String _formatDate(dynamic rawDate) {
    final parsed = DateTime.tryParse((rawDate ?? '').toString())?.toLocal();
    if (parsed == null) return '--';
    final local = parsed.toLocal();
    final yy = local.year.toString().padLeft(4, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$yy-$mm-$dd $hh:$min';
  }

  Future<void> _submitRequest(List<StationDto> stations) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a destination station'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final requestedItemsError = _validateRequestedItems();
    if (requestedItemsError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(requestedItemsError),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }
    final requestedItems = _requestedItems
        .map(
          (item) => <String, dynamic>{
            'battery_model_id': item.batteryModelId,
            'quantity': item.quantity,
          },
        )
        .toList();
    final units = _derivedUnits();
    final destination = _destinationController.text.trim();
    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();
    final notes = _notesController.text.trim();
    final selectedStation = _findStationById(stations, _selectedStationId);
    if (selectedStation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected station is no longer available'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{
      'units': units,
      'requested_items': requestedItems,
      'destination': destination,
      'destination_station_id': selectedStation.id,
      'priority': _priority,
      if (_selectedWarehouseId != null)
        'source_warehouse_id': _selectedWarehouseId,
      if (customerName.isNotEmpty) 'customer_name': customerName,
      if (customerPhone.isNotEmpty) 'customer_phone': customerPhone,
      if (notes.isNotEmpty) 'notes': notes,
    };

    setState(() => _isSubmitting = true);
    try {
      final dio = ref.read(dioProvider);
      final idempotencyKey =
          'dealer-delivery-${DateTime.now().microsecondsSinceEpoch}-${selectedStation.id}';
      final response = await dio.post(
        ApiConstants.deliveries,
        data: payload,
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );
      final order = ApiResponse.asMap(response.data);
      final orderId = order['id']?.toString() ?? 'N/A';
      final tracking = order['tracking_number']?.toString() ?? '';

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tracking.isEmpty
                ? 'Request submitted. Order ID: $orderId'
                : 'Request submitted. Order ID: $orderId, Tracking: $tracking',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      _notesController.clear();
      await _loadRecentRequests();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ApiResponse.errorMessage(e, fallback: 'Failed to create request'),
          ),
          backgroundColor: AppColors.red,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create request'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationsState = ref.watch(stationsProvider);
    final stations = stationsState.stations;
    _ensureSelectedStation(stations);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/inventory'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.arrowLeft, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Back to Inventory',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.packagePlus,
                    size: 22,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Operations: Request Batteries',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a dealer delivery request using the canonical orders API.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 920;
                  final fields = <Widget>[
                    _fieldGroup(
                      'Destination Station',
                      DropdownButtonFormField<int>(
                        initialValue: _selectedStationId,
                        dropdownColor: AppColors.cardBg,
                        decoration: _inputDecoration('Select station'),
                        validator: (value) =>
                            value == null ? 'Station is required' : null,
                        items: stations
                            .map(
                              (station) => DropdownMenuItem<int>(
                                value: station.id,
                                child: Text(
                                  _stationDestinationLabel(station),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: stationsState.isLoading
                            ? null
                            : (value) {
                                setState(() => _selectedStationId = value);
                                final station =
                                    _findStationById(stations, value);
                                if (station != null) {
                                  _destinationController.text =
                                      _stationDestinationLabel(station);
                                }
                              },
                      ),
                    ),
                    _fieldGroup(
                      'Destination',
                      TextFormField(
                        controller: _destinationController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration:
                            _inputDecoration('Delivery destination label'),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Destination is required'
                            : null,
                      ),
                    ),
                    _fieldGroup(
                      'Priority',
                      DropdownButtonFormField<String>(
                        initialValue: _priority,
                        dropdownColor: AppColors.cardBg,
                        decoration: _inputDecoration('Select priority'),
                        items: const [
                          DropdownMenuItem(
                            value: 'low',
                            child: Text(
                              'Low',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'normal',
                            child: Text(
                              'Normal',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Text(
                              'High',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'urgent',
                            child: Text(
                              'Urgent',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _priority = value ?? 'normal'),
                      ),
                    ),
                    _fieldGroup(
                      'Source Warehouse (optional)',
                      DropdownButtonFormField<int?>(
                        initialValue: _selectedWarehouseId,
                        dropdownColor: AppColors.cardBg,
                        decoration: _inputDecoration(
                          _isLoadingWarehouses
                              ? 'Loading warehouses...'
                              : 'Auto-assign (recommended)',
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              'Auto-assign',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          ..._warehouses.map((w) {
                            final id = w['id'] as int?;
                            final name =
                                w['name']?.toString() ?? 'Warehouse $id';
                            final city = w['city']?.toString() ?? '';
                            final label =
                                city.isNotEmpty ? '$name — $city' : name;
                            return DropdownMenuItem<int?>(
                              value: id,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }),
                        ],
                        onChanged: _isLoadingWarehouses
                            ? null
                            : (value) =>
                                setState(() => _selectedWarehouseId = value),
                      ),
                    ),
                    _fieldGroup(
                      'Customer Name',
                      TextFormField(
                        controller: _customerNameController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration('Walk-in Customer'),
                      ),
                    ),
                    _fieldGroup(
                      'Customer Phone (optional)',
                      TextFormField(
                        controller: _customerPhoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration('+91xxxxxxxxxx'),
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) return null;
                          final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
                          if (digits.length < 10 || digits.length > 15) {
                            return 'Enter a valid phone (10 to 15 digits)';
                          }
                          return null;
                        },
                      ),
                    ),
                  ];

                  final notesField = _fieldGroup(
                    'Notes (optional)',
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: _inputDecoration(
                        'Business context for approver',
                      ),
                    ),
                  );
                  final requestedItemsField = _buildRequestedItemsField();

                  if (!isWide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stationsState.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Loading stations...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                        if (stationsState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              stationsState.error!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.red,
                              ),
                            ),
                          ),
                        ...fields,
                        const SizedBox(height: 12),
                        requestedItemsField,
                        const SizedBox(height: 12),
                        notesField,
                        const SizedBox(height: 18),
                        _submitButton(stations),
                      ],
                    );
                  }

                  final horizontalGap = 16.0;
                  final fieldWidth =
                      ((constraints.maxWidth - horizontalGap) / 2)
                          .clamp(280.0, 520.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (stationsState.isLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Loading stations...',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ),
                      if (stationsState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            stationsState.error!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      Wrap(
                        spacing: horizontalGap,
                        runSpacing: 14,
                        children: fields
                            .map(
                              (field) =>
                                  SizedBox(width: fieldWidth, child: field),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      requestedItemsField,
                      const SizedBox(height: 12),
                      notesField,
                      const SizedBox(height: 18),
                      _submitButton(stations),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Recent Battery Requests',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          _isLoadingRequests ? null : _loadRecentRequests,
                      icon: const Icon(
                        LucideIcons.refreshCw,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_isLoadingRequests)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_requestsError != null)
                  Text(
                    _requestsError!,
                    style: const TextStyle(
                      color: AppColors.red,
                      fontSize: 12,
                    ),
                  )
                else if (_recentRequests.isEmpty)
                  const Text(
                    'No requests yet. Submit a request above to create your first delivery order.',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  )
                else
                  Column(
                    children: _recentRequests.take(8).map((order) {
                      final statusColor = _statusColor(order['status']);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pageBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                order['id']?.toString() ?? '--',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${order['units'] ?? '--'} units',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                order['destination']?.toString() ?? '--',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    _statusLabel(order['status']),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _formatDate(order['order_date']),
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _fieldGroup(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        field,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
      ),
      filled: true,
      fillColor: AppColors.pageBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildRequestedItemsField() {
    final validationMessage = _validateRequestedItems();
    return _fieldGroup(
      'Requested Battery Models',
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pageBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingInventoryModels)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Loading battery models...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            if (_inventoryModelsError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _inventoryModelsError!,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ...List.generate(_requestedItems.length, (index) {
              final item = _requestedItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _requestedItems.length - 1 ? 0 : 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<int>(
                        initialValue: item.batteryModelId,
                        dropdownColor: AppColors.cardBg,
                        decoration: _inputDecoration('Select model'),
                        items: _availableInventoryModels
                            .map(
                              (model) => DropdownMenuItem<int>(
                                value: model.id,
                                child: Text(
                                  model.displayLabel,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: _availableInventoryModels.isEmpty
                            ? null
                            : (value) {
                                setState(() => item.batteryModelId = value);
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: TextFormField(
                        controller: item.quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration('Qty'),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: _requestedItems.length <= 1
                          ? null
                          : () => _removeRequestedItem(index),
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 6),
            Row(
              children: [
                TextButton.icon(
                  onPressed:
                      _isLoadingInventoryModels ? null : _addRequestedItem,
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Add model line'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isLoadingInventoryModels
                      ? null
                      : () => _loadInventoryModels(force: true),
                  icon: const Icon(LucideIcons.refreshCcw, size: 14),
                  label: const Text('Refresh'),
                ),
                const Spacer(),
                Text(
                  'Units: ${_derivedUnits()}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (validationMessage != null)
              Text(
                validationMessage,
                style: const TextStyle(
                  color: AppColors.red,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(List<StationDto> stations) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : () => _submitRequest(stations),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: _isSubmitting
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(LucideIcons.send, size: 15),
        label:
            Text(_isSubmitting ? 'Submitting...' : 'Submit Delivery Request'),
      ),
    );
  }
}

class _InventoryModelOption {
  final int id;
  final String name;
  final String? manufacturer;
  final bool isActive;

  const _InventoryModelOption({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.isActive,
  });

  String get displayLabel =>
      manufacturer == null || manufacturer!.trim().isEmpty
          ? name
          : '$name — ${manufacturer!.trim()}';

  static _InventoryModelOption? fromMap(Map<String, dynamic> raw) {
    final id = (raw['model_id'] as num?)?.toInt() ??
        (raw['id'] as num?)?.toInt() ??
        (raw['battery_model_id'] as num?)?.toInt();
    if (id == null || id <= 0) return null;
    final name = raw['name']?.toString().trim() ??
        raw['model_name']?.toString().trim() ??
        raw['display_name']?.toString().trim() ??
        '';
    if (name.isEmpty) return null;
    final manufacturer = raw['manufacturer']?.toString().trim();
    final isActive =
        _asBool(raw['is_active']) ?? _asBool(raw['active']) ?? true;
    return _InventoryModelOption(
      id: id,
      name: name,
      manufacturer:
          manufacturer == null || manufacturer.isEmpty ? null : manufacturer,
      isActive: isActive,
    );
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    return null;
  }
}

class _RequestedModelLineDraft {
  int? batteryModelId;
  final TextEditingController quantityController;

  _RequestedModelLineDraft({int quantity = 1})
      : quantityController = TextEditingController(text: '$quantity');

  int get quantity => int.tryParse(quantityController.text.trim()) ?? 0;

  void dispose() {
    quantityController.dispose();
  }
}
