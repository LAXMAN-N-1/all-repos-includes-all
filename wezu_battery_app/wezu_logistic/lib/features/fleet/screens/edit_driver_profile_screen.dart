import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../models/driver_model.dart';
import '../../../../widgets/app_button.dart';
import '../../../../widgets/app_card.dart';
import '../../../../widgets/app_loader.dart';
import '../../../../widgets/app_scaffold.dart';
import '../../../../widgets/app_text_field.dart';
import '../providers/logistics_providers.dart';
import '../widgets/driver_status_chip.dart';

class EditDriverProfileScreen extends ConsumerStatefulWidget {
  const EditDriverProfileScreen({super.key, required this.driverId});

  final String driverId;

  @override
  ConsumerState<EditDriverProfileScreen> createState() =>
      _EditDriverProfileScreenState();
}

class _EditDriverProfileScreenState
    extends ConsumerState<EditDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  DriverModel? _driver;
  String? _errorMessage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadDriver();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadDriver() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(driverRepositoryProvider)
        .fetchDriver(widget.driverId);
    if (!mounted) return;

    result.when(
      success: (driver) {
        _driver = driver;
        _nameController.text = driver.name;
        _phoneController.text = driver.phoneNumber;
        _vehicleTypeController.text = driver.vehicleType;
        _vehiclePlateController.text = driver.vehiclePlate;
      },
      failure: (message, _) {
        _errorMessage = message;
      },
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _phoneComparable(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';
    return hasPlus ? '+$digits' : digits;
  }

  void _showSnack(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    final currentDriver = _driver;
    if (currentDriver == null) return;

    final nextName = _nameController.text.trim();
    final nextPhone = _phoneController.text.trim();
    final nextVehicleType = _vehicleTypeController.text.trim();
    final nextVehiclePlate = _vehiclePlateController.text.trim().toUpperCase();
    final nextLicense = _licenseNumberController.text.trim().toUpperCase();

    final changedName = nextName != currentDriver.name.trim();
    final changedPhone =
        _phoneComparable(nextPhone) !=
        _phoneComparable(currentDriver.phoneNumber);
    final changedVehicleType =
        nextVehicleType != currentDriver.vehicleType.trim();
    final changedVehiclePlate =
        nextVehiclePlate != currentDriver.vehiclePlate.trim().toUpperCase();
    final changedLicense = nextLicense.isNotEmpty;

    if (!changedName &&
        !changedPhone &&
        !changedVehicleType &&
        !changedVehiclePlate &&
        !changedLicense) {
      _showSnack('No changes to save.', backgroundColor: AppColors.info);
      return;
    }

    setState(() => _isSaving = true);
    final result = await ref
        .read(driverRepositoryProvider)
        .updateDriverProfile(
          widget.driverId,
          name: changedName ? nextName : null,
          phoneNumber: changedPhone ? nextPhone : null,
          vehicleType: changedVehicleType ? nextVehicleType : null,
          vehiclePlate: changedVehiclePlate ? nextVehiclePlate : null,
          licenseNumber: changedLicense ? nextLicense : null,
        );
    if (!mounted) return;

    setState(() => _isSaving = false);
    result.when(
      success: (updatedDriver) {
        context.pop(updatedDriver);
      },
      failure: (message, _) {
        _showSnack(
          message.isNotEmpty ? message : 'Failed to update driver profile.',
          backgroundColor: AppColors.error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Edit Driver Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadDriver,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const AppLoader();
    }

    if (_driver == null) {
      return Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 28,
                ),
                AppSpacing.gapH12,
                Text(
                  _errorMessage ?? 'Unable to load driver profile.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                AppSpacing.gapH16,
                AppButton(
                  label: 'Retry',
                  onPressed: _loadDriver,
                  icon: Icons.refresh_rounded,
                  size: AppButtonSize.medium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final driver = _driver!;
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      driver.name.isEmpty ? '?' : driver.name.characters.first,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppSpacing.gapW12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'ID: ${driver.id}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  DriverStatusChip(status: driver.status),
                ],
              ),
            ),
            AppSpacing.gapH16,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapH12,
                  AppTextField(
                    controller: _nameController,
                    label: 'Driver Name',
                    hint: 'e.g. Rahul Kumar',
                    prefixIcon: Icons.person_outline_rounded,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Name is required';
                      if (trimmed.length > 120) {
                        return 'Name must be 120 characters or less';
                      }
                      return null;
                    },
                  ),
                  AppSpacing.gapH16,
                  AppTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'e.g. +91 9876543210',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Phone number is required';
                      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
                      if (digits.length < 10 || digits.length > 15) {
                        return 'Phone must contain 10 to 15 digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapH12,
                  AppTextField(
                    controller: _vehicleTypeController,
                    label: 'Vehicle Type',
                    hint: 'e.g. Van, Bike, Truck',
                    prefixIcon: Icons.directions_car_outlined,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Vehicle type is required';
                      return null;
                    },
                  ),
                  AppSpacing.gapH16,
                  AppTextField(
                    controller: _vehiclePlateController,
                    label: 'Vehicle Plate',
                    hint: 'e.g. KA-01-AB-1234',
                    prefixIcon: Icons.local_shipping_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Vehicle plate is required';
                      return null;
                    },
                  ),
                  AppSpacing.gapH16,
                  AppTextField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                    hint: 'Leave empty to keep existing license',
                    helperText:
                        'Backend does not return current license in driver details.',
                    prefixIcon: Icons.badge_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      final trimmed = value?.trim() ?? '';
                      if (trimmed.isEmpty) return null;
                      if (trimmed.length < 3) {
                        return 'License number looks too short';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'Deliveries',
                      value: '${driver.completedDeliveries}',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Rating',
                      value: driver.rating.toStringAsFixed(1),
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'Battery',
                      value: '${driver.currentBatteryLevel}%',
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH24,
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Save Changes',
                icon: Icons.save_outlined,
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        AppSpacing.gapH4,
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
