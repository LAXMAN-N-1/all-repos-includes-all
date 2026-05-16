import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../logic/providers/bid_provider.dart';
import '../../data/models/bid_model.dart';
import '../../theme/app_theme.dart';

class AssignedVendorScreen extends ConsumerStatefulWidget {
  final int bidId;
  const AssignedVendorScreen({super.key, required this.bidId});

  @override
  ConsumerState<AssignedVendorScreen> createState() => _AssignedVendorScreenState();
}

class _AssignedVendorScreenState extends ConsumerState<AssignedVendorScreen> {
  @override
  Widget build(BuildContext context) {
    // We use getBidDetails from provider which fetches fresh data
    final bidAsync = ref.watch(bidDetailProvider(widget.bidId));

    return bidAsync.when(
      data: (bid) => _buildContent(context, bid),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildContent(BuildContext context, Bid bid) {
    final currencyFmt = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          TextButton.icon(
            onPressed: () => context.go('/bids'), // Assuming /bids is correct path for dashboard
            icon: const Icon(Icons.arrow_back, size: 20),
            label: const Text('Back to Dashboard'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
          ),
          const SizedBox(height: 24),

          // Success Header
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]), // Green gradient
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Vendor Assigned Successfully!', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${bid.vendorName ?? "Vendor"} has been assigned to ${bid.eventName ?? "Event"}', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {}, // View Details Logic
                  icon: const Icon(Icons.visibility, size: 20),
                  label: const Text('View Event Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (bid.eventId != null) {
                      context.push('/admin/bidding/customer-view/${bid.eventId}');
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event ID not found')));
                    }
                  },
                  icon: const Icon(Icons.people, size: 20, color: Colors.white),
                  label: const Text('View Customer View', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B), // Amber/Orange
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Main Content Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Vendor Details)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Vendor Profile Card
                    Container(
                      decoration: AppTheme.cardDecoration,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Assigned Vendor', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Complete vendor information and contact details', style: TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(color: const Color(0xFFFEF9E7), borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.emoji_events, color: Color(0xFFFDB913), size: 32),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(bid.vendorName ?? 'Unknown', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 18, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(bid.vendorRating?.toString() ?? 'N/A', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            Text('(${bid.completedEvents ?? 0} projects completed)', style: TextStyle(color: Colors.grey[500])),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 2,
                                  childAspectRatio: 3,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    _infoBox('Experience', bid.vendorExperience ?? 'N/A'),
                                    _infoBox('Team Size', '${bid.vendorTeamSize ?? "N/A"} members'),
                                    _infoBox('Assigned Date', DateFormat.yMMMd().format(bid.submittedAt ?? DateTime.now())), // Or assignedAt if available
                                    _infoBox('Location', bid.vendorLocation ?? 'N/A'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contact Info
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Contact Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          _contactRow(Icons.phone, 'Phone Number', bid.vendorPhone ?? 'N/A', Colors.blue),
                          const SizedBox(height: 16),
                          _contactRow(Icons.email, 'Email Address', bid.vendorEmail ?? 'N/A', Colors.green),
                          const SizedBox(height: 16),
                          _contactRow(Icons.location_on, 'Location', bid.vendorLocation ?? 'N/A', Colors.amber),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Certifications
                    _tagSection('Certifications & Credentials', Icons.verified_user, bid.vendorCertifications ?? [], Colors.green),
                    const SizedBox(height: 24),
                    
                    // Specializations
                    _tagSection('Specializations', Icons.workspace_premium, bid.vendorSpecializations ?? [], Colors.amber, isAmber: true),
                    const SizedBox(height: 24),
                     
                     // Notes
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(children: [Icon(Icons.description, color: Color(0xFFFDB913)), SizedBox(width: 8), Text('Additional Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                           const SizedBox(height: 16),
                           Text(bid.vendorNotes ?? 'No additional notes.', style: TextStyle(color: Colors.grey[600], height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right Column (Summary)
              Expanded(
                flex: 1,
                child: Column(
                   children: [
                     // Bid Summary
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: AppTheme.cardDecoration,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('Bid Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 16),
                           Container(
                             padding: const EdgeInsets.all(16),
                             width: double.infinity,
                             decoration: BoxDecoration(
                               gradient: const LinearGradient(colors: [Color(0xFFFDB913), Color(0xFFE5A711)]),
                               borderRadius: BorderRadius.circular(12),
                             ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text('Bid Amount', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                 Text(currencyFmt.format(bid.amount), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                           const SizedBox(height: 16),
                           Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue[100]!), borderRadius: BorderRadius.circular(12)),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Row(children: [Icon(Icons.access_time, size: 16, color: Colors.blue[700]), SizedBox(width: 8), Text('Timeline', style: TextStyle(color: Colors.grey[600], fontSize: 13))]),
                                 const SizedBox(height: 4),
                                 Text('${bid.timelineDays ?? "N/A"} days', style: TextStyle(color: Colors.blue[700], fontSize: 20, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),

                     // Event Details
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: AppTheme.cardDecoration,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 16),
                           Text('Event Name', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                           Text(bid.eventName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           const SizedBox(height: 12),
                           _eventDetailRow(Icons.calendar_today, 'Event Date', bid.eventDate != null ? DateFormat.yMMMd().format(bid.eventDate!) : 'N/A'),
                           const SizedBox(height: 12),
                           _eventDetailRow(Icons.location_on, 'Venue', bid.eventVenue ?? 'N/A'),
                           const SizedBox(height: 4),
                           Padding(padding: const EdgeInsets.only(left: 28), child: Text(bid.eventLocation ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12))),
                           const SizedBox(height: 12),
                           _eventDetailRow(Icons.people, 'Expected Guests', '${bid.eventGuests ?? 0}'),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),

                     // Documents
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: AppTheme.cardDecoration,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           const Text('Documents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                           const SizedBox(height: 16),
                           ...(bid.vendorDocuments ?? []).map((doc) => Padding(
                             padding: const EdgeInsets.only(bottom: 8.0),
                             child: Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(color: Colors.blue[50], border: Border.all(color: Colors.blue[100]!), borderRadius: BorderRadius.circular(12)),
                               child: Row(
                                 children: [
                                   Icon(Icons.description, color: Colors.blue[700], size: 20),
                                   const SizedBox(width: 12),
                                   Expanded(child: Text(doc, style: TextStyle(color: Colors.blue[800], fontSize: 13))),
                                 ],
                               ),
                             ),
                           )),
                         ],
                       ),
                     ),
                     const SizedBox(height: 24),
                     
                     // Status Badge
                     Container(
                       padding: const EdgeInsets.all(24),
                       decoration: BoxDecoration(
                         gradient: LinearGradient(colors: [Colors.green[50]!, Colors.green[100]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
                         border: Border.all(color: Colors.green[300]!),
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(children: [Icon(Icons.check_circle, color: Colors.green[700], size: 28), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Status', style: TextStyle(color: Colors.green[700], fontSize: 13)), Text('Vendor Assigned', style: TextStyle(color: Colors.green[800], fontSize: 18, fontWeight: FontWeight.bold))])]),
                           const SizedBox(height: 12),
                           Text('This vendor has been successfully assigned to the event. The customer will be notified.', style: TextStyle(color: Colors.green[800], fontSize: 13)),
                         ],
                       ),
                     ),
                   ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color[50], border: Border.all(color: color[100]!), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color[100], borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color[700], size: 20)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 16))]),
        ],
      ),
    );
  }
  
  Widget _tagSection(String title, IconData icon, List<String> tags, MaterialColor color, {bool isAmber = false}) {
     return Container(
       padding: const EdgeInsets.all(24),
       decoration: AppTheme.cardDecoration,
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Row(children: [Icon(icon, color: const Color(0xFFFDB913)), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
           const SizedBox(height: 16),
           Wrap(
             spacing: 8,
             runSpacing: 8,
             children: tags.map((tag) => Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
               decoration: BoxDecoration(
                 color: isAmber ? const Color(0xFFFEF9E7) : color[50],
                 border: Border.all(color: isAmber ? const Color(0xFFFDB913).withOpacity(0.2) : color[100]!),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: Row(mainAxisSize: MainAxisSize.min, children: [if (!isAmber) ...[Icon(Icons.check_circle, size: 14, color: color[700]), SizedBox(width: 8)], Text(tag, style: TextStyle(color: isAmber ? const Color(0xFFFDB913) : color[700], fontWeight: FontWeight.w500))]),
             )).toList(),
           ),
         ],
       ),
     );
  }

  Widget _eventDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFDB913)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.w500))]),
      ],
    );
  }
}

// Helper Provider for fetching single bid details with caching handled by Riverpod
final bidDetailProvider = FutureProvider.family<Bid, int>((ref, id) async {
  final bidsNotifier = ref.watch(bidsProvider.notifier);
  return bidsNotifier.getBidDetails(id);
});
