import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../profile_view_model.dart';

class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key});

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  late TextEditingController _modelController;
  late TextEditingController _plateController;
  late TextEditingController _typeController;
  late TextEditingController _colorController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final vehicle = context.read<ProfileViewModel>().user.vehicle;
    _modelController = TextEditingController(text: vehicle.model);
    _plateController = TextEditingController(text: vehicle.plateNumber);
    _typeController = TextEditingController(text: vehicle.type);
    _colorController = TextEditingController(text: vehicle.color);
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateController.dispose();
    _typeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges(ProfileViewModel viewModel) async {
    await viewModel.updateVehicle(
      model: _modelController.text,
      plateNumber: _plateController.text,
      type: _typeController.text,
      color: _colorController.text,
    );
    if (mounted) {
      _toggleEdit();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vehicle Details Updated')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final vehicle = viewModel.user.vehicle;

    if (!_isEditing) {
      if (_modelController.text != vehicle.model) {
        _modelController.text = vehicle.model;
      }
      if (_plateController.text != vehicle.plateNumber) {
        _plateController.text = vehicle.plateNumber;
      }
      if (_typeController.text != vehicle.type) {
        _typeController.text = vehicle.type;
      }
      if (_colorController.text != vehicle.color) {
        _colorController.text = vehicle.color;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF233D4C),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveChanges(viewModel);
              } else {
                _toggleEdit();
              }
            },
            tooltip: _isEditing ? 'Save' : 'Edit',
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.electric_scooter,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    'Vehicle Model',
                    _modelController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Plate Number',
                    _plateController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Vehicle Type',
                    _typeController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    'Color',
                    _colorController,
                    enabled: _isEditing,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF233D4C).withValues(alpha: 0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        filled: !enabled,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF233D4C),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
