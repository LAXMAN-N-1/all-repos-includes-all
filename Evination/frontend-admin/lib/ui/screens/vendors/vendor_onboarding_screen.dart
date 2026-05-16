import 'package:flutter/material.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_textarea.dart';
import '../../widgets/common_select.dart';
import '../../widgets/common_progress.dart';

class VendorOnboardingScreen extends StatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  State<VendorOnboardingScreen> createState() => _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState extends State<VendorOnboardingScreen> {
  int currentStep = 1;
  bool isAddingVendor = false;

  final List<Map<String, dynamic>> applications = [
    {
      'id': 1,
      'name': 'Royal Events Co.',
      'category': 'Event Planning',
      'submittedAt': '2 hours ago',
      'status': 'Review',
      'completeness': 100.0,
    },
    // ...
  ];

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(5, (index) {
        int step = index + 1;
        bool isActive = step <= currentStep;
        bool isCompleted = step < currentStep;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? const Color(0xFFfdb913) : Colors.grey[200],
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text('$step', style: TextStyle(color: isActive ? Colors.white : Colors.grey)),
                ),
              ),
              if (index < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? const Color(0xFFfdb913) : Colors.grey[200],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFormStep() {
    switch (currentStep) {
      case 1: // Business Info
        return const Column(
          children: [
            CommonInput(label: 'Company Name'),
            SizedBox(height: 16),
            CommonInput(label: 'Business Type'), // Select ideally
            SizedBox(height: 16),
            CommonInput(label: 'Registration Number'),
          ],
        );
      case 2: // Contact
        return const Column(
          children: [
            CommonInput(label: 'Contact Person'),
            SizedBox(height: 16),
            CommonInput(label: 'Email'),
            SizedBox(height: 16),
            CommonInput(label: 'Phone'),
             SizedBox(height: 16),
            CommonInput(label: 'Address'),
          ],
        );
      case 3: // Services
        return const Column(
          children: [
            CommonTextarea(label: 'Services Offered', minLines: 3),
            SizedBox(height: 16),
            CommonInput(label: 'Pricing Range'),
            SizedBox(height: 16),
            CommonInput(label: 'Service Areas'),
          ],
        );
      case 4: // Documents
        return const Column(
          children: [
            CommonInput(label: 'Business License (URL or Filename)'),
            SizedBox(height: 16),
            CommonInput(label: 'Insurance Certificate'),
          ],
        );
      case 5: // Payment
        return const Column(
          children: [
            CommonInput(label: 'Bank Name'),
            SizedBox(height: 16),
            CommonInput(label: 'Account Number'),
             SizedBox(height: 16),
            CommonInput(label: 'IFSC Code'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Vendor Onboarding', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFfdb913))),
                    Text('Review and approve new applications', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                CommonButton(
                  text: isAddingVendor ? 'Cancel' : 'Add Vendor',
                  icon: isAddingVendor ? Icons.close : Icons.add,
                  onPressed: () => setState(() {
                    isAddingVendor = !isAddingVendor;
                    currentStep = 1;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (isAddingVendor) ...[
              _buildStepIndicator(),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    _buildFormStep(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentStep > 1)
                          CommonButton(text: 'Previous', variant: ButtonVariant.outline, onPressed: () => setState(() => currentStep--))
                        else
                          const SizedBox(),
                        CommonButton(
                          text: currentStep == 5 ? 'Submit' : 'Next',
                          onPressed: () {
                            if (currentStep < 5) {
                              setState(() => currentStep++);
                            } else {
                              setState(() {
                                isAddingVendor = false;
                                applications.insert(0, {
                                  'id': 99,
                                  'name': 'New Vendor Ltd', // Mock
                                  'category': 'Catering',
                                  'submittedAt': 'Just now',
                                  'status': 'Review',
                                  'completeness': 100.0,
                                });
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Pending Applications List
              const Text('Pending Applications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...applications.map((app) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(app['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text('${app['category']} • Submitted ${app['submittedAt']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          Row(
                            children: [
                              CommonButton(text: 'View', variant: ButtonVariant.secondary, onPressed: () {}),
                              const SizedBox(width: 8),
                              CommonButton(text: 'Approve', onPressed: () {}), // Green normally
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Data Completeness: ', style: TextStyle(fontSize: 12)),
                          Expanded(child: CommonProgress(value: app['completeness'] / 100)),
                          const SizedBox(width: 8),
                          Text('${app['completeness']}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
