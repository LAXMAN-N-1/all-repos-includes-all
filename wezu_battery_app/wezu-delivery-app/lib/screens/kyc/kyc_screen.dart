import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wezu_delivery_app/widgets/vehicle_type_selector.dart';
import 'kyc_view_model.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KycViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Partner Registration')),
        body: Consumer<KycViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Expanded(
                  child: Stepper(
                    type: StepperType.horizontal,
                    currentStep: viewModel.currentStep,
                    onStepContinue: () async {
                      if (viewModel.currentStep < 2) {
                        viewModel.nextStep();
                      } else {
                        // Last Step - Submit
                        final success = await viewModel.submitKyc();
                        if (success && context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/dashboard',
                            (route) => false,
                          );
                        }
                      }
                    },
                    onStepCancel: viewModel.previousStep,
                    controlsBuilder: (context, details) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: details.onStepContinue,
                                child: Text(
                                  viewModel.currentStep == 2
                                      ? 'Submit'
                                      : 'Next',
                                ),
                              ),
                            ),
                            if (viewModel.currentStep > 0) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: details.onStepCancel,
                                  child: const Text('Back'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                    steps: [
                      // Step 1: Personal Info
                      Step(
                        title: const Text('Personal'),
                        content: Column(
                          children: [
                            TextFormField(
                              initialValue: viewModel.fullName,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setFullName,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: viewModel.email,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: viewModel.address,
                              decoration: const InputDecoration(
                                labelText: 'Address',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setAddress,
                            ),
                          ],
                        ),
                        isActive: viewModel.currentStep >= 0,
                        state: viewModel.currentStep > 0
                            ? StepState.complete
                            : StepState.indexed,
                      ),

                      // Step 2: Vehicle Info
                      Step(
                        title: const Text('Vehicle'),
                        content: Column(
                          children: [
                            VehicleTypeSelector(
                              selectedType: viewModel.vehicleType,
                              onSelected: viewModel.setVehicleType,
                            ),
                            const SizedBox(height: 18),

                            TextFormField(
                              initialValue: viewModel.vehicleModel,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Model',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setVehicleModel,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: viewModel.vehicleYear,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Year',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: viewModel.setVehicleYear,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: viewModel.vehicleNumber,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Number',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setVehicleNumber,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: viewModel.vehicleColor,
                              decoration: const InputDecoration(
                                labelText: 'Vehicle Color',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onChanged: viewModel.setVehicleColor,
                            ),
                          ],
                        ),
                        isActive: viewModel.currentStep >= 1,
                        state: viewModel.currentStep > 1
                            ? StepState.complete
                            : StepState.indexed,
                      ),

                      // Step 3: Documents
                      Step(
                        title: const Text('Docs'),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDocUploader(
                              context,
                              'Driving License',
                              viewModel.drivingLicense,
                              viewModel.pickDrivingLicense,
                              viewModel.removeDrivingLicense,
                            ),
                            const SizedBox(height: 16),
                            _buildDocUploader(
                              context,
                              'Vehicle Insurance',
                              viewModel.vehicleInsurance,
                              viewModel.pickVehicleInsurance,
                              viewModel.removeVehicleInsurance,
                            ),
                          ],
                        ),
                        isActive: viewModel.currentStep >= 2,
                      ),
                    ],
                  ),
                ),
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocUploader(
    BuildContext context,
    String label,
    XFile? file,
    VoidCallback onPick,
    VoidCallback onRemove,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (file != null)
          ListTile(
            leading: const Icon(Icons.check_circle, color: Colors.green),
            title: Text(file.name),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onRemove,
            ),
            contentPadding: EdgeInsets.zero,
          )
        else
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
          ),
      ],
    );
  }
}
