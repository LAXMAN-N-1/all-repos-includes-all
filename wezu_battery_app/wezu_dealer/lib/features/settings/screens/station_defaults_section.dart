import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'settings_theme.dart';
import 'settings_common_widgets.dart';

class StationDefaultsSection extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final Map<String, String> initialValues;
  final bool isRealTime;

  const StationDefaultsSection({
    super.key,
    required this.controllers,
    required this.initialValues,
    this.isRealTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'Station Operations',
      accentColor: SettingsTheme.primaryCyan,
      dataStatus: isRealTime ? 'Real-time Data' : 'Pending Configuration',
      children: [
        _buildField('Default Open Time', 'station_open_time'),
        _buildField('Default Close Time', 'station_close_time'),
        _buildField(
          'Battery Capacity', 
          'battery_capacity',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        _buildField(
          'Low Stock Threshold', 
          'low_stock_threshold',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const Divider(height: 48, color: SettingsTheme.borderSubtle),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                   Text('Station Status Default', style: SettingsTheme.h3), 
                   Text('Sets the initial status for newly added stations', style: SettingsTheme.subline)
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: true, 
              activeTrackColor: SettingsTheme.primaryGreen.withValues(alpha: 0.3),
              activeThumbColor: SettingsTheme.primaryGreen, 
              onChanged: (v) {}
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(String label, String key, {TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    final controller = controllers[key];
    final isModified = controller != null && controller.text != (initialValues[key] ?? '');
    
    return SettingsFieldRow(
      label: label, 
      controller: controller, 
      isModified: isModified,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
    );
  }
}
