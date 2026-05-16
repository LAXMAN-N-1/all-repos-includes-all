import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/app_colors.dart';
import '../../../../config/app_spacing.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/app_button.dart';

class DiscrepancyReportDialog extends StatefulWidget {
  final String batteryId;
  final Function(String report, String? imagePath) onReport;

  const DiscrepancyReportDialog({
    super.key,
    required this.batteryId,
    required this.onReport,
  });

  @override
  State<DiscrepancyReportDialog> createState() =>
      _DiscrepancyReportDialogState();
}

class _DiscrepancyReportDialogState extends State<DiscrepancyReportDialog> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  String? _imagePath;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report Issue', style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Battery: ${widget.batteryId}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              AppSpacing.gapH16,
              AppTextField(
                controller: _controller,
                label: 'Description',
                hint: 'e.g., Dent on side, connector broken',
                maxLines: 3,
              ),
              AppSpacing.gapH16,
              if (_imagePath != null)
                Stack(
                  children: [
                     ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imagePath!),
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePath = null),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_imagePath != null) AppSpacing.gapH16,
              AppButton(
                onPressed: _pickImage,
                variant: AppButtonVariant.outlined,
                icon: Icons.camera_alt,
                label: _imagePath == null ? 'Take Photo' : 'Retake Photo',
                size: AppButtonSize.small,
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          size: AppButtonSize.small,
        ),
         AppButton(
          label: 'Report Damage',
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onReport(_controller.text, _imagePath);
              Navigator.pop(context);
            }
          },
          size: AppButtonSize.small,
          // TODO: Consider error color variant if available
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class LocationAssignmentDialog extends StatefulWidget {
  final String batteryId;
  final String? currentLocation;
  final Function(String location) onAssign;

  const LocationAssignmentDialog({
    super.key,
    required this.batteryId,
    this.currentLocation,
    required this.onAssign,
  });

  @override
  State<LocationAssignmentDialog> createState() =>
      _LocationAssignmentDialogState();
}

class _LocationAssignmentDialogState extends State<LocationAssignmentDialog> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _controller.text = widget.currentLocation!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Location', style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Battery: ${widget.batteryId}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
               AppSpacing.gapH16,
              AppTextField(
                controller: _controller,
                label: 'Rack / Shelf',
                hint: 'e.g., A-12',
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
        ),
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
          variant: AppButtonVariant.text,
          size: AppButtonSize.small,
        ),
        AppButton(
          label: 'Assign',
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAssign(_controller.text);
              Navigator.pop(context);
            }
          },
          size: AppButtonSize.small,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
