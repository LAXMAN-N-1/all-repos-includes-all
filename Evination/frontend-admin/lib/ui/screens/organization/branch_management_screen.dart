import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/providers/branch_provider.dart';
import '../../../data/models/branch_model.dart';
import '../../../theme/app_theme.dart';

class BranchManagementScreen extends ConsumerStatefulWidget {
  const BranchManagementScreen({super.key});

  @override
  ConsumerState<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends ConsumerState<BranchManagementScreen> {
  int? _openMenuId;

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(branchesProvider);

    return Scaffold(
      body: branchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (branches) {
          final totalBranches = branches.length;
          final totalEmployees = branches.fold(0, (sum, b) => sum + (b.employeesCount));
          final activeLocations = branches.where((b) => b.isActive).length;
          final countries = branches.map((b) => b.country).toSet().length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFDB913), Color(0xFFE5A711)],
                          ).createShader(bounds),
                          child: const Text('Branch Management', style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white
                          )),
                        ),
                        const SizedBox(height: 8),
                        Text("Manage your organization's branches and locations", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/admin/organization/branches/create'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Branch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDB913),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Stats Grid
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.5,
                  children: [
                    _StatCard('Total Branches', '$totalBranches'),
                    _StatCard('Total Employees', '$totalEmployees'),
                    _StatCard('Active Locations', '$activeLocations'),
                    _StatCard('Countries', '$countries'),
                  ],
                ),
                const SizedBox(height: 32),

                // Branches List
                if (branches.isEmpty)
                   const Center(child: Text('No branches found. Add one!'))
                else
                   GridView.builder(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                       crossAxisCount: 2,
                       crossAxisSpacing: 24,
                       mainAxisSpacing: 24,
                       childAspectRatio: 1.4, 
                     ),
                     itemCount: branches.length,
                     itemBuilder: (context, index) {
                       final branch = branches[index];
                       return _BranchCard(
                         branch: branch, 
                         isMenuOpen: _openMenuId == branch.id,
                         onMenuToggle: () => setState(() => _openMenuId = _openMenuId == branch.id ? null : branch.id),
                       );
                     },
                   ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: AppTheme.cardDecoration.boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 4),
          ShaderMask(
             shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]).createShader(bounds),
             child: Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  final Branch branch;
  final bool isMenuOpen;
  final VoidCallback onMenuToggle;

  const _BranchCard({required this.branch, required this.isMenuOpen, required this.onMenuToggle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: AppTheme.cardDecoration.boxShadow, // Add hover effect logic if needed
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                       Text(branch.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 4),
                       Row(children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(branch.city ?? 'Unknown', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                       ]),
                       const SizedBox(height: 4),
                       Text(branch.address ?? 'No address', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ]),
                  ),
                  IconButton(
                    onPressed: onMenuToggle, 
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(Icons.person, 'Manager: ${branch.manager?.fullName ?? "Unassigned"}'),
              const SizedBox(height: 8),
              _DetailRow(Icons.group, '${branch.employeesCount} employees'),
              const SizedBox(height: 8),
              _DetailRow(Icons.phone, branch.phone ?? '-'),
              const SizedBox(height: 8),
              _DetailRow(Icons.email, branch.email ?? '-'),
              const Spacer(),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                     decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                     child: Text(branch.isActive ? 'Active' : 'Inactive', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
                   ),
                   TextButton(onPressed: () {}, child: const Text('View Details →', style: TextStyle(color: Color(0xFFFDB913)))),
                ],
              ),
            ],
          ),
        ),
        if (isMenuOpen)
          Positioned(
            top: 40,
            right: 0,
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                border: Border.all(color: Colors.grey[200]!)
              ),
              child: Column(
                children: [
                  _MenuButton(Icons.edit, 'Edit', () {}),
                  _MenuButton(Icons.delete, 'Delete', () {}, isDestructive: true),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow(this.icon, this.text);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
       Icon(icon, size: 14, color: Colors.grey[400]),
       const SizedBox(width: 8),
       Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
    ]);
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuButton(this.icon, this.label, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
           Icon(icon, size: 16, color: isDestructive ? Colors.red : Colors.black87),
           const SizedBox(width: 8),
           Text(label, style: TextStyle(fontSize: 13, color: isDestructive ? Colors.red : Colors.black87)),
        ]),
      ),
    );
  }
}
