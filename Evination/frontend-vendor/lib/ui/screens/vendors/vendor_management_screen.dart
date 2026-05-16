import 'package:flutter/material.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_select.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_table.dart';
import '../../widgets/common_sheet.dart';
import '../../widgets/common_toggle.dart';

class VendorManagementScreen extends StatefulWidget {
  const VendorManagementScreen({super.key});

  @override
  State<VendorManagementScreen> createState() => _VendorManagementScreenState();
}

class _VendorManagementScreenState extends State<VendorManagementScreen> {
  final List<Map<String, dynamic>> vendors = [
    {
      'id': 1,
      'name': 'Elegant Caterers Inc.',
      'contactNumber': '+91 98765 43210',
      'email': 'contact@elegantcaterers.com',
      'category': 'Catering',
      'status': 'Active',
      'address': 'Mumbai, Maharashtra',
      'joiningDate': 'Jan 15, 2023',
      'rating': 4.8,
      'totalEvents': 245,
      'documents': ['GST Certificate', 'Food License', 'PAN Card'],
    },
     // ... more vendors
  ];

  String searchTerm = '';
  String filterCategory = 'All';

  void _showAddEditModal({Map<String, dynamic>? vendor}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vendor == null ? 'Add New Vendor' : 'Edit Vendor',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFfdb913)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 24),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(child: CommonInput(label: 'Vendor Name', placeholder: 'Enter name')),
                          const SizedBox(width: 16),
                          const Expanded(child: CommonInput(label: 'Email', placeholder: 'Enter email')),
                        ],
                      ),
                      const SizedBox(height: 16),
                       Row(
                        children: [
                          const Expanded(child: CommonInput(label: 'Mobile', placeholder: '+91...')),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CommonSelect(
                              label: 'Category',
                              items: ['Catering', 'Photography'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              value: null, 
                              onChanged: (_) {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const CommonInput(label: 'Address', placeholder: 'Enter address'),
                      const SizedBox(height: 16),
                      const Text('Upload Documents', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!, style: BorderStyle.none), // Simplified
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Click to upload or drag and drop'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vendor Status', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text('Enable or disable vendor', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          Switch.adaptive(value: true, onChanged: (_) {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                   CommonButton(text: 'Cancel', variant: ButtonVariant.outline, onPressed: () => Navigator.pop(context)),
                   const SizedBox(width: 16),
                   CommonButton(text: 'Save Vendor', onPressed: () => Navigator.pop(context)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDrawer(Map<String, dynamic> vendor) {
    // Assuming CommonSheet.show requires context and named args
    CommonSheet.show(
      context,
      title: 'Vendor Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFfdb913),
              child: Text(vendor['name'][0], style: const TextStyle(fontSize: 32, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text(vendor['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          Center(child: Text(vendor['category'], style: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 32),
          _buildDetailRow(Icons.phone, vendor['contactNumber']),
          _buildDetailRow(Icons.email, vendor['email']),
          _buildDetailRow(Icons.location_on, vendor['address']),
          const SizedBox(height: 32),
          const Text('Performance', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildMiniStat('Rating', '${vendor['rating']}'),
              const SizedBox(width: 16),
              _buildMiniStat('Events', '${vendor['totalEvents']}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientShaderCallback = (Rect bounds) => const LinearGradient(colors: [Color(0xFFfdb913), Color(0xFFe5a711)]).createShader(bounds);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: gradientShaderCallback,
                      child: const Text('Vendor Management', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    Text('Manage all vendors and their information', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                CommonButton(text: 'Add Vendor', icon: Icons.add, onPressed: () => _showAddEditModal()),
              ],
            ),
            const SizedBox(height: 24),
            // Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(child: CommonInput(placeholder: 'Search vendors...', prefixIcon: const Icon(Icons.search))),
                  const SizedBox(width: 16),
                   SizedBox(width: 200, child: CommonSelect(items: const [], value: null, onChanged: (_){}, placeholder: 'All Categories')),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Table
            Expanded(
              child: CommonTable(
                headers: [
                  CommonTableHeader(label: 'Vendor Name'),
                  CommonTableHeader(label: 'Contact'),
                  CommonTableHeader(label: 'Category'),
                  CommonTableHeader(label: 'Status'),
                  CommonTableHeader(label: 'Actions'),
                ],
                rows: vendors.map((vendor) {
                  return [
                     Row(
                      children: [
                        CircleAvatar(backgroundColor: const Color(0xFFfdb913), radius: 16, child: Text(vendor['name'][0], style: const TextStyle(color: Colors.white, fontSize: 12))),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(vendor['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(vendor['address'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ]),
                      ],
                    ),
                    Text(vendor['contactNumber']),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Text(vendor['category'], style: const TextStyle(fontSize: 12)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(12)),
                      child: Text(vendor['status'], style: TextStyle(color: Colors.green[800], fontSize: 12)),
                    ),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () => _showDetailsDrawer(vendor)),
                        IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _showAddEditModal(vendor: vendor)),
                        IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () {}),
                      ],
                    ),
                  ];
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
