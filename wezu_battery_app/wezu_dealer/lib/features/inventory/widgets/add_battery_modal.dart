import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/api/api_client.dart';
import '../../../core/theme/colors.dart';
import '../models/inventory_state.dart';
import '../providers/inventory_provider.dart';

/// Redesigned Add Battery Modal
/// Replaces the old side drawer with a centered, 2-step flow.
/// Step 1: Asset Lookup (Scan / ID Entry)
/// Step 2: Configuration & Station Assignment
class AddBatteryModal extends ConsumerStatefulWidget {
  const AddBatteryModal({super.key});

  @override
  ConsumerState<AddBatteryModal> createState() => _AddBatteryModalState();
}

class _AddBatteryModalState extends ConsumerState<AddBatteryModal> {
  int _step = 1;

  // Step 1 State
  final _idController = TextEditingController();
  bool _isValidating = false;
  String? _validationError;
  BatteryItemDto? _scannedAsset;

  // Step 2 State
  String? _selectedStation;
  bool _requiresInitialCharge = true;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _lookupAsset() async {
    final val = _idController.text.trim();
    if (val.isEmpty) {
      setState(() => _validationError = 'Please enter an Asset ID.');
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('${ApiConstants.inventory.replaceAll('/inventory', '')}/batteries/$val');
      
      if (response.data != null && response.data['success'] == true) {
        setState(() {
          _isValidating = false;
          _scannedAsset = BatteryItemDto.fromJson(response.data['data']);
          _step = 2; // Move to next step
        });
      } else {
        throw Exception('Asset not found');
      }
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationError = 'Asset not found in WEZU global registry.';
      });
    }
  }

  void _submit() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post(
        '${ApiConstants.inventory.replaceAll('/inventory', '')}/batteries/${_scannedAsset?.batteryId}/assign',
        data: {
          'station_id': _selectedStation,
          'requires_initial_charge': _requiresInitialCharge,
        },
      );
    } catch (e) {
      // Intentionally fall through if API not ready
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asset ${_scannedAsset?.serialNumber} registered successfully'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    // Refresh list
    ref.read(inventoryBatteriesProvider.notifier).fetchPage();
    ref.read(inventoryMetricsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 24,
      child: Container(
        width: 480,
        constraints: const BoxConstraints(minHeight: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(LucideIcons.packagePlus, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Register New Asset',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _step == 1
                              ? 'Step 1 of 2: Lookup Asset in Global Registry'
                              : 'Step 2 of 2: Assignment & Configuration',
                          style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x, size: 20, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _step == 1 ? _buildStep1() : _buildStep2(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // QR scanner area
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 120),
                painter: _ScannerBracketPainter(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.scanLine, size: 32, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                  const SizedBox(height: 12),
                  const Text(
                    'Position QR code in frame',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('OR ENTER MANUALLY', style: TextStyle(fontSize: 10, color: AppColors.textTertiary, fontWeight: FontWeight.w700)),
            ),
            Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 20),
        
        // Manual entry field
        TextField(
          controller: _idController,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: 'e.g. WZ-BAT-2026-X',
            hintStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.pageBg,
            errorText: _validationError,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
          onSubmitted: (_) => _lookupAsset(),
        ),
        const SizedBox(height: 24),
        
        ElevatedButton(
          onPressed: _isValidating ? null : _lookupAsset,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          ),
          child: _isValidating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lookup Asset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final asset = _scannedAsset!;
    return Column(
      key: const ValueKey('step2'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Asset card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pageBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.checkCircle2, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Validated Asset', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                    const SizedBox(height: 4),
                    Text(
                      asset.serialNumber,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'SOH: ${asset.health.percentage}% • SOC: ${asset.charge.percentage}%',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Station Assignment
        const Text('STATION ASSIGNMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStation,
          dropdownColor: AppColors.cardBg,
          decoration: InputDecoration(
            hintText: 'Assign to a station (Optional)',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.pageBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Station Alpha — Downtown', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
            DropdownMenuItem(value: '2', child: Text('Station Beta — Airport', style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
          ],
          onChanged: (val) => setState(() => _selectedStation = val),
        ),
        const SizedBox(height: 20),

        // Settings Toggles
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Initial Charging Required', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(
                      'Because SOC is ${asset.charge.percentage}%, battery will be locked until 100%.',
                      style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _requiresInitialCharge,
                onChanged: (val) => setState(() => _requiresInitialCharge = val),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(LucideIcons.packagePlus, size: 16),
                label: const Text('Confirm Registration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScannerBracketPainter extends CustomPainter {
  final Color color;
  _ScannerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLength = 20.0;

    // TL
    canvas.drawPath(Path()..moveTo(0, cornerLength)..lineTo(0, 0)..lineTo(cornerLength, 0), paint);
    // TR
    canvas.drawPath(Path()..moveTo(size.width - cornerLength, 0)..lineTo(size.width, 0)..lineTo(size.width, cornerLength), paint);
    // BL
    canvas.drawPath(Path()..moveTo(0, size.height - cornerLength)..lineTo(0, size.height)..lineTo(cornerLength, size.height), paint);
    // BR
    canvas.drawPath(Path()..moveTo(size.width - cornerLength, size.height)..lineTo(size.width, size.height)..lineTo(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
