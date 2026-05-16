import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class TenantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tenant; // Changed from custom Tenant type to Map
  const TenantDetailScreen({Key? key, required this.tenant}) : super(key: key);

  @override
  State<TenantDetailScreen> createState() => _TenantDetailScreenState();
}

class _TenantDetailScreenState extends State<TenantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingAction = false;
  late Map<String, dynamic> _currentTenant;

  @override
  void initState() {
    super.initState();
    _currentTenant = widget.tenant;
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleSuspend() async {
    setState(() => _isLoadingAction = true);
    final service = Provider.of<AdminService>(context, listen: false);
    final orgId = _currentTenant['id'];
    final isActive = _currentTenant['is_active'] == true;

    try {
      if (isActive) {
        await service.suspendOrganization(orgId);
      } else {
        await service.reactivateOrganization(orgId);
      }
      
      setState(() {
        _currentTenant['is_active'] = !isActive;
        _isLoadingAction = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Organization ${isActive ? 'suspended' : 'reactivated'} successfully"))
      );
    } catch (e) {
      setState(() => _isLoadingAction = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _currentTenant['is_active'] == true;
    final name = _currentTenant['name'] ?? 'Unknown';

    return Container(
      child: Column(
        children: [
          // Header / Breadcrumb
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AuraColors.glassBorder)),
              color: AuraColors.surface.withOpacity(0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context, true), // Return true to refresh list
                      child: const Text("Organizations", style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ),
                    const Icon(Icons.chevron_right, size: 16, color: Colors.white30),
                    Text(name, style: const TextStyle(color: AuraColors.primary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AuraColors.primary,
                          child: Text(name[0].toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text("ID: ${_currentTenant['id']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(width: 16),
                        _buildStatusBadge(isActive),
                      ],
                    ),
                    Row(
                      children: [
                         OutlinedButton.icon(
                          onPressed: _isLoadingAction ? null : _toggleSuspend,
                          icon: Icon(isActive ? Icons.block : Icons.check_circle, size: 16),
                          label: _isLoadingAction 
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)) 
                              : Text(isActive ? "Suspend" : "Activate"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isActive ? Colors.redAccent : Colors.greenAccent
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit Details"),
                          style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AuraColors.primary,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: AuraColors.primary,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: "Overview"),
                    Tab(text: "Users & Roles"),
                    Tab(text: "Billing & Invoices"),
                    Tab(text: "Usage Stats"),
                    Tab(text: "Support History"),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                const Center(child: Text("Users - Coming Soon", style: TextStyle(color: Colors.white))),
                const Center(child: Text("Billing - Coming Soon", style: TextStyle(color: Colors.white))),
                const Center(child: Text("Usage - Coming Soon", style: TextStyle(color: Colors.white))),
                const Center(child: Text("Support - Coming Soon", style: TextStyle(color: Colors.white))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Overview Tab ---
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           // Stats Row
           Row(
             children: [
               Expanded(child: _buildInfoCard("Total Users", "5", Icons.people, Colors.blue)), // Mock count for now
               const SizedBox(width: 20),
               Expanded(child: _buildInfoCard("Monthly Revenue", "\$99", Icons.attach_money, Colors.green)),
               const SizedBox(width: 20),
               Expanded(child: _buildInfoCard("Current Plan", "BASIC", Icons.star, Colors.purple)),
             ],
           ),
           const SizedBox(height: 24),
           
           Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Contact Info
               Expanded(
                 flex: 2,
                 child: Container(
                   padding: const EdgeInsets.all(24),
                   decoration: BoxDecoration(
                     color: AuraColors.surface,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: AuraColors.glassBorder),
                   ),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text("Contact Information", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                       const SizedBox(height: 16),
                       _buildLabelValue("Tax ID", _currentTenant['tax_id'] ?? '-'),
                       const Divider(color: Colors.white12),
                       _buildLabelValue("Address", _currentTenant['address'] ?? '-'),
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(width: 24),
               
               // Activity Timeline (Static)
               Expanded(
                 flex: 3,
                 child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Recent Activity", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        _buildTimelineItem("Subscription created", "Just now", Colors.green),
                        _buildTimelineItem("Admin user added", "Just now", Colors.blue),
                      ],
                    ),
                 ),
               ),
             ],
           )
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white70)),
                Text(time, style: const TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
  
  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.white54))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: (isActive ? Colors.green : Colors.red).withOpacity(0.5)),
      ),
      child: Text(
        isActive ? "ACTIVE" : "SUSPENDED",
        style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
