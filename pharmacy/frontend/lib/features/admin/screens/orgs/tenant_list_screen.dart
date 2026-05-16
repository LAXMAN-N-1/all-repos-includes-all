import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/admin/screens/orgs/tenant_detail_screen.dart';
import 'package:frontend/features/admin/screens/orgs/onboarding_screen.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({Key? key}) : super(key: key);

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  List<dynamic> _tenants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTenants();
  }

  Future<void> _fetchTenants() async {
    try {
      final orgs = await Provider.of<AdminService>(context, listen: false).getOrganizations();
      if (mounted) {
        setState(() {
          _tenants = orgs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Screen Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AuraColors.glassBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Organizations",
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manage your multi-tenant ecosystem",
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingWizardScreen())
                    );
                    if (result == true) {
                      _fetchTenants(); // Refresh list after onboarding
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Organization"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuraColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Filters Bar (Placeholder)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip("All Status", true),
                const SizedBox(width: 12),
                _buildFilterChip("Active", false),
                const SizedBox(width: 12),
                _buildFilterChip("Trial", false),
                const SizedBox(width: 12),
                _buildFilterChip("Suspended", false),
                const Spacer(),
                IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
                IconButton(icon: const Icon(Icons.download), onPressed: () {}),
              ],
            ),
          ),

          // Data Grid
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
              : _tenants.isEmpty 
                  ? const Center(child: Text("No organizations found.", style: TextStyle(color: Colors.white30)))
                  : SingleChildScrollView(
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: AuraColors.glassBorder),
                        child: DataTable(
                          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
                          dataTextStyle: const TextStyle(color: Colors.white),
                          columnSpacing: 24,
                          horizontalMargin: 24,
                          columns: const [
                            DataColumn(label: Text("Organization")),
                            DataColumn(label: Text("Address")),
                            DataColumn(label: Text("Tax ID")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Actions")),
                          ],
                          rows: _tenants.map((tenant) => DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AuraColors.surface,
                                      child: Text((tenant['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(tenant['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                )
                              ),
                              DataCell(Text(tenant['address'] ?? '-', style: const TextStyle(fontSize: 12))),
                              DataCell(Text(tenant['tax_id'] ?? '-', style: const TextStyle(fontSize: 12))),
                              DataCell(_buildStatusBadge(tenant['is_active'] == true ? 'Active' : 'Inactive')),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 18),
                                      onPressed: () {
                                        // TODO: Pass full tenant object or fetch detail
                                        // Navigator.push(context, MaterialPageRoute(builder: (_) => TenantDetailScreen(tenant: tenant)));
                                      },
                                    ),
                                    IconButton(icon: const Icon(Icons.more_vert, size: 18), onPressed: () {}),
                                  ],
                                )
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AuraColors.primary.withOpacity(0.2) : AuraColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AuraColors.primary : AuraColors.glassBorder),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AuraColors.primary : Colors.white70,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text = status.toUpperCase();
    
    switch (status.toLowerCase()) {
      case 'active': color = Colors.green; break;
      case 'trial': color = Colors.blue; break;
      case 'suspended': color = Colors.red; break;
      case 'inactive': color = Colors.grey; break;
      default: color = Colors.orange; break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
  
  Widget _buildPlanBadge(dynamic planName) {
    String name = planName?.toString() ?? 'UNKNOWN';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
         border: Border.all(color: Colors.white24),
         borderRadius: BorderRadius.circular(4),
      ),
      child: Text(name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white70)),
    );
  }
}
