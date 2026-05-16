import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendor_app/logic/providers/onboarding_provider.dart';
import 'package:vendor_app/ui/screens/onboarding/step_1_basic_info.dart';
import 'package:vendor_app/ui/screens/onboarding/step_2_business_details.dart';
import 'package:vendor_app/ui/screens/onboarding/step_3_documents.dart';
import 'package:vendor_app/ui/screens/onboarding/submission_success_screen.dart';

class OnboardingLayout extends ConsumerWidget {
  const OnboardingLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final controller = ref.read(onboardingProvider.notifier);

    // If already submitted or success, show success screen
    // Note: Ideally we check user status or backend response. 
    // For now, assuming step 4 is completed.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Registration'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (state.currentStep + 1) / 4,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: _buildStepLabel(context, 0, "Basic Info", state.currentStep)),
                Flexible(child: _buildStepLabel(context, 1, "Business", state.currentStep)),
                Flexible(child: _buildStepLabel(context, 2, "Documents", state.currentStep)),
                Flexible(child: _buildStepLabel(context, 3, "Review", state.currentStep)),
              ],
            ),
          ),
          const Divider(),
          
          Expanded(
            child: IndexedStack(
              index: state.currentStep,
              children: [
                Step1BasicInfo(),
                Step2BusinessDetails(),
                Step3Documents(),
                // Step4Review(), // Or banking
                Placeholder(child: Center(child: Text("Review & Submit"))), 
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(BuildContext context, int stepIndex, String label, int currentStep) {
    bool isActive = stepIndex == currentStep;
    bool isCompleted = stepIndex < currentStep;
    
    return Text(
      label,
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12,
        fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
        color: isActive ? Theme.of(context).primaryColor : (isCompleted ? Colors.green : Colors.grey),
      ),
    );
  }
}
