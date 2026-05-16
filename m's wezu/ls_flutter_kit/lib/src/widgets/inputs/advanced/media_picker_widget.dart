import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Reusable wrapper for picking media using the image_picker package.
///
/// Features:
/// - Inline trigger button (customizable)
/// - Bottom sheet prompt for Camera vs Gallery
/// - Built-in fallback displays and selected image preview
class MediaPickerWidget extends StatefulWidget {
  final void Function(File selectedImage) onImageSelected;
  final Widget? placeholder;
  final double width;
  final double height;
  final double borderRadius;
  final bool showCameraOption;

  const MediaPickerWidget({
    super.key,
    required this.onImageSelected,
    this.placeholder,
    this.width = double.infinity,
    this.height = 160,
    this.borderRadius = 12,
    this.showCameraOption = true,
  });

  @override
  State<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends State<MediaPickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.of(context).pop(); // Close the modal
    setState(() => _isLoading = true);
    
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        final f = File(image.path);
        setState(() => _selectedFile = f);
        widget.onImageSelected(f);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Attach Image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (widget.showCameraOption)
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: const Text('Take a photo'),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _showPickerModal,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: theme.dividerColor, style: BorderStyle.dash),
          image: _selectedFile != null
              ? DecorationImage(image: FileImage(_selectedFile!), fit: BoxFit.cover)
              : null,
        ),
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _selectedFile != null
                ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: _showPickerModal,
                        ),
                      ),
                    ),
                  )
                : widget.placeholder ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 40, color: theme.colorScheme.outline),
                        const SizedBox(height: 8),
                        Text('Tap here to select an image', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
      ),
    );
  }
}
