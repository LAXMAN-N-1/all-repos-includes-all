import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';
import 'package:wezu_customer_app/features/maps/models/station.dart';
import 'package:wezu_customer_app/features/rental/models/battery.dart';
import 'package:wezu_customer_app/features/rental/providers/rental_providers.dart';
import 'package:wezu_customer_app/features/rental/screens/rent_payment_confirmation_screen.dart';

class RentBatteryScreen extends ConsumerStatefulWidget {
  const RentBatteryScreen({super.key});

  @override
  ConsumerState<RentBatteryScreen> createState() => _RentBatteryScreenState();
}

class _RentBatteryScreenState extends ConsumerState<RentBatteryScreen> {
  int? _selectedStationId;
  int? _selectedBatteryId;

  bool _isBatteryAvailable(Battery battery) {
    final status = battery.status.toLowerCase();
    return status == 'available' || status == 'ready';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stationsAsync = ref.watch(rentalStationOptionsProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Rent A Battery',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: stationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load stations: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (stations) {
          final stationOptions =
              stations.isNotEmpty ? stations : const <Station>[];
          final stationValue = stationOptions.any(
            (station) => station.id == _selectedStationId,
          )
              ? _selectedStationId
              : null;
          final selectedStation = stationOptions.cast<Station?>().firstWhere(
              (s) => s?.id == _selectedStationId,
              orElse: () => null);

          final batteriesAsync = _selectedStationId == null
              ? null
              : ref.watch(batteriesAtStationProvider(_selectedStationId!));

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionCard(
                title: 'Select Station',
                child: DropdownButtonFormField<int>(
                  value: stationValue,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    hintText: 'Choose a station',
                  ),
                  items: stationOptions
                      .map(
                        (station) => DropdownMenuItem<int>(
                          value: station.id,
                          child: Text(
                            '${station.name} (${station.availableBatteries} available)',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStationId = value;
                      _selectedBatteryId = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Select Battery',
                child: _buildBatteryDropdown(batteriesAsync),
              ),
              const SizedBox(height: 20),
              if (selectedStation != null)
                _StationSummaryCard(station: selectedStation),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _canContinue(stationOptions, batteriesAsync)
                      ? () =>
                          _continueToPayment(stationOptions, batteriesAsync!)
                      : null,
                  child: const Text('Continue To Payment'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBatteryDropdown(AsyncValue<List<Battery>>? batteriesAsync) {
    if (batteriesAsync == null) {
      return const Text(
        'Select a station first.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return batteriesAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text('Failed to load batteries: $error'),
      data: (batteries) {
        final available = batteries.where(_isBatteryAvailable).toList();
        final options = available.isNotEmpty ? available : batteries;
        final batteryValue =
            options.any((item) => item.id == _selectedBatteryId)
                ? _selectedBatteryId
                : null;
        if (options.isEmpty) {
          return const Text(
            'No batteries available at this station.',
            style: TextStyle(color: Colors.grey),
          );
        }

        return DropdownButtonFormField<int>(
          value: batteryValue,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Choose a battery'),
          items: options
              .map(
                (battery) => DropdownMenuItem<int>(
                  value: battery.id,
                  child: Text(
                    '${battery.modelNumber} • ${battery.currentCharge.toStringAsFixed(0)}% SOC',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _selectedBatteryId = value),
        );
      },
    );
  }

  bool _canContinue(
    List<Station> stations,
    AsyncValue<List<Battery>>? batteriesAsync,
  ) {
    if (_selectedStationId == null || _selectedBatteryId == null) {
      return false;
    }
    final batteries = batteriesAsync?.asData?.value;
    if (batteries == null) {
      return false;
    }
    final selectedStation =
        stations.any((station) => station.id == _selectedStationId);
    final selectedBattery =
        batteries.any((battery) => battery.id == _selectedBatteryId);
    return selectedStation && selectedBattery;
  }

  void _continueToPayment(
    List<Station> stations,
    AsyncValue<List<Battery>> batteriesAsync,
  ) {
    final station =
        stations.firstWhere((item) => item.id == _selectedStationId);
    final batteries = batteriesAsync.asData?.value ?? <Battery>[];
    final battery =
        batteries.firstWhere((item) => item.id == _selectedBatteryId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RentPaymentConfirmationScreen(
          station: station,
          battery: battery,
          durationDays: 30,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StationSummaryCard extends StatelessWidget {
  const _StationSummaryCard({required this.station});

  final Station station;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station.name,
            style:
                GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(station.address, style: GoogleFonts.inter(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            'Available Batteries: ${station.availableBatteries}',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
