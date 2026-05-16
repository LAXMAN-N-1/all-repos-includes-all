import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../stations/providers/stations_provider.dart';

class StationFilter extends ConsumerWidget {
  final String? selectedStationId;
  final Function(String?) onStationChanged;

  const StationFilter({
    super.key,
    this.selectedStationId,
    required this.onStationChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationsState = ref.watch(stationsProvider);
    final stations = stationsState.stations;

    String selectedLabel = 'All Stations';
    if (selectedStationId != null) {
      final selected = stations.where((s) => s.id.toString() == selectedStationId).firstOrNull;
      if (selected != null) {
        selectedLabel = selected.name;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Station',
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppColors.cardBg,
          ),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: selectedStationId,
                icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textTertiary),
                isExpanded: true,
                hint: Text(
                  selectedLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                dropdownColor: AppColors.cardBg,
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'All Stations',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                  ...stations.map((station) {
                    return DropdownMenuItem<String?>(
                      value: station.id.toString(),
                      child: Text(
                        station.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    );
                  }),
                ],
                onChanged: onStationChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
