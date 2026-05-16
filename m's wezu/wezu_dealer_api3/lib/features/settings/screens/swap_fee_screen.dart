import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_response.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/theme/colors.dart';

class SwapFeeScreen extends ConsumerStatefulWidget {
  const SwapFeeScreen({super.key});

  @override
  ConsumerState<SwapFeeScreen> createState() => _SwapFeeScreenState();
}

class _SwapFeeScreenState extends ConsumerState<SwapFeeScreen> {
  final TextEditingController _swapFeeController =
      TextEditingController(text: '0');
  final TextInputFormatter _twoDecimalFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    return RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(text) ? newValue : oldValue;
  });

  bool _isLoading = true;
  bool _isSaving = false;
  bool _swapFeeWasUnset = true;
  String? _loadError;
  String? _validationError;
  double _loadedSwapFee = 0;

  @override
  void initState() {
    super.initState();
    _fetchRentalSettings();
  }

  @override
  void dispose() {
    _swapFeeController.dispose();
    super.dispose();
  }

  Future<void> _fetchRentalSettings() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _validationError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get(ApiConstants.rentalSettings);
      final settings = _extractSettings(response.data);

      final hasSwapFee = settings.containsKey('swap_fee');
      final rawSwapFee = settings['swap_fee'];
      final parsedSwapFee = _toDouble(rawSwapFee);

      _loadedSwapFee = parsedSwapFee ?? 0;
      _swapFeeWasUnset = !hasSwapFee || rawSwapFee == null;
      _swapFeeController.text = _formatForInput(_loadedSwapFee);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = ApiResponse.errorMessage(
            e,
            fallback: 'Failed to load rental settings',
          );
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Failed to load rental settings';
        });
      }
    }
  }

  Future<void> _saveSwapFee() async {
    final validation = _validateSwapFee(_swapFeeController.text);
    if (validation != null) {
      setState(() => _validationError = validation);
      return;
    }

    final parsedValue = double.parse(_swapFeeController.text.trim());
    final hasChanged =
        _swapFeeWasUnset || (parsedValue - _loadedSwapFee).abs() > 0.0001;

    if (!hasChanged) {
      ToastService.show(
        context,
        'No changes to save',
        type: ToastType.info,
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _validationError = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final response = await dio.patch(
        ApiConstants.rentalSettings,
        data: {'swap_fee': parsedValue},
      );

      final settings = _extractSettings(response.data);
      final updatedSwapFee = _toDouble(settings['swap_fee']) ?? parsedValue;

      if (mounted) {
        setState(() {
          _loadedSwapFee = updatedSwapFee;
          _swapFeeWasUnset = false;
          _swapFeeController.text = _formatForInput(updatedSwapFee);
        });

        ToastService.show(
          context,
          'Saved',
          type: ToastType.success,
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        ToastService.show(
          context,
          ApiResponse.errorMessage(
            e,
            fallback: 'Failed to save swap fee',
          ),
          type: ToastType.error,
        );
      }
    } catch (_) {
      if (mounted) {
        ToastService.show(
          context,
          'Failed to save swap fee',
          type: ToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Map<String, dynamic> _extractSettings(dynamic payload) {
    final map = ApiResponse.asMap(payload);

    if (map['settings'] is Map) {
      return Map<String, dynamic>.from(map['settings'] as Map);
    }

    if (map['rental_settings'] is Map) {
      return Map<String, dynamic>.from(map['rental_settings'] as Map);
    }

    return map;
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  String _formatForInput(double value) {
    final fixed = value.toStringAsFixed(2);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String? _validateSwapFee(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return 'Swap fee is required';
    if (!RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
      return 'Use a valid amount with up to 2 decimal places';
    }

    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Swap fee cannot be negative';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Container(
          width: 420,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                color: AppColors.red,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                _loadError!,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchRentalSettings,
                icon: const Icon(LucideIcons.refreshCw, size: 16),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Swap Fee Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set the amount customers pay for each battery swap.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.pageBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  _swapFeeWasUnset
                      ? 'Current value: Not set'
                      : 'Current value: ₹${_loadedSwapFee.toStringAsFixed(2)} /swap',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Swap Fee (per battery swap)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _swapFeeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [_twoDecimalFormatter],
                onChanged: (_) {
                  if (_validationError == null) return;
                  setState(() {
                    _validationError =
                        _validateSwapFee(_swapFeeController.text);
                  });
                },
                decoration: InputDecoration(
                  hintText: _swapFeeWasUnset ? 'Not set' : '0',
                  errorText: _validationError,
                  prefixText: '₹ ',
                  suffixText: '/swap',
                  filled: true,
                  fillColor: AppColors.pageBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSwapFee,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isSaving)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        const Icon(LucideIcons.save, size: 16),
                      const SizedBox(width: 8),
                      Text(_isSaving ? 'Saving...' : 'Save'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
