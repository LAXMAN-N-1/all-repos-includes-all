import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:admin_panel/theme/app_theme.dart'; // Added theme import if needed
import 'package:admin_panel/data/models/vendor/vendor_admin_model.dart';
import 'package:admin_panel/logic/providers/vendor_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VendorApprovalScreen extends ConsumerStatefulWidget {
  final int vendorId;
  final AdminVendorModel? vendorCache; // Passed from list

  const VendorApprovalScreen({super.key, required this.vendorId, this.vendorCache});

  @override
  ConsumerState<VendorApprovalScreen> createState() => _VendorApprovalScreenState();
}

class _VendorApprovalScreenState extends ConsumerState<VendorApprovalScreen> {
  late AdminVendorModel? vendor;

  @override
  void initState() {
    super.initState();
    vendor = widget.vendorCache;
    // ideally fetch fresh
  }

  @override
  Widget build(BuildContext context) {
    if (vendor == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text("Approve ${vendor!.displayName}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Details", [
              _buildRow("Email", vendor!.email),
              _buildRow("Phone", vendor!.phone),
              _buildRow("City", vendor!.city),
              _buildRow("PAN", vendor!.panNumber),
              _buildRow("GST", vendor!.gstNumber),
            ]),
            
            const SizedBox(height: 24),
            const Text("Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (vendor!.documents != null)
              ...vendor!.documents!.map((doc) => Card(
                child: ListTile(
                  leading: const Icon(Icons.file_present),
                  title: Text(doc.documentType),
                  subtitle: Text("${doc.documentNumber ?? ''} - ${doc.verificationStatus}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: "View File",
                        onPressed: () async {
                           // launchUrl(Uri.parse(doc.fileUrl));
                           print("Opening: ${doc.fileUrl}");
                        },
                      ),
                      if (doc.verificationStatus == 'PENDING') ...[
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: "Verify",
                          onPressed: () async {
                            await ref.read(vendorProvider.notifier).verifyDocument(vendor!.id, doc.id, "VERIFIED");
                            setState(() {
                               // simple refresh hack, ideal is reload from server
                               // doc.verificationStatus = "VERIFIED"; 
                            });
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Verified")));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: "Reject",
                          onPressed: () async {
                             // Dialog for reason
                             await ref.read(vendorProvider.notifier).verifyDocument(vendor!.id, doc.id, "REJECTED");
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Rejected")));
                          },
                        ),
                      ]
                    ],
                  ),
                ),
              )).toList(),
              
             const SizedBox(height: 40),
             Row(
               children: [
                 Expanded(
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                     onPressed: () {
                       // Reject logic
                     }, 
                     child: const Text("Reject Application"),
                   ),
                 ),
                 const SizedBox(width: 24),
                 Expanded(
                   child: ElevatedButton(
                     style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                     onPressed: () async {
                        final success = await ref.read(vendorProvider.notifier).approveVendor(vendor!.id);
                        if (success && mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vendor Approved Successfully")));
                        }
                     }, 
                     child: const Text("Approve & Activate Vendor"),
                   ),
                 ),
               ],
             )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        )
      ],
    );
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value ?? "-", style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
