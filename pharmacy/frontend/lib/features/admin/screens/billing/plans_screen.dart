import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/admin_service.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/features/admin/screens/billing/create_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final plans = await Provider.of<AdminService>(context, listen: false).getPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load plans: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                    Text("Subscription Plans", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Manage pricing tiers and feature sets", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const CreatePlanScreen())
                    );
                    if (result == true) {
                      _fetchPlans(); // Refresh list after creation
                    }
                  }, 
                  icon: const Icon(Icons.add), 
                  label: const Text("Create New Plan"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Plans Grid
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
                : _plans.isEmpty 
                    ? const Center(child: Text("No plans defined yet.", style: TextStyle(color: Colors.white30)))
                    : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          return _buildPlanCard(_plans[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    final features = List<String>.from(plan['included_modules'] ?? []);
    final isEnterprise = plan['code'] == 'ENTERPRISE';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AuraColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan['name'] ?? 'Plan', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              if (isEnterprise)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AuraColors.secondary.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: const Text("TOP TIER", style: TextStyle(fontSize: 10, color: AuraColors.secondary, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("\$${plan['monthly_price']}", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: AuraColors.primary)),
              const Padding(
                padding: EdgeInsets.only(bottom: 6.0, left: 4),
                child: Text("/ month", style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
           Text("\$${plan['yearly_price']} / year", style: const TextStyle(color: Colors.white30, fontSize: 12)),
          
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: features.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AuraColors.success, size: 16),
                    const SizedBox(width: 12),
                    Expanded(child: Text(features[i], style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              child: const Text("Edit Plan"),
            ),
          ),
        ],
      ),
    );
  }
}
