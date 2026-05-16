import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart'; // Add signature package
import '../../config/app_colors.dart';
import '../../config/app_spacing.dart';
import '../../config/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';

import 'providers/orders_providers.dart';

/// Screen to capture and submit proof of delivery.
/// Note: This includes simulation features (Signature Pad) normally found in a Driver App.
class ProofOfDeliveryScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ProofOfDeliveryScreen({super.key, required this.orderId});

  @override
  ConsumerState<ProofOfDeliveryScreen> createState() =>
      _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends ConsumerState<ProofOfDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _recipientController = TextEditingController(); // New: Recipient Name

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  File? _selectedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _notesController.dispose();
    _recipientController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate Image
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select a proof of delivery image.'),
        ),
      );
      return;
    }

    // Validate Signature
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please collect the recipient\'s signature.'),
        ),
      );
      return;
    }

    // Validate Name
    if (_recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the recipient\'s name.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement file upload when backend supports it.
      // For now, use a placeholder URL to unblock the flow.
      final photoUrl = 'local://${_selectedImage!.path}';
      String? signatureUrl;
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final signatureFile = File(
          '${tempDir.path}/signature_${DateTime.now().microsecondsSinceEpoch}.png',
        );
        await signatureFile.writeAsBytes(signatureBytes);
        signatureUrl = 'local://${signatureFile.path}';
      }

      final notes = [
        if (_recipientController.text.trim().isNotEmpty)
          'Received by: ${_recipientController.text.trim()}',
        if (_notesController.text.trim().isNotEmpty)
          _notesController.text.trim(),
      ].join(' | ');

      final result = await ref
          .read(orderDetailProvider(widget.orderId).notifier)
          .submitProofOfDelivery(
            imageUrl: photoUrl,
            notes: notes.isNotEmpty ? notes : null,
            signatureUrl: signatureUrl,
            recipientName: _recipientController.text.trim(),
          );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Proof of delivery submitted'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.error ?? 'Failed to submit proof of delivery',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            AppSpacing.gapH24,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            AppSpacing.gapH8,
            Text(label, style: AppTextStyles.labelMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppScaffold(
      appBar: AppBar(title: const Text('Proof of Delivery')),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: AppColors.success,
                      size: 28,
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confirm Delivery',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Order ${widget.orderId} will be marked as Delivered.',
                            style: AppTextStyles.caption.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapH24,

              // 1. Recipient Name
              AppTextField(
                controller: _recipientController,
                label: 'Recipient Name',
                hint: 'Who received the order?',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              AppSpacing.gapH24,

              // 2. Delivery Photo
              Text(
                'Delivery Photo',
                style: AppTextStyles.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              AppSpacing.gapH12,
              InkWell(
                onTap: _showImageSourceSheet,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedImage == null
                          ? AppColors.border
                          : AppColors.success,
                    ),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                            AppSpacing.gapH8,
                            Text(
                              'Tap to add photo',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              AppSpacing.gapH24,

              // 3. Signature Pad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recipient Signature',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _signatureController.clear(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
              AppSpacing.gapH8,
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signatureController,
                    height: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),

              AppSpacing.gapH24,

              // 4. Notes
              AppTextField(
                controller: _notesController,
                label: 'Delivery Notes (Optional)',
                hint: 'Any other details...',
                prefixIcon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
              AppSpacing.gapH32,

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _submit,
                  isLoading: _isSubmitting,
                  icon: Icons.check_circle_outline,
                  label: 'Submit Proof of Delivery',
                ),
              ),
              AppSpacing.gapH32, // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
