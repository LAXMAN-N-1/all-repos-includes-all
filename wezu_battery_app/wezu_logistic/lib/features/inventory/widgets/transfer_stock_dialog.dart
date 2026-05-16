import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/battery_model.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../utils/battery_identity.dart';
import '../providers/inventory_providers.dart';
import '../repository/inventory_repository.dart';

class TransferStockDialog extends ConsumerStatefulWidget {
  final List<BatteryModel> availableBatteries;
  final List<TransferWarehouse> warehouses;
  final List<TransferDestination> destinations;

  const TransferStockDialog({
    super.key,
    required this.availableBatteries,
    required this.warehouses,
    required this.destinations,
  });

  @override
  ConsumerState<TransferStockDialog> createState() =>
      _TransferStockDialogState();
}

class _TransferSourceLocation {
  final String type;
  final int id;
  final String label;

  const _TransferSourceLocation({
    required this.type,
    required this.id,
    required this.label,
  });

  String get key => '$type:$id';
}

class _TransferStockDialogState extends ConsumerState<TransferStockDialog> {
  final _batterySearchController = TextEditingController();
  final Set<String> _selectedBatteryIds = {};

  late final List<_TransferSourceLocation> _sourceLocations;
  late String _selectedSourceKey;

  final String _toLocationType = 'station';
  late int _toLocationId;

