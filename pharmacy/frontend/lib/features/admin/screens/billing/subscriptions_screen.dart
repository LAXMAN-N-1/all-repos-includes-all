import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_billing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                   Text("Active Subscriptions", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                   const SizedBox(height: 8),
                   const Text("Monitor billing cycles and plan usage across tenants.", style: TextStyle(color: Colors.white60)),
                ],
              ),
              OutlinedButton.icon(
                onPressed: (){}, 
                icon: const Icon(Icons.download), 
                label: const Text("Export CSV")
              )
            ],
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: ListView.separated(
              itemCount: mockSubscriptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final sub = mockSubscriptions[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AuraColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AuraColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      // Sub Icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AuraColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_membership, color: AuraColors.primary),
                      ),
                      const SizedBox(width: 20),
                      
                      // Details
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub.orgName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                            Text("${sub.planName} • \$${sub.price}/mo", style: const TextStyle(color: Colors.white60, fontSize: 13)),
                          ],
                        ),
                      ),
                      
                      // Usage
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Row(
                               children: [
                                 Text("Users: ${sub.usersUsed}/${sub.usersLimit}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                 const Spacer(),
                                 Text("${(sub.usersUsed/sub.usersLimit*100).toInt()}%", style: const TextStyle(color: Colors.white30, fontSize: 10)),
                               ],
                             ),
                             const SizedBox(height: 6),
                             LinearProgressIndicator(
                               value: sub.usersUsed / sub.usersLimit,
                               backgroundColor: Colors.white10,
                               color: _getUsageColor(sub.usersUsed / sub.usersLimit),
                               minHeight: 4,
                             ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 24),
                      
                      // Next Billing
                      Expanded(
                        flex: 2,
                        child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Text("Next Billing", style: TextStyle(color: Colors.white30, fontSize: 10)),
                             const SizedBox(height: 4),
                             Text(DateFormat('MMM dd, yyyy').format(sub.nextBillingDate), style: const TextStyle(color: Colors.white)),
                           ],
                        ),
                      ),
                      
                      // Status
                      _buildStatusBadge(sub.status),
                      
                      const SizedBox(width: 16),
                      IconButton(icon: const Icon(Icons.more_vert), onPressed: (){}),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case "Active": color = Colors.green; break;
      case "Past Due": color = Colors.orange; break;
      case "Canceled": color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Color _getUsageColor(double usage) {
    if (usage > 0.9) return Colors.red;
    if (usage > 0.7) return Colors.orange;
    return Colors.blue;
  }
}
