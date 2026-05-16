import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/kyc_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/responsive_wrapper.dart';

class KYCScreen extends ConsumerStatefulWidget {
  const KYCScreen({super.key});

  @override
  ConsumerState<KYCScreen> createState() => _KYCScreenState();
}

class _KYCScreenState extends ConsumerState<KYCScreen> {
  int _currentStep = 0;
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  String? _billPath;
  String? _videoPath;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickBill() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _billPath = image.path);
    }
  }

  Future<void> _recordVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      setState(() => _videoPath = video.path);
    }
  }

  void _submit() async {
    if (_aadhaarController.text.isEmpty || _panController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter Aadhaar and PAN numbers')));
      return;
    }
    if (_billPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a utility bill')));
      return;
    }
    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please record a video for liveness detection')));
      return;
    }

    final notifier = ref.read(kycProvider.notifier);
    
    try {
      // 1. Submit Identity
      await notifier.submitKYC(idNumber: _aadhaarController.text, idType: 'aadhaar');
      // For MVP, we might combine or call multiple times. Assuming submit handles one ID.

      // 2. Upload Documents
      await notifier.uploadDocument(_billPath!, 'utility_bill');
      await notifier.uploadDocument(_videoPath!, 'video');

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC Submitted Successfully for Review')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final kycState = ref.watch(kycProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification')),
      body: kycState.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        steps: [
          Step(
            title: const Text('Identity Verification'),
            subtitle: const Text('Aadhaar & PAN Details'),
            content: Column(
              children: [
                _buildTextField('Aadhaar Number', _aadhaarController, Icons.credit_card),
                const SizedBox(height: 16),
                _buildTextField('PAN Number', _panController, Icons.assignment_ind),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Address Proof'),
            subtitle: const Text('Utility Bills / Rent Agreement'),
            content: GestureDetector(
              onTap: _pickBill,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: _billPath != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(_billPath!), fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 48, color: AppTheme.primaryBlue),
                        SizedBox(height: 8),
                        Text('Tap to upload utility bill', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
              ),
            ),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Video KYC'),
            subtitle: const Text('Liveness Detection'),
            content: Column(
              children: [
                const Text(
                  'We need a short video of you to confirm your identity. Please ensure you are in a well-lit area.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                if (_videoPath != null)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.accentGreen),
                      SizedBox(width: 8),
                      Text('Video recorded successfully', style: TextStyle(color: AppTheme.accentGreen)),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _recordVideo,
                  icon: const Icon(Icons.videocam),
                  label: Text(_videoPath != null ? 'Re-record Video' : 'Start Video Recording'),
                ),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textMain),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
        filled: true,
        fillColor: AppTheme.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}