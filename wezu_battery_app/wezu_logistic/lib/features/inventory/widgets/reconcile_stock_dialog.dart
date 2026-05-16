import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../providers/inventory_providers.dart';

class ReconcileStockDialog extends ConsumerStatefulWidget {
  const ReconcileStockDialog({super.key});

  @override
  ConsumerState<ReconcileStockDialog> createState() =>
      _ReconcileStockDialogState();
}

class _ReconcileStockDialogState extends ConsumerState<ReconcileStockDialog> {
  final _scannedController = TextEditingController();
  final List<String> _scannedIds = [];

  bool _isLoadingLocations = true;
  bool _isSubmitting = false;
  String? _locationLoadError;
  List<_ReconcileLocationOption> _locationOptions = const [];
  String? _selectedLocationKey;

  _ReconcileLocationOption? get _selectedLocation {
    if (_selectedLocationKey == null) return null;
    for (final option in _locationOptions) {
      if (option.key == _selectedLocationKey) return option;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoadingLocations = true;
      _locationLoadError = null;
    });

    final repo = ref.read(inventoryRepositoryProvider);
    final result = await repo.fetchTransferLocationData();
    if (!mounted) return;

    result.when(
      success: (data) {
        final options = <_ReconcileLocationOption>[
          ...data.warehouses.map(
            (warehouse) => _ReconcileLocationOption(
              locationType: 'warehouse',
              locationId: warehouse.id,
              label: '${warehouse.name} (Warehouse #${warehouse.id})',
            ),
          ),
          ...data.destinations.map(
            (destination) => _ReconcileLocationOption(
              locationType: 'station',
              locationId: destination.id,
              label: '${destination.name} (Station #${destination.id})',
            ),
          ),
        ];
        final existingSelection = _selectedLocationKey;
        final hasExistingSelection =
            existingSelection != null &&
            options.any((option) => option.key == existingSelection);
        setState(() {
          _locationOptions = options;
          _selectedLocationKey = hasExistingSelection
              ? existingSelection
              : (options.isEmpty ? null : options.first.key);
          _isLoadingLocations = false;
        });
      },
      failure: (message, _) {
        setState(() {
          _locationLoadError = message;
          _isLoadingLocations = false;
        });
      },
    );
  }

  void _addId() {
    final id = _scannedController.text.trim();
    if (id.isNotEmpty && !_scannedIds.contains(id)) {
      setState(() {
        _scannedIds.add(id);
        _scannedController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxDialogHeight = mediaQuery.size.height * 0.86;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxDialogHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconcile Inventory',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              AppSpacing.gapH16,
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isLoadingLocations)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Loading locations...'),
                            ],
                          ),
                        )
                      else if (_locationLoadError != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Failed to load locations: $_locationLoadError',
                              style: const TextStyle(color: AppColors.error),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _loadLocations,
                                child: const Text('Retry'),
                              ),
                            ),
                          ],
                        )
                      else
                        DropdownButtonFormField<String>(
                          initialValue: _selectedLocationKey,
                          isExpanded: true,
                          menuMaxHeight: 360,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.place_outlined),
                          ),
                          selectedItemBuilder: (context) => _locationOptions
                              .map(
                                (option) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    option.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          items: _locationOptions
                              .map(
                                (option) => DropdownMenuItem<String>(
                                  value: option.key,
                                  child: Text(
                                    option.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedLocationKey = value),
                        ),
                      AppSpacing.gapH16,
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _scannedController,
                              decoration: const InputDecoration(
                                hintText: 'Scan or enter Battery ID',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                              onSubmitted: (_) => _addId(),
                            ),
                          ),
                          AppSpacing.gapW8,
                          IconButton.filled(
                            onPressed: _addId,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      AppSpacing.gapH16,
                      if (_scannedIds.isNotEmpty) ...[
                        Text(
                          'Scanned Items (${_scannedIds.length})',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        AppSpacing.gapH8,
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _scannedIds.length,
                            itemBuilder: (context, index) => ListTile(
                              dense: true,
                              title: Text(
                                _scannedIds[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () =>
                                    setState(() => _scannedIds.removeAt(index)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              AppSpacing.gapH16,
              OverflowBar(
                alignment: MainAxisAlignment.end,
                overflowAlignment: OverflowBarAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  AppSpacing.gapW16,
                  FilledButton(
                    onPressed:
                        _isSubmitting ||
                            _scannedIds.isEmpty ||
                            _selectedLocation == null
                        ? null
                        : _submitReconciliation,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Count'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReconciliation() async {
    final selected = _selectedLocation;
    if (selected == null) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(inventoryRepositoryProvider);
      final result = await repo.reconcileInventory(
        locationType: selected.locationType,
        locationId: selected.locationId,
        physicalCount: _scannedIds.length,
        scannedIds: _scannedIds,
      );

      result.when(
        success: (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reconciliation submitted. Check Discrepancies.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        },
        failure: (message, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed: $message'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _ReconcileLocationOption {
  final String locationType;
  final int locationId;
  final String label;

  const _ReconcileLocationOption({
    required this.locationType,
    required this.locationId,
    required this.label,
  });

  String get key => '$locationType:$locationId';
}
