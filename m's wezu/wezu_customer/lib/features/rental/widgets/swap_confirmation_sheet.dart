import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/rental_providers.dart';
import '../services/swap_request_service.dart';

class SwapConfirmationSheet extends ConsumerStatefulWidget {
  final String batteryId;

  const SwapConfirmationSheet({super.key, required this.batteryId});

  @override
  ConsumerState<SwapConfirmationSheet> createState() =>
      _SwapConfirmationSheetState();
}

class _SwapConfirmationSheetState extends ConsumerState<SwapConfirmationSheet> {
  int _currentStep = 0;
  List<SwapStationOption>? _options;
  SwapStationOption? _selectedStation;
  int _selectedDuration = 7; // Default 7 days
  bool _isProcessing = false;
  double? _swapFee;
  bool _fetchingFee = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions([String? batteryType]) async {
    final swapService = ref.read(swapRequestServiceProvider);
    try {
      final options = await swapService.getNearestSwapOptions(
        batteryTypeFilter: batteryType,
      );
      if (mounted) {
        setState(() {
          _options = options;
          final availableTypes = _deriveFilterTypes(options);
          if (_selectedType != 'All' &&
              !availableTypes.contains(_selectedType)) {
            _selectedType = 'All';
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _options = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_options == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.accentGreen),
          SizedBox(height: 20),
          Text('Loading available stations...',
              style: TextStyle(color: AppTheme.textSecondary)),
        ],
      );
    }

    switch (_currentStep) {
      case 0:
        return _buildStationSelection();
      case 1:
        return _buildDurationSelection();
      case 2:
        return _buildSummaryConfirmation();
      case 3:
        return _buildSuccessState();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStationSelection() {
    return Column(
      key: const ValueKey(0),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Swap Station',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildFilterRow(),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4),
          child: _options!.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text('No stations available',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                )
              : ListView(
                  shrinkWrap: true,
                  children:
                      _options!.map((opt) => _buildStationCard(opt)).toList(),
                ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _selectedStation != null
              ? () => setState(() => _currentStep = 1)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentGreen,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('NEXT: RENTAL DURATION'),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    final types = ['All', ..._deriveFilterTypes(_options ?? const [])];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: types.map((type) {
          final isSelected = (_selectedType == type);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedType = type;
                  _options = null;
                });
                _loadOptions(type == 'All' ? null : type);
              },
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              selectedColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _selectedType = 'All';

  List<String> _deriveFilterTypes(List<SwapStationOption> options) {
    final set = <String>{};
    for (final option in options) {
      for (final type in option.supportedBatteryTypes) {
        final trimmed = type.trim();
        if (trimmed.isNotEmpty) {
          set.add(trimmed);
        }
      }
    }
    final types = set.toList()..sort((a, b) => a.compareTo(b));
    return types;
  }

  Future<void> _fetchFeeForStation(SwapStationOption station) async {
    if (!mounted) return;
    setState(() {
      _fetchingFee = true;
      _swapFee = null;
    });
    try {
      final swapService = ref.read(swapRequestServiceProvider);
      final fee = await swapService.getSwapFee(station.id);
      if (mounted) setState(() => _swapFee = fee);
    } catch (_) {
      if (mounted) setState(() => _swapFee = 0.0);
    } finally {
      if (mounted) setState(() => _fetchingFee = false);
    }
  }

  Widget _buildStationCard(SwapStationOption station) {
    final bool isSelected = _selectedStation?.id == station.id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStation = station);
        _fetchFeeForStation(station);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGreen.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppTheme.accentGreen : Colors.transparent),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(LucideIcons.mapPin,
                    color: isSelected
                        ? AppTheme.accentGreen
                        : AppTheme.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(station.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(station.operatingHours,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                          const SizedBox(width: 12),
                          const Icon(LucideIcons.batteryCharging,
                              size: 12, color: AppTheme.accentGreen),
                          const SizedBox(width: 4),
                          Text(
                              '${station.availableSlots}/${station.totalCapacity} slots',
                              style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppTheme.accentGreen),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 40),
                Text(
                    station.distanceKm > 0
                        ? '${station.distanceKm.toStringAsFixed(1)}km · ${station.estimatedMinutes} mins drive'
                        : 'Available station',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
                const Spacer(),
                Wrap(
                  spacing: 4,
                  children: (station.supportedBatteryTypes.isEmpty
                          ? const ['All models']
                          : station.supportedBatteryTypes)
                      .map((type) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(type,
                                style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelection() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('New Rental Duration',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildDurationOption(7, '7 Days', 'Short term top-up'),
        _buildDurationOption(14, '14 Days', 'Most popular choice'),
        _buildDurationOption(30, '30 Days', 'Best value monthly'),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() => _currentStep = 0),
                child: const Text('BACK',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            ),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('NEXT: SUMMARY'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOption(int days, String label, String sub) {
    final bool isSelected = _selectedDuration == days;
    return GestureDetector(
      onTap: () => setState(() => _selectedDuration = days),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.calendar,
                color:
                    isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(sub,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryConfirmation() {
    final feeLabel = _fetchingFee
        ? 'Loading...'
        : (_swapFee != null && _swapFee! > 0)
            ? '₹${_swapFee!.toStringAsFixed(2)}'
            : 'Free';

    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Confirm Swap Request',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                  LucideIcons.mapPin, 'Destination', _selectedStation!.name),
              const Divider(color: Colors.white10, height: 24),
              _buildSummaryRow(LucideIcons.clock, 'Arrival Time',
                  'In ${_selectedStation!.estimatedMinutes} mins'),
              const Divider(color: Colors.white10, height: 24),
              _buildSummaryRow(LucideIcons.refreshCw, 'New Duration',
                  '$_selectedDuration Days'),
              const Divider(color: Colors.white10, height: 24),
              _buildSummaryRow(LucideIcons.creditCard, 'Swap Fee', feeLabel),
            ],
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(_errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
        ],
        const SizedBox(height: 32),
        _isProcessing
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.accentGreen))
            : ElevatedButton(
                onPressed: _fetchingFee ? null : _handleConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('CONFIRM SWAP REQUEST',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 18),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14))),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Future<void> _handleConfirm() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    try {
      final swapService = ref.read(swapRequestServiceProvider);
      await swapService.confirmSwapRequest(
        stationId: _selectedStation!.id,
        durationDays: _selectedDuration,
        batteryId: widget.batteryId,
      );
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 3;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'Swap request failed. Please try again.';
        });
      }
    }
  }

  Widget _buildSuccessState() {
    return Column(
      key: const ValueKey(3),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 80),
        const SizedBox(height: 24),
        const Text('Swap Request Confirmed!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
            'Please head to ${_selectedStation!.name}. The station is notified of your arrival.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.surfaceDark,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            side: const BorderSide(color: Colors.white10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
