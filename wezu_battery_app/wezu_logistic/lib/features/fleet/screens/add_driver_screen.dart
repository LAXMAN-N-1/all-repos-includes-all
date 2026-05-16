import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_colors.dart';
import '../../../config/app_spacing.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_scaffold.dart';
import '../../../models/driver_model.dart';
import '../providers/logistics_providers.dart';

class AddDriverScreen extends ConsumerStatefulWidget {
  const AddDriverScreen({super.key});

  @override
  ConsumerState<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends ConsumerState<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _plateController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final newDriver = DriverModel(
      id: _userIdController.text.trim(),
      name: _nameController.text,
      phoneNumber: _phoneController.text,
      status: DriverStatus.available,
      vehicleType: _vehicleTypeController.text,
      vehiclePlate: _plateController.text,
      currentLat: 0.0,
      currentLng: 0.0,
      rating: 5.0,
      completedDeliveries: 0,
    );

    final result = await ref
        .read(fleetListProvider.notifier)
        .addDriver(newDriver);

    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Driver added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      },
      failure: (message, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        setState(() => _isSubmitting = false);
      },
    );

    if (!result.isFailure) return;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Add Driver')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Register a new driver to the fleet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.gapH24,

              AppTextField(
                controller: _userIdController,
                label: 'User ID',
                hint: 'Existing user ID (numeric)',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.badge_outlined,
                validator: (value) {
                  final trimmed = (value ?? '').trim();
                  if (trimmed.isEmpty) return 'Required';
                  final parsed = int.tryParse(trimmed);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid numeric user ID';
                  }
                  return null;
                },
              ),
              AppSpacing.gapH16,

              // Name
              AppTextField(
                controller: _nameController,
                label: 'Driver Name',
                hint: 'e.g., John Doe',
                prefixIcon: Icons.person_outline,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              AppSpacing.gapH16,

              // Phone
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'e.g., +1 555-0100',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              AppSpacing.gapH16,

              // Vehicle Type
              AppTextField(
                controller: _vehicleTypeController,
                label: 'Vehicle Type',
                hint: 'e.g., Van, Bike, Truck',
                prefixIcon: Icons.directions_car_outlined,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              AppSpacing.gapH16,

              // License Plate
              AppTextField(
                controller: _plateController,
                label: 'License Plate',
                hint: 'e.g., ABC-1234',
                prefixIcon: Icons.tag,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              AppSpacing.gapH32,

              // Submit
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                  icon: Icons.person_add_outlined,
                  label: 'Add Driver',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
