import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/features/maps/models/station.dart';
import 'package:wezu_customer_app/features/rental/models/battery.dart';
import 'package:wezu_customer_app/features/rental/models/rental.dart';
import 'package:wezu_customer_app/features/rental/providers/rental_providers.dart';
import 'package:wezu_customer_app/features/rental/screens/rental_return_success_screen.dart';

class RentalReturnScreen extends ConsumerStatefulWidget {
  const RentalReturnScreen({super.key, required this.rental});

  final Rental rental;

  @override
  ConsumerState<RentalReturnScreen> createState() => _RentalReturnScreenState();
}

class _RentalReturnScreenState extends ConsumerState<RentalReturnScreen> {
  int? _selectedStationId;
  bool _isSubmitting = false;
  bool _swapOnReturn = false;
  int? _selectedNewBatteryId;

  Future<void> _submitReturn(List<Station> stations) async {
    if (_selectedStationId == null || _isSubmitting) return;

    if (_swapOnReturn && _selectedNewBatteryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pick a battery to take, or turn off swap.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(rentalRepositoryProvider);

      final result = await repository.returnRentalWithSwap(
        widget.rental.id,
        _selectedStationId!,
        _swapOnReturn && _selectedNewBatteryId != null
            ? _selectedNewBatteryId!
            : -1,
      );

      ref.invalidate(activeRentalsProvider);
      ref.invalidate(rentalHistoryProvider);

      final station = stations.firstWhere((s) => s.id == _selectedStationId);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RentalReturnSuccessScreen(
            rentalId: widget.rental.id,
            stationName: station.name,
            swapSessionId: result.swapSessionId,
            swapFee: result.swapFee,
            swapError: result.swapError,
            newRentalId: result.newRentalId,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stationsAsync = ref.watch(rentalStationOptionsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Return Battery',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load stations: $error',
                textAlign: TextAlign.center),
          ),
        ),
        data: (stations) {
          final stationValue = stations.any((s) => s.id == _selectedStationId)
              ? _selectedStationId
              : null;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Rental info card
              _card(isDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rental #${widget.rental.id}',
                          style: GoogleFonts.outfit(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(widget.rental.battery.modelName,
                          style:
                              GoogleFonts.inter(color: Colors.grey.shade600)),
                    ],
                  )),
              const SizedBox(height: 16),

              // Station picker
              _card(isDark,
                  child: DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: stationValue,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Return Station',
                      hintText: 'Choose station to return',
                    ),
                    items: stations
                        .map((s) => DropdownMenuItem<int>(
                              value: s.id,
                              child:
                                  Text(s.name, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _selectedStationId = value;
                      _selectedNewBatteryId = null;
                    }),
                  )),
              const SizedBox(height: 16),

              // Swap-on-return toggle
              if (_selectedStationId != null) ...[
                _card(isDark,
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Take a fresh battery?',
                          style:
                              GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'Pick up a charged battery from this station right now.',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      value: _swapOnReturn,
                      onChanged: (v) => setState(() {
                        _swapOnReturn = v;
                        _selectedNewBatteryId = null;
                      }),
                    )),
                const SizedBox(height: 16),
              ],

              // Battery picker (shown when swap toggle is ON)
              if (_swapOnReturn && _selectedStationId != null)
                _BatteryPicker(
                  stationId: _selectedStationId!,
                  selectedBatteryId: _selectedNewBatteryId,
                  isDark: isDark,
                  onSelected: (id) =>
                      setState(() => _selectedNewBatteryId = id),
                ),

              const SizedBox(height: 8),

              // Submit
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedStationId == null || _isSubmitting)
                      ? null
                      : () => _submitReturn(stations),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_swapOnReturn
                          ? 'Return & Get New Battery'
                          : 'Confirm Return'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.shadowLight,
      ),
      child: child,
    );
  }
}

class _BatteryPicker extends ConsumerWidget {
  const _BatteryPicker({
    required this.stationId,
    required this.selectedBatteryId,
    required this.isDark,
    required this.onSelected,
  });

  final int stationId;
  final int? selectedBatteryId;
  final bool isDark;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final batteriesAsync = ref.watch(batteriesAtStationProvider(stationId));

    return batteriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text('Could not load batteries: $e',
            style: GoogleFonts.inter(color: Colors.red)),
      ),
      data: (batteries) {
        final available = batteries
            .where((b) =>
                b.status.toLowerCase() == 'available' ||
                b.status.toLowerCase() == 'ready')
            .toList();

        if (available.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.shadowLight,
              ),
              child: Text(
                'No charged batteries available at this station right now.',
                style: GoogleFonts.inter(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('Select Battery to Take',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
              ),
              ...available.map((battery) => _BatteryTile(
                    battery: battery,
                    isSelected: selectedBatteryId == battery.id,
                    isDark: isDark,
                    onTap: () => onSelected(battery.id),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _BatteryTile extends StatelessWidget {
  const _BatteryTile({
    required this.battery,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final Battery battery;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final soc = battery.currentCharge.toInt();
    final socColor = soc >= 70
        ? Colors.green
        : soc >= 40
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.12)
              : isDark
                  ? const Color(0xFF1E293B)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Row(
          children: [
            Icon(
              Icons.battery_charging_full,
              color: socColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(battery.modelName,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  Text('SN: ${battery.serialNumber}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$soc%',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        color: socColor,
                        fontSize: 16)),
                Text('charge',
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey)),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
