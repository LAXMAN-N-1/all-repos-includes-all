import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_textarea.dart';
import '../../../theme/app_theme.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../logic/providers/category_provider.dart';
import '../../../data/models/vendor_registration_model.dart';
import '../../../data/models/category_model.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  int currentStep = 1;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _companyController = TextEditingController();
  final _businessTypeController = TextEditingController();
  
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController(); // Also username
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // final _servicesController = TextEditingController(); // Replaced by _selectedCategories
  final _pricingController = TextEditingController();
  // final _areasController = TextEditingController(); // Replaced by _selectedServiceCities
  
  final _licenseController = TextEditingController();
  final _insuranceController = TextEditingController();
  
  final _bankNameController = TextEditingController();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();

  // Dynamic Selection State
  List<Category> _selectedCategories = [];
  List<String> _selectedServiceCities = [];
  
  // Hardcoded list of major Indian cities
  final List<String> _indianCities = [
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Ahmedabad', 'Chennai', 'Kolkata', 
    'Surat', 'Pune', 'Jaipur', 'Lucknow', 'Kanpur', 'Nagpur', 'Indore', 'Thane', 
    'Bhopal', 'Visakhapatnam', 'Pimpri-Chinchwad', 'Patna', 'Vadodara', 'Ghaziabad', 
    'Ludhiana', 'Agra', 'Nashik', 'Faridabad', 'Meerut', 'Rajkot', 'Kalyan-Dombivli', 
    'Vasai-Virar', 'Varanasi', 'Srinagar', 'Aurangabad', 'Dhanbad', 'Amritsar', 
    'Navi Mumbai', 'Allahabad', 'Howrah', 'Ranchi', 'Gwalior', 'Jabalpur', 
    'Coimbatore', 'Vijayawada', 'Jodhpur', 'Madurai', 'Raipur', 'Kota', 'Chandigarh', 
    'Guwahati', 'Solapur', 'Hubli-Dharwad', 'Mysore', 'Tiruchirappalli', 'Bareilly', 
    'Aligarh', 'Tiruppur', 'Gurgaon', 'Moradabad', 'Jalandhar', 'Bhubaneswar', 
    'Salem', 'Warangal', 'Mira-Bhayandar', 'Jalgaon', 'Dehradun', 'Guntur', 
    'Bhiwandi', 'Saharanpur', 'Gorakhpur', 'Bikaner', 'Amravati', 'Noida', 
    'Jamshedpur', 'Bhilai', 'Cuttack', 'Firozabad', 'Kochi', 'Nellore', 'Bhavnagar', 
    'Deoghar', 'Durgapur', 'Asansol', 'Rourkela', 'Nanded', 'Kolhapur', 'Ajmer', 
    'Akola', 'Gulbarga', 'Jamnagar', 'Ujjain', 'Loni', 'Siliguri', 'Jhansi', 
    'Ulhasnagar', 'Jammu', 'Sangli-Miraj & Kupwad', 'Mangalore', 'Erode', 'Belgaum', 
    'Ambattur', 'Tirunelveli', 'Malegaon', 'Gaya', 'Jalna', 'Udaipur', 'Maheshtala'
  ];

  @override
  void dispose() {
    _companyController.dispose();
    _businessTypeController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    // _servicesController.dispose();
    _pricingController.dispose();
    // _areasController.dispose();
    _licenseController.dispose();
    _insuranceController.dispose();
    _bankNameController.dispose();
    _accountController.dispose();
    _ifscController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix the errors in the form')));
      return;
    }
    
    if (_selectedCategories.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one service')));
       return;
    }
    
    if (_cityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select your city')));
        return;
    }

    setState(() => _isLoading = true);

    final data = VendorRegistrationModel(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      companyName: _companyController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      servicesDescription: _selectedCategories.map((e) => e.name).join(', '), // Send as CSV for now
      pricingRange: _pricingController.text.trim(),
      serviceAreas: _selectedServiceCities.join(', '), // Send as CSV
      businessLicenseUrl: _licenseController.text.trim(),
      insuranceCertUrl: _insuranceController.text.trim(),
      bankName: _bankNameController.text.trim(),
      accountNumber: _accountController.text.trim(),
      ifscCode: _ifscController.text.trim(),
    );

    try {
      await ref.read(authStateProvider.notifier).registerVendor(data);
      if (mounted) {
        // Show Success Dialog or Navigate
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text('Your application has been submitted for review. You will be able to login once an Admin approves your account.'),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.go('/login'); // Return to login
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _openCitySearchDialog(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        List<String> filteredCities = List.from(_indianCities);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select City'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                         setState(() {
                           filteredCities = _indianCities
                               .where((city) => city.toLowerCase().contains(value.toLowerCase()))
                               .toList();
                         });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredCities[index]),
                            onTap: () {
                              controller.text = filteredCities[index];
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMultiCitySearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        List<String> filteredCities = List.from(_indianCities);
        List<String> tempSelected = List.from(_selectedServiceCities);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Service Areas'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                         setState(() {
                           filteredCities = _indianCities
                               .where((city) => city.toLowerCase().contains(value.toLowerCase()))
                               .toList();
                         });
                      },
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCities.length,
                        itemBuilder: (context, index) {
                          final city = filteredCities[index];
                          final isSelected = tempSelected.contains(city);
                          return CheckboxListTile(
                            title: Text(city),
                            value: isSelected,
                            onChanged: (val) {
                              setState(() {
                                if (val == true) {
                                  tempSelected.add(city);
                                } else {
                                  tempSelected.remove(city);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    this.setState(() {
                      _selectedServiceCities = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
                  color: isActive ? AppTheme.emeraldGreen : Colors.white10,
                  border: Border.all(color: isActive ? AppTheme.emeraldGreen : Colors.white24),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text('$step', style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: FontWeight.bold)),
                ),
              ),
              if (index < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppTheme.emeraldGreen : Colors.white10,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
  
  // Widget for MultiSelect Category
  Widget _buildServiceMultiSelect() {
    final categoriesAsync = ref.watch(categoryListProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Services Offered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
             categoriesAsync.when(
               data: (categories) {
                 showDialog(
                   context: context,
                   builder: (context) {
                     List<Category> tempSelected = List.from(_selectedCategories);
                     return StatefulBuilder(builder: (context, setState) {
                       return AlertDialog(
                         title: const Text('Select Services'),
                         content: SingleChildScrollView(
                           child: ListBody(
                             children: categories.map((cat) {
                               final isSelected = tempSelected.where((c) => c.id == cat.id).isNotEmpty;
                               return CheckboxListTile(
                                 title: Text(cat.name),
                                 value: isSelected,
                                 onChanged: (val) {
                                   setState(() {
                                     if (val == true) {
                                       tempSelected.add(cat);
                                     } else {
                                       tempSelected.removeWhere((c) => c.id == cat.id);
                                     }
                                   });
                                 },
                               );
                             }).toList(),
                           ),
                         ),
                         actions: [
                           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                           TextButton(
                             onPressed: () {
                               this.setState(() {
                                 _selectedCategories = tempSelected;
                               });
                               Navigator.pop(context);
                             }, 
                             child: const Text('Done')
                           ),
                         ],
                       );
                     });
                   }
                 );
               },
               error: (e, st) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading categories: $e'))),
               loading: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading categories...'))),
             );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _selectedCategories.isEmpty 
                        ? 'Select Services' 
                        : _selectedCategories.map((e) => e.name).join(', '),
                    style: TextStyle(color: _selectedCategories.isEmpty ? Colors.grey.shade600 : Colors.black, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep() {
    switch (currentStep) {
      case 1: // Business Info
        return Column(
          children: [
             CommonInput(controller: _companyController, label: 'Company Name', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            CommonInput(controller: _businessTypeController, label: 'Business Type (e.g. Pvt Ltd, Prop.)'),
          ],
        );
      case 2: // Contact & Auth
        return Column(
          children: [
            CommonInput(controller: _contactPersonController, label: 'Contact Person Name', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            CommonInput(controller: _emailController, label: 'Email Address (Username)', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            CommonInput(
              controller: _passwordController, 
              label: 'Password',
              obscureText: true,
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null
            ),
            const SizedBox(height: 16),
            CommonInput(controller: _phoneController, label: 'Phone Number', keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            CommonInput(controller: _addressController, label: 'Business Address', validator: (v) => v!.isEmpty ? 'Required' : null),
            const SizedBox(height: 16),
            
            // City Dropdown
            InkWell(
              onTap: () => _openCitySearchDialog(_cityController),
              child: IgnorePointer(
                child: CommonInput(
                   controller: _cityController, 
                   label: 'City', 
                   suffixIcon: const Icon(Icons.arrow_drop_down),
                   validator: (v) => v!.isEmpty ? 'Required' : null
                ),
              ),
            ),
          ],
        );
      case 3: // Services
        return Column(
          children: [
            _buildServiceMultiSelect(),
            const SizedBox(height: 16),
            CommonInput(controller: _pricingController, label: 'Pricing Range'),
            const SizedBox(height: 16),
            
            // Service Areas MultiSelect
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Service Areas (Cities)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                 const SizedBox(height: 8),
                InkWell(
                   onTap: _openMultiCitySearchDialog,
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                     decoration: BoxDecoration(
                       border: Border.all(color: Colors.grey.shade400),
                       borderRadius: BorderRadius.circular(4),
                       color: Colors.white,
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Expanded(
                           child: Text(
                             _selectedServiceCities.isEmpty 
                                 ? 'Select Service Areas' 
                                 : _selectedServiceCities.join(', '),
                             style: TextStyle(color: _selectedServiceCities.isEmpty ? Colors.grey.shade600 : Colors.black, fontSize: 16),
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                         const Icon(Icons.arrow_drop_down),
                       ],
                     ),
                   ),
                ),
              ],
            ),
          ],
        );
      case 4: // Documents
        return Column(
          children: [
            const Text("Upload Documents (Provide URL for now)", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            CommonInput(controller: _licenseController, label: 'Business License URL'),
            const SizedBox(height: 16),
            CommonInput(controller: _insuranceController, label: 'Insurance Certificate URL'),
          ],
        );
      case 5: // Banking
        return Column(
          children: [
            CommonInput(controller: _bankNameController, label: 'Bank Name'),
            const SizedBox(height: 16),
            CommonInput(controller: _accountController, label: 'Account Number'),
             const SizedBox(height: 16),
            CommonInput(controller: _ifscController, label: 'IFSC Code'),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkEvergreen,
      appBar: AppBar(
        title: const Text('Vendor Registration'),
        backgroundColor: AppTheme.darkEvergreen,
        foregroundColor: Colors.white,
        elevation: 0,
       ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
             constraints: const BoxConstraints(maxWidth: 600),
             child: Form(
               key: _formKey,
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.stretch,
                 children: [
                   _buildStepIndicator(),
                   const SizedBox(height: 32),
                   Container(
                     padding: const EdgeInsets.all(24),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.05), // Glassmorphism
                       borderRadius: BorderRadius.circular(16),
                       border: Border.all(color: AppTheme.mintWhisper.withOpacity(0.1)),
                       boxShadow: [
                         BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                       ],
                     ),
                     child: _buildFormStep(),
                   ),
                   const SizedBox(height: 32),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       if (currentStep > 1)
                         Expanded(
                           child: CommonButton(
                             text: 'Previous', 
                             variant: ButtonVariant.outline, 
                             onPressed: () => setState(() => currentStep--),
                           ),
                         )
                       else
                         const Spacer(),
                       
                       const SizedBox(width: 16),
                       
                       Expanded(
                         child: CommonButton(
                           text: currentStep == 5 ? (_isLoading ? 'Submitting...' : 'Submit Application') : 'Next',
                           onPressed: _isLoading ? null : () {
                             if (currentStep < 5) {
                               if (currentStep == 1 && (_companyController.text.isEmpty || _businessTypeController.text.isEmpty)) {
                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                                 return;
                               }
                               // Basic Validation for each step could be added here
                               
                               setState(() => currentStep++);
                             } else {
                               _submit();
                             }
                           },
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
          ),
        ),
      ),
    );
  }
}
