import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/models/vendor/vendor_admin_model.dart';
import '../../../../logic/providers/vendor_provider.dart';

class VendorDetailScreen extends ConsumerWidget {
  final String vendorId;
  const VendorDetailScreen({super.key, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to fetch vendor details. Assuming vendorProvider has it or we fetch it.
    // For now, let's assume we can get it from the provider's list or a new details provider.
    // Simplifying: Fetch from logic or pass object.
    // Ideally: final vendor = ref.watch(vendorDetailsProvider(vendorId));
    
    // Quick fix: find in list or loading
    final vendorState = ref.watch(vendorProvider);
    final vendor = vendorState.vendors.firstWhere(
        (v) => v.id.toString() == vendorId, 
        orElse: () => AdminVendorModel(id: -1, vendorType: '', status: '', companyName: 'Loading...') // Placeholder
    );
    
    if (vendor.id == -1) {
         // Trigger fetch details if not found?
         // ref.read(vendorProvider.notifier).getVendorDetails(int.parse(vendorId));
         return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      body: DefaultTabController(
        length: 6,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, size: 20)),
                      const SizedBox(width: 8),
                      Text('Vendor Management', style: TextStyle(color: Colors.grey[600])),
                      const Text(' / ', style: TextStyle(color: Colors.grey)),
                      Text('Vendor Profile', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.primary100,
                        child: Text(vendorId.isNotEmpty ? vendorId[0] : 'V', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primary700)),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('Elegant Caterers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                                  child: Text('VERIFIED', style: TextStyle(color: Colors.green[700], fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(4)),
                                  child: Text('GOLD TIER', style: TextStyle(color: Colors.amber[700], fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('ID: #V-$vendorId • Joined: Jan 12, 2024', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildContactChip(Icons.email, 'contact@elegant.com'),
                                const SizedBox(width: 12),
                                _buildContactChip(Icons.phone, '+91 98765 43210'),
                                const SizedBox(width: 12),
                                _buildContactChip(Icons.location_on, 'Mumbai, Maharashtra'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          _buildActionButtons(context, ref, vendor),
                          const SizedBox(height: 8),
                          // Keep existing buttons if needed, or replace
                          if (vendor.status == 'active') ...[
                              ElevatedButton.icon(
                                onPressed: (){}, 
                                icon: const Icon(Icons.block, size: 16),
                                label: const Text('Suspend'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, elevation: 0),
                              ),
                              const SizedBox(height: 8),
                          ],
                          OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.edit, size: 16), label: const Text('Edit Profile')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TabBar(
                    isScrollable: true,
                    labelColor: AppTheme.primary600,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primary600,
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Business Info'),
                      Tab(text: 'Documents'),
                      Tab(text: 'Financials'),
                      Tab(text: 'Bookings'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildBusinessInfoTab(vendor),
                  _buildDocumentsTab(vendor),
                  _buildFinancialsTab(vendor),
                  const Center(child: Text('Bookings Flow - To Be Implemented')),
                  const Center(child: Text('Reviews Flow - To Be Implemented')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSectionCard('Performance Metrics', 
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildMetricItem('Total Revenue', '₹12.4L', Colors.green)),
                          Expanded(child: _buildMetricItem('Bookings', '45', Colors.blue)),
                          Expanded(child: _buildMetricItem('Avg. Rating', '4.8', Colors.amber)),
                        ],
                      ),
                    ],
                  )
                ),
                const SizedBox(height: 24),
                _buildSectionCard('Recent Activity', Container(height: 200, color: Colors.grey[50], child: const Center(child: Text('Chart Placeholder')))),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSectionCard('Verification Status', 
                  Column(
                    children: [
                      _buildCheckItem('Email Verified', true),
                      _buildCheckItem('Phone Verified', true),
                      _buildCheckItem('GSTIN Verified', true),
                      _buildCheckItem('PAN Verified', true),
                      _buildCheckItem('Bank Details', true),
                    ],
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(checked ? Icons.check_circle : Icons.cancel, color: checked ? Colors.green : Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
  Widget _buildBusinessInfoTab(AdminVendorModel vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Company Details', Column(
            children: [
              _buildRow('Company Name', vendor.companyName),
              _buildRow('Business Type', vendor.businessName), // or vendorType
              _buildRow('Vendor Type', vendor.vendorType),
              _buildRow('Description', vendor.description),
              _buildRow('Year Established', '2020'), // Placeholder or add to model
              _buildRow('Team Size', '10-50'), // Placeholder
            ],
          )),
          const SizedBox(height: 24),
          _buildSectionCard('Contact & Location', Column(
            children: [
              _buildRow('Email', vendor.email),
              _buildRow('Phone', vendor.phone),
              _buildRow('Address', vendor.address),
              _buildRow('City', vendor.city),
              _buildRow('State', vendor.state),
              _buildRow('Zip Code', vendor.zipCode),
            ],
          )),
          const SizedBox(height: 24),
          _buildSectionCard('Services Offered', 
            vendor.servicesOffered != null && vendor.servicesOffered!.isNotEmpty
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vendor.servicesOffered!.map((s) => Chip(label: Text(s.toString()))).toList(),
              )
            : const Text("No services listed", style: TextStyle(color: Colors.grey))
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialsTab(AdminVendorModel vendor) {
    final payout = vendor.payoutSetting;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard('Bank Account Details', 
            payout != null 
            ? Column(
                children: [
                  _buildRow('Account Number', payout.bankAccountNumber),
                  _buildRow('IFSC Code', payout.bankIfsc),
                  _buildRow('Bank Name', payout.bankName),
                  _buildRow('Beneficiary', payout.beneficiaryName),
                ],
              )
            : const Text("No bank details provided", style: TextStyle(color: Colors.grey))
          ),
          const SizedBox(height: 24),
          _buildSectionCard('Tax Information', Column(
            children: [
              _buildRow('GST Number', vendor.gstNumber),
              _buildRow('PAN Number', vendor.panNumber),
            ],
          )),
        ],
      ),
    );
  }
  
  Widget _buildDocumentsTab(AdminVendorModel vendor) {
      if (vendor.documents == null || vendor.documents!.isEmpty) {
          return const Center(child: Text("No documents uploaded"));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: vendor.documents!.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
            final doc = vendor.documents![index];
            return Card(
                child: ListTile(
                    leading: const Icon(Icons.description, color: AppTheme.primary500),
                    title: Text(doc.documentType),
                    subtitle: Text(doc.verificationStatus),
                    trailing: Icon(Icons.check_circle, color: doc.verificationStatus == 'VERIFIED' ? Colors.green : Colors.grey),
                ),
            );
        },
      );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, AdminVendorModel vendor) {
      if (vendor.status == 'pending' || vendor.status == 'pending_approval') {
          return Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                    // Reject Logic
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red, elevation: 0),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                   final success = await ref.read(vendorProvider.notifier).approveVendor(vendor.id);
                   if (success) {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vendor Approved")));
                       context.pop();
                   }
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, elevation: 0),
              ),
            ],
          );
      }
      return const SizedBox.shrink();
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
