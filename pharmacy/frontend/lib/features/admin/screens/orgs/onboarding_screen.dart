import 'package:flutter/material.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  List<dynamic> _plans = [];

  // Controllers
  final _orgNameController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _addressController = TextEditingController();
  
  int? _selectedPlanId;
  
  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final plans = await Provider.of<AdminService>(context, listen: false).getPlans();
      if (mounted) {
        setState(() => _plans = plans);
      }
    } catch (e) {
      print("Error fetching plans: $e");
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    
    final payload = {
      "org_name": _orgNameController.text,
      "tax_id": _taxIdController.text,
      "address": _addressController.text,
      "plan_id": _selectedPlanId,
      "admin_user": {
        "full_name": _adminNameController.text,
        "email": _adminEmailController.text,
        "password": _adminPassController.text
      }
    };

    try {
      await Provider.of<AdminService>(context, listen: false).onboardOrganization(payload);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Organization Created Successfully!")));
        Navigator.pop(context, true);
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
        title: const Text("New Organization Wizard"),
        backgroundColor: Colors.transparent, 
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Steps Indicator
            SizedBox(
              width: 250,
              child: Column(
                children: [
                   _buildStepIndicator(0, "Basic Info"),
                   _buildStepIndicator(1, "Subscription Plan"),
                   _buildStepIndicator(2, "Primary Admin"),
                   _buildStepIndicator(3, "Review & Create"),
                ],
              ),
            ),
            const SizedBox(width: 32),
            
            // Form Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AuraColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentStep == 0 ? "Organization Details" : 
                      _currentStep == 1 ? "Select Subscription Plan" :
                      _currentStep == 2 ? "Admin Account Setup" : "Review Details",
                      style: GoogleFonts.outfit(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    
                    Expanded(child: SingleChildScrollView(child: _buildStepContent())),
                    
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _isLoading ? null : () => setState(() => _currentStep--),
                            child: const Text("Back"),
                          ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () {
                            if (_validateStep()) {
                              if (_currentStep < 3) {
                                setState(() => _currentStep++);
                              } else {
                                _submit();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuraColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                          ),
                          child: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_currentStep == 3 ? "Create Organization" : "Next Step"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateStep() {
    if (_currentStep == 0) {
      if (_orgNameController.text.isEmpty) {
        _showError("Organization Name is required");
        return false;
      }
    } else if (_currentStep == 1) {
      if (_selectedPlanId == null) {
        _showError("Please select a subscription plan");
        return false;
      }
    } else if (_currentStep == 2) {
      if (_adminEmailController.text.isEmpty || _adminPassController.text.isEmpty) {
        _showError("Admin email and password are required");
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep == step;
    bool isCompleted = _currentStep > step;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AuraColors.primary : (isCompleted ? Colors.green : Colors.white10),
              border: isActive ? Border.all(color: Colors.white, width: 2) : null,
            ),
            alignment: Alignment.center,
            child: isCompleted 
              ? const Icon(Icons.check, size: 20, color: Colors.white)
              : Text((step+1).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Text(label, style: GoogleFonts.outfit(
            color: isActive || isCompleted ? Colors.white : Colors.white30,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 16
          )),
        ],
      ),
    );
  }
  
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          children: [
            _buildTextField("Organization Name", _orgNameController),
            const SizedBox(height: 24),
            _buildTextField("Tax ID / EIN (Optional)", _taxIdController),
            const SizedBox(height: 24),
            _buildTextField("Business Address", _addressController, maxLines: 3),
          ],
        );
      case 1:
        if (_plans.isEmpty) {
          return const Center(child: Text("No plans available. Create a plan first.", style: TextStyle(color: Colors.white60)));
        }
        return Column(
          children: _plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: RadioListTile<int>(
              value: plan['id'],
              groupValue: _selectedPlanId,
              onChanged: (val) => setState(() => _selectedPlanId = val),
              tileColor: _selectedPlanId == plan['id'] ? AuraColors.primary.withOpacity(0.1) : Colors.white10,
              activeColor: AuraColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: _selectedPlanId == plan['id'] ? AuraColors.primary : Colors.transparent)
              ),
              title: Text(plan['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text("\$${plan['monthly_price']}/mo • ${plan['max_users']} Users • ${plan['max_stores']} Stores", style: const TextStyle(color: Colors.white70)),
              secondary: plan['code'] == 'ENTERPRISE' 
                  ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(4)), child: const Text("PRO", style: TextStyle(fontSize: 10, color: Colors.white))) 
                  : null,
            ),
          )).toList(),
        );
      case 2:
        return Column(
          children: [
            const Text("This user will have full access to manage the organization.", style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 24),
             _buildTextField("Full Name", _adminNameController),
            const SizedBox(height: 24),
            _buildTextField("Email Address", _adminEmailController),
            const SizedBox(height: 24),
            _buildTextField("Temporary Password", _adminPassController, isPassword: true),
          ],
        );
      case 3:
        final selectedPlan = _plans.firstWhere((p) => p['id'] == _selectedPlanId, orElse: () => {});
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReviewRow("Organization", _orgNameController.text),
              _buildReviewRow("Tax ID", _taxIdController.text.isEmpty ? "N/A" : _taxIdController.text),
              const Divider(color: Colors.white24, height: 32),
              _buildReviewRow("Selected Plan", selectedPlan['name'] ?? 'Unknown'),
              _buildReviewRow("Price", "\$${selectedPlan['monthly_price']}/mo"),
              const Divider(color: Colors.white24, height: 32),
              _buildReviewRow("Admin User", _adminNameController.text),
              _buildReviewRow("Admin Email", _adminEmailController.text),
            ],
          ),
        );
      default:
         return Container();
    }
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AuraColors.primary)),
      ),
    );
  }
}
