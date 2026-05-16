import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/theme/app_theme.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceMoController = TextEditingController();
  final _priceYrController = TextEditingController();
  final _storesController = TextEditingController(text: "1");
  final _usersController = TextEditingController(text: "5");
  final _storageController = TextEditingController(text: "1");
  final _featuresController = TextEditingController();
  
  String _selectedCode = "BASIC";
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final features = _featuresController.text.split(',').map((e) => e.trim()).toList();
      
      final data = {
        "name": _nameController.text,
        "code": _selectedCode,
        "monthly_price": double.parse(_priceMoController.text),
        "yearly_price": double.parse(_priceYrController.text),
        "max_stores": int.parse(_storesController.text),
        "max_users": int.parse(_usersController.text),
        "storage_limit_gb": int.parse(_storageController.text),
        "features": features,
      };

      await Provider.of<AdminService>(context, listen: false).createPlan(data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Plan Created Successfully")));
        Navigator.pop(context, true); // Return true to refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      appBar: AppBar(
        title: const Text("Create Subscription Plan"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AuraColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AuraColors.glassBorder),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Plan Details", style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  
                  _buildTextField("Plan Name", _nameController),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedCode,
                    dropdownColor: AuraColors.surface,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Plan Code / Type"),
                    items: ["BASIC", "PROFESSIONAL", "ENTERPRISE", "TRIAL"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCode = v!),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Monthly Price (\$)", _priceMoController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("Yearly Price (\$)", _priceYrController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Text("Limits & Quotas", style: GoogleFonts.outfit(fontSize: 18, color: Colors.white70)),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField("Max Stores", _storesController, isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("Max Users", _usersController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Storage Limit (GB)", _storageController, isNumber: true),
                  
                  const SizedBox(height: 16),
                  _buildTextField("Features (comma separated)", _featuresController, maxLines: 3),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Create Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.black12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.glassBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.glassBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.primary)),
    );
  }
}
