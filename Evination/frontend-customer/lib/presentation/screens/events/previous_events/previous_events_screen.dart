import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class PreviousEventsScreen extends StatefulWidget {
  const PreviousEventsScreen({super.key});

  @override
  State<PreviousEventsScreen> createState() => _PreviousEventsScreenState();
}

class _PreviousEventsScreenState extends State<PreviousEventsScreen> {
  String _selectedFilter = 'All Events';

  final List<Map<String, dynamic>> _events = [
    {
      'type': 'Celebration',
      'tag': 'Wedding',
      'title': 'Wedding Reception',
      'rating': 5.0,
      'date': 'October 15, 2024',
      'location': 'Grand Palace, Mumbai',
      'guests': '500 guests',
      'vendor': 'Rajesh Kumar Catering',
      'image': 'https://images.unsplash.com/photo-1519225468359-2961d5a999fc?auto=format&fit=crop&q=80',
    },
    {
      'type': 'Celebration',
      'tag': 'Birthday',
      'title': 'Birthday Celebration',
      'rating': 4.5,
      'date': 'October 10, 2024',
      'location': 'Celebration Hall, Pune',
      'guests': '150 guests',
      'vendor': 'Elegant Decor Solutions',
      'image': 'https://images.unsplash.com/photo-1464349153735-7db50ed83c84?auto=format&fit=crop&q=80',
    },
    {
      'type': 'Solemn Event',
      'tag': 'Memorial',
      'title': 'Memorial Service',
      'rating': 5.0,
      'date': 'October 8, 2024',
      'location': 'Peace Memorial, Chennai',
      'guests': '100 guests',
      'vendor': 'Peaceful Tributes Services',
      'image': 'https://images.unsplash.com/photo-1596395353594-5220c455850e?auto=format&fit=crop&q=80',
    },
    {
      'type': 'Celebration',
      'tag': 'Corporate',
      'title': 'Corporate Conference',
      'rating': 4.8,
      'date': 'October 5, 2024',
      'location': 'Business Center, Bangalore',
      'guests': '300 guests',
      'vendor': 'Meera Event Management',
      'image': 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&q=80',
    },
    {
      'type': 'Celebration',
      'tag': 'Anniversary',
      'title': 'Anniversary Celebration',
      'rating': 5.0,
      'date': 'September 28, 2024',
      'location': 'Garden Resort, Goa',
      'guests': '80 guests',
      'vendor': 'Blissful Venue Spaces',
      'image': 'https://images.unsplash.com/photo-1530103862676-de3c9a59af57?auto=format&fit=crop&q=80',
    },
    {
      'type': 'Solemn Event',
      'tag': 'Prayer Meeting',
      'title': 'Prayer Meeting',
      'rating': 4.9,
      'date': 'September 25, 2024',
      'location': 'Community Hall, Delhi',
      'guests': '60 guests',
      'vendor': 'Divine Flowers & Arrangements',
      'image': 'https://plus.unsplash.com/premium_photo-1678122363715-e2187747738f?auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _selectedFilter == 'All Events'
        ? _events
        : _events.where((e) => e['type'] == (_selectedFilter == 'Celebrations' ? 'Celebration' : 'Solemn Event')).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Hero Section
            Container(
              color: AppColors.primaryBlack,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 60),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: AppColors.crimsonSilk,
                       borderRadius: BorderRadius.circular(16),
                     ),
                     child: const Icon(Icons.calendar_today_outlined, size: 32, color: AppColors.primaryBlack),
                   ),
                   const SizedBox(height: 24),
                  Text(
                    'Previous Events',
                    style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Explore our portfolio of successfully executed celebrations and solemn occasions',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 2. Filters & Stats Container
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
                   boxShadow: const [
                     BoxShadow(
                       color: Colors.black12,
                       blurRadius: 10,
                       offset: Offset(0, 4),
                     )
                   ]
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.filter_list, size: 20),
                            const SizedBox(width: 8),
                            Text('Filter:', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        _buildFilterChip('All Events', _events.length),
                        _buildFilterChip('Celebrations', _events.where((e) => e['type'] == 'Celebration').length),
                        _buildFilterChip('Solemn Events', _events.where((e) => e['type'] == 'Solemn Event').length),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Stats Grid - Using Wrap for responsiveness
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                          _buildStatCard(
                             icon: Icons.calendar_month,
                             value: '12',
                             label: 'Total Events',
                             color: AppColors.crimsonSilk,
                             textColor: AppColors.primaryBlack,
                           ),
                           _buildStatCard(
                             icon: Icons.people_outline,
                             value: '2,425',
                             label: 'Guests',
                             color: Colors.white,
                             textColor: AppColors.primaryBlack,
                             hasShadow: true,
                            ),
                           _buildStatCard(
                             icon: Icons.star_outline,
                             value: '4.9',
                             label: 'Rating',
                             color: Colors.white,
                             textColor: AppColors.primaryBlack,
                              hasShadow: true,
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Event Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);
                
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: filteredEvents.map((event) {
                    final cardWidth = (width - ((crossAxisCount - 1) * 24)) / crossAxisCount;
                    return _buildEventCard(event, cardWidth);
                  }).toList(),
                );
              }),
            ),

            const SizedBox(height: 60),

            // 4. Footer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.crimsonSilk, size: 40),
                  const SizedBox(height: 24),
                  Text(
                    'Create Your Own Event',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.crimsonSilk,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join thousands of satisfied customers who trusted us.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.white.withOpacity(0.9)),
                  ),
                   const SizedBox(height: 40),
                   Wrap(
                     spacing: 16,
                     runSpacing: 16,
                     alignment: WrapAlignment.center,
                     children: [
                       ElevatedButton(
                         onPressed: () => context.go('/book/General'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.crimsonSilk,
                           foregroundColor: AppColors.primaryBlack,
                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: const Text('Start Planning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       ),
                       OutlinedButton(
                         onPressed: () => context.push('/verified_vendors'),
                         style: OutlinedButton.styleFrom(
                           foregroundColor: AppColors.crimsonSilk,
                           side: const BorderSide(color: AppColors.crimsonSilk, width: 2),
                           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                         child: const Text('Browse Vendors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       ),
                     ],
                   ),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _selectedFilter == label;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.crimsonSilk : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label, required Color color, required Color textColor, bool hasShadow = false}) {
    return Container(
      width: 140, // Fixed width for cleaner layout in Wrap
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasShadow ? [BoxShadow(color: AppColors.primaryBlack.withOpacity(0.05), blurRadius: 10)] : null,
          border: hasShadow ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 28),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: textColor)),
           const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: textColor.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, double width) {
    final isCelebration = event['type'] == 'Celebration';
    final tagColor = isCelebration ? AppColors.crimsonSilk : AppColors.primaryBlack;
    final tagTextColor = isCelebration ? AppColors.primaryBlack : Colors.white;

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primaryBlack.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  event['image'],
                  height: 200,
                  width: width,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(height: 200, color: Colors.grey[300], child: const Center(child: Icon(Icons.broken_image))),
                ),
                 Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(event['type'], style: TextStyle(color: tagTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                 Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: AppColors.crimsonSilk, size: 16),
                        const SizedBox(width: 4),
                        Text(event['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  child: Text(event['tag'], style: const TextStyle(color: AppColors.softBlush, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(height: 12),
                Text(event['title'], style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.calendar_today_outlined, event['date']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on_outlined, event['location']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.people_outline, event['guests']),
                
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                 Row( // Using Row for Vendor
                   children: [
                     const Icon(Icons.storefront, size: 16, color: Colors.grey),
                     const SizedBox(width: 8),
                     Expanded(child: Text(event['vendor'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                   ],
                  ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.crimsonSilk,
                      foregroundColor: AppColors.primaryBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
                         SizedBox(width: 8),
                         Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
      ],
    );
  }
}