  bool _isConfirming = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _sourceLocations = _buildSourceLocations();
    final defaultSource = _sourceLocations.firstWhere(
      (source) => source.type == 'warehouse',
      orElse: () => _sourceLocations.isEmpty
          ? const _TransferSourceLocation(type: '', id: -1, label: '')
          : _sourceLocations.first,
    );
    _selectedSourceKey = defaultSource.id <= 0 ? '' : defaultSource.key;
    _toLocationId = widget.destinations.first.id;
    _syncTrackedLocations();
  }

  @override
  void dispose() {
    unawaited(
      ref
          .read(transferLocationBatteriesProvider.notifier)
          .clearTrackedLocations(),
    );
    _batterySearchController.dispose();
    super.dispose();
  }

  String _normalizeLocationType(String? value) {
    final locationType = (value ?? '').trim().toLowerCase();
    if (locationType == 'in_transit') return 'transit';
    return locationType;
  }

  bool _isSupportedSourceType(String locationType) {
    return locationType == 'warehouse' ||
        locationType == 'station' ||
        locationType == 'shelf';
  }

  InventoryLocationRef? get _selectedSourceRef {
    final source = _selectedSourceLocation;
    if (source == null) return null;
    return InventoryLocationRef(
      locationType: source.type,
      locationId: source.id,
    );
  }

  InventoryLocationRef get _destinationRef => InventoryLocationRef(
    locationType: _toLocationType,
    locationId: _toLocationId,
  );

  void _syncTrackedLocations() {
    unawaited(
      ref
          .read(transferLocationBatteriesProvider.notifier)
          .setTrackedLocations(
            sourceLocation: _selectedSourceRef,
            destinationLocation: _destinationRef,
          ),
    );
  }

  _TransferSourceLocation? get _selectedSourceLocation {
    if (_sourceLocations.isEmpty) return null;
    for (final source in _sourceLocations) {
      if (source.key == _selectedSourceKey) return source;
    }
    return _sourceLocations.first;
  }

  List<_TransferSourceLocation> _buildSourceLocations() {
    final indexed = <String, _TransferSourceLocation>{};

    for (final warehouse in widget.warehouses) {
      final source = _TransferSourceLocation(
        type: 'warehouse',
        id: warehouse.id,
        label: _sourceLabel('warehouse', warehouse.id),
      );
      indexed[source.key] = source;
    }

    for (final station in widget.destinations) {
      final source = _TransferSourceLocation(
        type: 'station',
        id: station.id,
        label: _sourceLabel('station', station.id),
      );
      indexed[source.key] = source;
    }

    // Keep legacy source discovery for shelf sources that may not have metadata
    // in the transfer-location endpoint yet.
    for (final battery in widget.availableBatteries) {
      final locationType = _normalizeLocationType(battery.location);
      final locationId = battery.locationId;
      if (!_isSupportedSourceType(locationType) || locationId == null) {
        continue;
      }

      final source = _TransferSourceLocation(
        type: locationType,
        id: locationId,
        label: _sourceLabel(locationType, locationId),
      );
      indexed[source.key] = source;
    }

    final values = indexed.values.toList()
      ..sort((a, b) => a.label.compareTo(b.label));
    return values;
  }

  String _sourceLabel(String type, int id) {
    switch (type) {
      case 'warehouse':
        final matches = widget.warehouses.where(
          (warehouse) => warehouse.id == id,
        );
        final warehouseName = matches.isNotEmpty
            ? matches.first.name
            : 'Warehouse #$id';
        return 'Warehouse: $warehouseName';
      case 'station':
        final matches = widget.destinations.where(
          (destination) => destination.id == id,
        );
        final stationName = matches.isNotEmpty
            ? matches.first.name
            : 'Station #$id';
        return 'Station: $stationName';
      case 'shelf':
        return 'Shelf #$id';
      default:
        return '${type[0].toUpperCase()}${type.substring(1)} #$id';
    }
  }

  IconData _sourceIcon(String sourceType) {
    switch (sourceType) {
      case 'warehouse':
        return Icons.warehouse_outlined;
      case 'station':
        return Icons.store;
      case 'shelf':
        return Icons.inventory_2_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  String _locationTypeLabel(String sourceType) {
    switch (sourceType) {
      case 'warehouse':
        return 'Warehouse';
      case 'station':
        return 'Station';
      case 'shelf':
        return 'Shelf';
      default:
        if (sourceType.isEmpty) return 'Location';
        return '${sourceType[0].toUpperCase()}${sourceType.substring(1)}';
    }
  }

  Future<String?> _showSourcePickerSheet(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Text(
                  'Choose Source Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '${_sourceLocations.length} locations available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: _sourceLocations.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final source = _sourceLocations[index];
                    final isSelected = source.key == _selectedSourceKey;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primaryContainer
                            .withValues(alpha: isSelected ? 0.55 : 0.3),
                        child: Icon(
                          _sourceIcon(source.type),
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        source.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${_locationTypeLabel(source.type)} • ID ${source.id}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.primary,
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(source.key),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int?> _showDestinationPickerSheet(BuildContext context) {
    final theme = Theme.of(context);
    return showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                child: Text(
                  'Choose Destination Station',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  '${widget.destinations.length} stations available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.destinations.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final destination = widget.destinations[index];
                    final isSelected = destination.id == _toLocationId;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.secondaryContainer
                            .withValues(alpha: isSelected ? 0.55 : 0.3),
                        child: Icon(
                          Icons.storefront_outlined,
                          size: 18,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        destination.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text('Station • ID ${destination.id}'),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: theme.colorScheme.secondary,
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pop(destination.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _batteryMatchesSelectedSource(BatteryModel battery) {
    final selectedSource = _selectedSourceLocation;
    if (selectedSource == null) return false;

    final locationType = _normalizeLocationType(battery.location);
    if (!_isSupportedSourceType(locationType)) return false;

    final locationId = battery.locationId;
    if (locationId == null) return false;

    return locationType == selectedSource.type &&
        locationId == selectedSource.id;
  }

  BatteryModel? _findBattery(String serial) {
    final normalized = normalizeBatterySerial(serial);
    final locationState = ref.read(transferLocationBatteriesProvider);
    for (final batteries in locationState.batteriesByLocation.values) {
      for (final battery in batteries) {
        if (normalizeBatterySerial(battery.serialNumber) == normalized) {
          return battery;
        }
      }
    }
    for (final battery in widget.availableBatteries) {
      if (normalizeBatterySerial(battery.serialNumber) == normalized) {
        return battery;
      }
    }
    return null;
  }

  void _pruneSelectedBatteriesToSource() {
    _selectedBatteryIds.removeWhere((serial) {
      final battery = _findBattery(serial);
      return battery == null || !_batteryMatchesSelectedSource(battery);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locationState = ref.watch(transferLocationBatteriesProvider);

    final selectedSource = _selectedSourceLocation;
    final sourceName = selectedSource?.label ?? 'Unknown source';
    final sourceRef = _selectedSourceRef;
    final sourceBatteries = locationState.batteriesFor(sourceRef);
    final sourceLoadError = locationState.errorFor(sourceRef);
    final isSourceLoading = locationState.isLoadingFor(sourceRef);

    final filteredBatteries =
        sourceBatteries.where((battery) {
          if (!_batteryMatchesSelectedSource(battery)) return false;

          final query = _batterySearchController.text.trim().toLowerCase();
          if (query.isEmpty) return true;

          final serial = normalizeBatterySerial(
            battery.serialNumber,
          ).toLowerCase();
          final status = battery.status.label.toLowerCase();
          return serial.contains(query) || status.contains(query);
        }).toList()..sort(
          (a, b) => normalizeBatterySerial(
            a.serialNumber,
          ).compareTo(normalizeBatterySerial(b.serialNumber)),
        );

    final destinationName = widget.destinations
        .firstWhere(
          (destination) => destination.id == _toLocationId,
          orElse: () => widget.destinations.first,
        )
        .name;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isConfirming
                        ? Icons.check_circle_outline
                        : Icons.swap_horiz_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  AppSpacing.gapW8,
                  Text(
                    _isConfirming ? 'Confirm Transfer' : 'Transfer Stock',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              AppSpacing.gapH24,
              if (_errorMessage != null)
                _InlineBanner(
                  message: _errorMessage!,
                  type: _BannerType.error,
                  onDismiss: () => setState(() => _errorMessage = null),
                ),
              if (_successMessage != null)
                _InlineBanner(
                  message: _successMessage!,
                  type: _BannerType.success,
                  onDismiss: () => setState(() => _successMessage = null),
                ),
              if (selectedSource == null)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No valid source locations found for transfer.',
                    ),
                  ),
                )
              else if (_isConfirming) ...[
                _buildConfirmationView(
                  theme,
                  isDark,
                  destinationName,
                  sourceName,
                  _sourceIcon(selectedSource.type),
                ),
              ] else ...[
                _buildSelectionView(
                  theme,
                  filteredBatteries,
                  isSourceLoading: isSourceLoading,
                  sourceLoadError: sourceLoadError,
                ),
              ],
              AppSpacing.gapH16,
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionView(
    ThemeData theme,
    List<BatteryModel> filteredBatteries, {
    required bool isSourceLoading,
    required String? sourceLoadError,
  }) {
    final selectedSource = _selectedSourceLocation;
    final selectedDestination = widget.destinations.firstWhere(
      (destination) => destination.id == _toLocationId,
      orElse: () => widget.destinations.first,
    );

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationSelectorCard(
            title: 'Source Location',
            value: selectedSource?.label ?? 'No source location',
            subtitle: selectedSource == null
                ? 'Unavailable'
                : '${_locationTypeLabel(selectedSource.type)} • ID ${selectedSource.id}',
            icon: selectedSource == null
                ? Icons.place_outlined
                : _sourceIcon(selectedSource.type),
            onTap: _sourceLocations.isEmpty
                ? null
                : () async {
                    final selectedKey = await _showSourcePickerSheet(context);
                    if (!mounted ||
                        selectedKey == null ||
                        selectedKey == _selectedSourceKey) {
                      return;
                    }
                    setState(() {
                      _selectedSourceKey = selectedKey;
                      _errorMessage = null;
                      _pruneSelectedBatteriesToSource();
                    });
                    _syncTrackedLocations();
                  },
          ),
          AppSpacing.gapH16,
          _LocationSelectorCard(
            title: 'Destination Station',
            value: selectedDestination.name,
            subtitle: 'Station • ID ${selectedDestination.id}',
            icon: Icons.storefront_outlined,
            onTap: () async {
              final selectedId = await _showDestinationPickerSheet(context);
              if (!mounted ||
                  selectedId == null ||
                  selectedId == _toLocationId) {
                return;
              }
              setState(() {
                _toLocationId = selectedId;
                _errorMessage = null;
              });
              _syncTrackedLocations();
            },
          ),
          AppSpacing.gapH16,
          const Divider(),
          AppSpacing.gapH16,
          Text(
            'Select Batteries (${_selectedBatteryIds.length} selected)',
            style: theme.textTheme.titleMedium,
          ),
          AppSpacing.gapH8,
          TextField(
            controller: _batterySearchController,
            decoration: const InputDecoration(
              hintText: 'Search serial number...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          AppSpacing.gapH8,
          Expanded(
            child: isSourceLoading && filteredBatteries.isEmpty
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : sourceLoadError != null && filteredBatteries.isEmpty
                ? Center(
                    child: Text(sourceLoadError, textAlign: TextAlign.center),
                  )
                : filteredBatteries.isEmpty
                ? const Center(child: Text('No available batteries found'))
                : ListView.builder(
                    itemCount: filteredBatteries.length,
                    itemBuilder: (context, index) {
                      final battery = filteredBatteries[index];
                      final serial = normalizeBatterySerial(
                        battery.serialNumber,
                      );
                      final isSelected = _selectedBatteryIds.contains(serial);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            _errorMessage = null;
                            if (value == true) {
                              _selectedBatteryIds.add(serial);
                            } else {
                              _selectedBatteryIds.remove(serial);
                            }
                          });
                        },
                        title: Text(serial, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          '${battery.chargePercentage}% Charge • ${battery.status.label}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        secondary: Icon(
                          Icons.battery_full,
                          color: battery.isLowHealth
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView(
    ThemeData theme,
    bool isDark,
    String destinationName,
    String sourceLocationName,
    IconData sourceIcon,
  ) {
    final cardColor = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariant;

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: AppSpacing.cardPadding,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: AppSpacing.borderRadiusMd,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    icon: sourceIcon,
                    label: 'From',
                    value: sourceLocationName,
                    theme: theme,
                  ),
                  AppSpacing.gapH12,
                  _SummaryRow(
                    icon: Icons.store,
                    label: 'To',
                    value: destinationName,
                    theme: theme,
                  ),
                  AppSpacing.gapH12,
                  _SummaryRow(
                    icon: Icons.battery_charging_full,
                    label: 'Batteries',
                    value: '${_selectedBatteryIds.length} units',
                    theme: theme,
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            Text('Selected Batteries:', style: theme.textTheme.titleSmall),
            AppSpacing.gapH8,
            ..._selectedBatteryIds.map(
              (id) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: theme.colorScheme.primary,
                    ),
                    AppSpacing.gapW8,
                    Expanded(
                      child: Text(id, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.gapH16,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      'Batteries will be locked and unavailable until the transfer is received at the destination.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isSubmitting) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Initiating transfer...'),
        ],
      );
    }

    if (_isConfirming) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => setState(() {
              _isConfirming = false;
              _errorMessage = null;
            }),
            child: const Text('Back'),
          ),
          AppSpacing.gapW16,
          FilledButton.icon(
            onPressed: _submitTransfer,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text('Confirm Transfer'),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppSpacing.gapW16,
        FilledButton(
          onPressed:
              _selectedBatteryIds.isEmpty || _selectedSourceLocation == null
              ? null
              : () => setState(() {
                  _pruneSelectedBatteriesToSource();
                  _isConfirming = true;
                  _errorMessage = null;
                  _successMessage = null;
                }),
          child: const Text('Review Transfer'),
        ),
      ],
    );
  }

  Future<void> _submitTransfer() async {
    final source = _selectedSourceLocation;
    if (source == null) {
      setState(() {
        _errorMessage = 'No valid source location selected';
      });
      return;
    }
    _pruneSelectedBatteriesToSource();
    if (_selectedBatteryIds.isEmpty) {
      setState(() {
        _errorMessage = 'Select at least one battery to transfer';
      });
      return;
    }
    if (source.type == _toLocationType && source.id == _toLocationId) {
      setState(() {
        _errorMessage = 'Source and destination cannot be the same';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final transferBatteryIds = _selectedBatteryIds.toList()..sort();
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.createTransfer(
        fromType: source.type,
        fromId: source.id,
        toType: _toLocationType,
        toId: _toLocationId,
        batteryIds: transferBatteryIds,
      );

      if (result.isFailure) {
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _errorMessage = result.error ?? 'Failed to create transfer';
        });
        return;
      }

      await ref
          .read(transferLocationBatteriesProvider.notifier)
          .safetyRefetchAfterTransferCreate(
            sourceLocation: InventoryLocationRef(
              locationType: source.type,
              locationId: source.id,
            ),
          );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _successMessage = 'Transfer initiated successfully!';
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Unexpected error: $e';
      });
    }
  }
}

enum _BannerType { error, success }

class _InlineBanner extends StatelessWidget {
  final String message;
  final _BannerType type;
  final VoidCallback onDismiss;

  const _InlineBanner({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isError = type == _BannerType.error;
    final bgColor = isError ? AppColors.errorLight : AppColors.successLight;
    final fgColor = isError ? AppColors.error : AppColors.success;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: fgColor.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: fgColor),
            AppSpacing.gapW8,
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, size: 16, color: fgColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        AppSpacing.gapW8,
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.gapW8,
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationSelectorCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _LocationSelectorCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onTap == null;
    final borderColor = isDisabled
        ? theme.colorScheme.outline.withValues(alpha: 0.3)
        : theme.colorScheme.outline.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: isDisabled ? 0.35 : 0.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primaryContainer
                      .withValues(alpha: isDisabled ? 0.35 : 0.7),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isDisabled
                        ? theme.disabledColor
                        : theme.colorScheme.primary,
                  ),
                ),
                AppSpacing.gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDisabled
                              ? theme.disabledColor
                              : theme.textTheme.titleSmall?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  color: isDisabled ? theme.disabledColor : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
