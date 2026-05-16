import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/filter_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/filter_state.dart';
import '../providers/map_providers.dart';
import '../../../core/theme/app_theme.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late double _radius;
  late RangeValues _priceRange;
  late double _minRating;
  late bool _onlyAvailable;
  late bool _isOpenNow;
  late bool _is24x7;
  bool? _isDealer;
  late List<String> _selectedAmenities;
  late List<String> _selectedBatteryTypes;
  late List<String> _selectedChargingSpeeds;

  static const _allAmenities = [
    '24/7 Access',
    'Climate Control',
    'Fast Charging',
    'CCTV Security',
    'Parking',
    'WiFi',
    'Coffee',
    'Restroom',
    'Lounge',
    'Security'
  ];

  static const _allBatteryTypes = ['Li-ion', 'LiFePO4', 'Lead Acid'];
  static const _allChargingSpeeds = ['Standard', 'Fast', 'Ultra'];

  @override
  void initState() {
    super.initState();
    final f = ref.read(stationFilterProvider);
    _radius = f.maxRadius;
    _priceRange = RangeValues(f.minPrice, f.maxPrice);
    _minRating = f.minRating;
    _onlyAvailable = f.onlyAvailable;
    _isOpenNow = f.isOpenNow;
    _is24x7 = f.is24x7;
    _isDealer = f.isDealer;
    _selectedAmenities = List.from(f.amenities);
    _selectedBatteryTypes = List.from(f.batteryTypes);
    _selectedChargingSpeeds = List.from(f.chargingSpeeds);
  }

  void _resetAll() {
    setState(() {
      _radius = 50.0;
      _priceRange = const RangeValues(0, 200);
      _minRating = 0.0;
      _onlyAvailable = false;
      _isOpenNow = false;
      _is24x7 = false;
      _isDealer = null;
      _selectedAmenities = [];
      _selectedBatteryTypes = [];
      _selectedChargingSpeeds = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.surfaceDark : Colors.white;
    final titleColor = isDark ? Colors.white : AppTheme.primaryBlue;
    final subtitleColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters',
                    style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: titleColor)),
                TextButton(
                    onPressed: _resetAll,
                    child: const Text('Reset',
                        style: TextStyle(color: AppTheme.primaryBlue))),
              ],
            ),
            const SizedBox(height: 20),

            // Sort By Section
            _sectionTitle('Sort By', '', subtitleColor),
            Consumer(builder: (context, ref, child) {
              final currentSort = ref.watch(stationSortProvider);
              return Row(
                children: [
                  _sortChip(context, ref, 'Distance',
                      StationSortFilter.distance, currentSort),
                  const SizedBox(width: 8),
                  _sortChip(context, ref, 'Availability',
                      StationSortFilter.availability, currentSort),
                  const SizedBox(width: 8),
                  _sortChip(context, ref, 'Rating', StationSortFilter.rating,
                      currentSort),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Quick toggles row
            Row(
              children: [
                _buildToggleChip('Open Now', _isOpenNow,
                    (v) => setState(() => _isOpenNow = v), Icons.access_time),
                const SizedBox(width: 10),
                _buildToggleChip('Open 24/7', _is24x7,
                    (v) => setState(() => _is24x7 = v), Icons.event_available),
                const SizedBox(width: 10),
                _buildToggleChip('Available', _onlyAvailable,
                    (v) => setState(() => _onlyAvailable = v), Icons.bolt),
              ],
            ),
            const SizedBox(height: 24),

            // Distance Radius
            _sectionTitle('Distance', '${_radius.toInt()} km', subtitleColor),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.primaryBlue,
                inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                thumbColor: AppTheme.primaryBlue,
                overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: _radius,
                min: 1,
                max: 100,
                onChanged: (v) => setState(() => _radius = v),
              ),
            ),
            const SizedBox(height: 16),

            // Price Range
            _sectionTitle(
                'Price',
                '₹${_priceRange.start.toInt()} – ₹${_priceRange.end.toInt()}/hr',
                subtitleColor),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.primaryBlue,
                inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                thumbColor: AppTheme.primaryBlue,
                overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: RangeSlider(
                values: _priceRange,
                min: 0,
                max: 200,
                onChanged: (v) => setState(() => _priceRange = v),
              ),
            ),
            const SizedBox(height: 16),

            // Station Type
            _sectionTitle('Station Type', '', subtitleColor),
            Row(
              children: [
                _choiceChip('All', _isDealer == null,
                    () => setState(() => _isDealer = null)),
                const SizedBox(width: 8),
                _choiceChip('Dealer', _isDealer == true,
                    () => setState(() => _isDealer = true)),
                const SizedBox(width: 8),
                _choiceChip('Official', _isDealer == false,
                    () => setState(() => _isDealer = false)),
              ],
            ),
            const SizedBox(height: 16),

            // Battery Types
            _sectionTitle('Battery Type', '', subtitleColor),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: _allBatteryTypes.map((type) {
                final selected = _selectedBatteryTypes.contains(type);
                return FilterChip(
                  label: Text(type),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedBatteryTypes.add(type);
                      } else {
                        _selectedBatteryTypes.remove(type);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : subtitleColor,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Charging Speeds
            _sectionTitle('Charging Speed', '', subtitleColor),
            Wrap(
              spacing: 8,
              runSpacing: 0,
              children: _allChargingSpeeds.map((speed) {
                final selected = _selectedChargingSpeeds.contains(speed);
                return FilterChip(
                  label: Text(speed),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedChargingSpeeds.add(speed);
                      } else {
                        _selectedChargingSpeeds.remove(speed);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : subtitleColor,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Rating
            _sectionTitle('Minimum Rating', '', subtitleColor),
            Row(
              children: [0.0, 3.0, 4.0, 4.5].map((rating) {
                final selected = _minRating == rating;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (rating > 0)
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                        if (rating > 0) const SizedBox(width: 4),
                        Text(rating == 0.0 ? 'All' : '$rating+'),
                      ],
                    ),
                    selected: selected,
                    onSelected: (s) {
                      if (s) setState(() => _minRating = rating);
                    },
                    selectedColor: AppTheme.primaryBlue,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : subtitleColor),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Amenities
            _sectionTitle('Amenities', '', subtitleColor),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allAmenities.map((amenity) {
                final selected = _selectedAmenities.contains(amenity);
                return FilterChip(
                  label: Text(amenity),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _selectedAmenities.add(amenity);
                      } else {
                        _selectedAmenities.remove(amenity);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : subtitleColor,
                      fontSize: 13),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(filterNotifierProvider.notifier).updateFilters(
                        StationFilterState(
                          maxRadius: _radius,
                          minPrice: _priceRange.start,
                          maxPrice: _priceRange.end,
                          minRating: _minRating,
                          onlyAvailable: _onlyAvailable,
                          isDealer: _isDealer,
                          isOpenNow: _isOpenNow,
                          is24x7: _is24x7,
                          amenities: _selectedAmenities,
                          batteryTypes: _selectedBatteryTypes,
                          chargingSpeeds: _selectedChargingSpeeds,
                        ),
                      );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: Text('APPLY FILTERS',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleChip(
      String label, bool value, ValueChanged<bool> onChanged, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: value
                ? AppTheme.primaryBlue
                : AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: value ? AppTheme.primaryBlue : Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: value ? Colors.white : AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: value ? Colors.white : AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600, color: color, fontSize: 16)),
          if (value.isNotEmpty)
            Text(value,
                style: GoogleFonts.inter(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
        ],
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.grey),
    );
  }

  Widget _sortChip(BuildContext context, WidgetRef ref, String label,
      StationSortFilter filter, StationSortFilter current) {
    final isSelected = filter == current;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          ref.read(stationSortProvider.notifier).state = filter;
        }
      },
      selectedColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
    );
  }
}
