import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class VerifiedVendorsScreen extends StatefulWidget {
  const VerifiedVendorsScreen({super.key});

  @override
  State<VerifiedVendorsScreen> createState() => _VerifiedVendorsScreenState();
}

class _VerifiedVendorsScreenState extends State<VerifiedVendorsScreen> {
  final List<Map<String, dynamic>> _vendors = [
    {
      'name': 'Rajesh Kumar Catering',
      'type': 'Catering',
      'rating': 4.9,
      'reviews': 245,
      'location': 'Mumbai, Maharashtra',
      'status': 'Available',
      'tags': ['Indian Cuisine', 'Continental'],
      'image': 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Priya Photography Studio',
      'type': 'Photography',
      'rating': 4.8,
      'reviews': 189,
      'location': 'Delhi NCR',
      'status': 'Available',
      'tags': ['Wedding Photography', 'Candid'],
      'image': 'https://images.unsplash.com/photo-1554048612-387768052bf7?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Grand Venues & Halls',
      'type': 'Venue Booking',
      'rating': 4.7,
      'reviews': 156,
      'location': 'Bangalore, Karnataka',
      'status': 'Busy',
      'tags': ['Banquet Halls', 'Outdoor Venues'],
      'image': 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Elegant Decor Solutions',
      'type': 'Decoration',
      'rating': 4.9,
      'reviews': 198,
      'location': 'Pune, Maharashtra',
      'status': 'Available',
      'tags': ['Theme Decoration', 'Floral Setup'],
      'image': 'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Peaceful Tributes Services',
      'type': 'Ritual Services',
      'rating': 5.0,
      'reviews': 142,
      'location': 'Chennai, Tamil Nadu',
      'status': 'Available',
      'tags': ['Funeral Services', 'Memorial Setup'],
      'image': 'https://images.unsplash.com/photo-1520013511397-d5d10d10c897?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Divine Flowers & Arrangements',
      'type': 'Floral Setup',
      'rating': 4.8,
      'reviews': 167,
      'location': 'Kolkata, West Bengal',
      'status': 'Available',
      'tags': ['Wedding Flowers', 'Memorial Wreaths'],
      'image': 'https://images.unsplash.com/photo-1526047932273-341f2a7631f9?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Premium Hospitality Services',
      'type': 'Hospitality',
      'rating': 4.7,
      'reviews': 134,
      'location': 'Hyderabad, Telangana',
      'status': 'Available',
      'tags': ['Guest Management', 'Valet Services'],
      'image': 'https://images.unsplash.com/photo-1556745753-b2904692b3cd?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Ankit Videography',
      'type': 'Videography',
      'rating': 4.9,
      'reviews': 176,
      'location': 'Jaipur, Rajasthan',
      'status': 'Busy',
      'tags': ['Cinematic Videos', 'Drone Coverage'],
      'image': 'https://images.unsplash.com/photo-1587329310686-947526a1ca32?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Meera Event Management',
      'type': 'Event Management',
      'rating': 4.8,
      'reviews': 203,
      'location': 'Ahmedabad, Gujarat',
      'status': 'Available',
      'tags': ['Full Event Planning', 'Coordination'],
      'image': 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Stellar Sound & Lights',
      'type': 'Sound & Lights',
      'rating': 4.6,
      'reviews': 123,
      'location': 'Surat, Gujarat',
      'status': 'Available',
      'tags': ['Sound Systems', 'Stage Lighting'],
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Royal Caterers & Bakers',
      'type': 'Catering',
      'rating': 4.7,
      'reviews': 187,
      'location': 'Lucknow, Uttar Pradesh',
      'status': 'Available',
      'tags': ['North Indian', 'Desserts'],
      'image': 'https://images.unsplash.com/photo-1621303837174-89787a7d4729?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Grace Memorial Services',
      'type': 'Ritual Services',
      'rating': 5.0,
      'reviews': 98,
      'location': 'Kochi, Kerala',
      'status': 'Available',
      'tags': ['Funeral Planning', 'Cremation Services'],
      'image': 'https://images.unsplash.com/photo-1498952875150-136debc91350?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Creative Stage Designers',
      'type': 'Decoration',
      'rating': 4.8,
      'reviews': 145,
      'location': 'Indore, Madhya Pradesh',
      'status': 'Busy',
      'tags': ['Stage Setup', 'Backdrop Design'],
      'image': 'https://images.unsplash.com/photo-1519741497674-611481863552?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Vivek Transport Solutions',
      'type': 'Transportation',
      'rating': 4.6,
      'reviews': 112,
      'location': 'Nagpur, Maharashtra',
      'status': 'Available',
      'tags': ['Guest Transport', 'Luxury Cars'],
      'image': 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Sparkle Event Planners',
      'type': 'Event Management',
      'rating': 4.9,
      'reviews': 221,
      'location': 'Chandigarh, Punjab',
      'status': 'Available',
      'tags': ['Corporate Events', 'Weddings'],
      'image': 'https://images.unsplash.com/photo-1527529482837-4698179dc6ce?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Serene Memorial Care',
      'type': 'Ritual Services',
      'rating': 4.9,
      'reviews': 156,
      'location': 'Bhubaneswar, Odisha',
      'status': 'Available',
      'tags': ['Condolence Setup', 'Prayer Arrangements'],
      'image': 'https://images.unsplash.com/photo-1533036813133-c15144d93026?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Elite Photography & Films',
      'type': 'Photography',
      'rating': 4.8,
      'reviews': 193,
      'location': 'Visakhapatnam, Andhra Pradesh',
      'status': 'Busy',
      'tags': ['Wedding Films', 'Event Coverage'],
      'image': 'https://images.unsplash.com/photo-1604017011826-d3b4c23f8914?auto=format&fit=crop&q=80',
    },
    {
      'name': 'Blissful Venue Spaces',
      'type': 'Venue Booking',
      'rating': 4.7,
      'reviews': 178,
      'location': 'Goa',
      'status': 'Available',
      'tags': ['Beach Venues', 'Resort Spaces'],
      'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bordeauxGradient),
        child: SingleChildScrollView(
           child: Column(
             children: [
               // 1. Hero
               Container(
                 width: double.infinity,
                 padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
                 child: Column(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(18),
                       decoration: BoxDecoration(
                         gradient: AppColors.luxuryGradient,
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: AppColors.crimsonSilk.withValues(alpha: 0.3),
                             blurRadius: 20,
                             offset: const Offset(0, 10),
                           )
                         ],
                       ),
                       child: const Icon(Icons.shield_outlined, size: 36, color: Colors.white),
                     ),
                     const SizedBox(height: 32),
                     Text(
                       'VERIFIED ARTISANS',
                       style: GoogleFonts.cormorantGaramond(
                         fontSize: 36, 
                         fontWeight: FontWeight.bold, 
                         color: AppColors.softBlush,
                         letterSpacing: 2.0,
                       ),
                     ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0),
                     const SizedBox(height: 16),
                     Text(
                       'Hand-selected professionals vetted for excellence, integrity, and insurance protection',
                       textAlign: TextAlign.center,
                       style: GoogleFonts.outfit(fontSize: 15, color: Colors.white54, height: 1.5),
                     ).animate().fadeIn(delay: 200.ms),
                   ],
                 ),
               ),
 
               // 2. Stats
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _buildStatCard('18', 'A-List Artisans', Icons.shield, true)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('4.9', 'Excellence Rating', Icons.star_outline, false)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('100%', 'Elite Insurance', Icons.verified_outlined, false)),
                    ],
                  ),
               ),
 
               const SizedBox(height: 32),
 
               // 3. Search Bar
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: Container(
                   padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.white.withValues(alpha: 0.05),
                     borderRadius: BorderRadius.circular(18),
                     border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                   ),
                   child: Row(
                     children: [
                       const Icon(Icons.search, color: AppColors.softBlush, size: 20),
                       const SizedBox(width: 16),
                       Expanded(
                         child: TextField(
                           style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                           decoration: InputDecoration(
                             border: InputBorder.none,
                             hintText: 'Seek excellence by name...',
                             hintStyle: GoogleFonts.outfit(color: Colors.white24, fontSize: 14),
                           ),
                         ),
                       ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                           decoration: BoxDecoration(
                             color: Colors.white.withValues(alpha: 0.05),
                             borderRadius: BorderRadius.circular(10),
                           ),
                           child: Row(children: [Text('MOST ACCOMPLISHED', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)), const SizedBox(width: 8), const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.softBlush)]),
                        ),
                     ],
                   ),
                 ),
               ),
               
               const SizedBox(height: 48),
 
               // 4. Vendor Grid
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 child: LayoutBuilder(builder: (context, constraints) {
                   final width = constraints.maxWidth;
                   final crossAxisCount = width > 1200 ? 3 : (width > 800 ? 2 : 1);
                   
                   return Wrap(
                     spacing: 24,
                     runSpacing: 32,
                     children: _vendors.map((vendor) {
                       final cardWidth = (width - ((crossAxisCount - 1) * 24)) / crossAxisCount;
                       return _buildVendorCard(vendor, cardWidth);
                     }).toList(),
                   );
                 }),
               ),
 
               const SizedBox(height: 80),
 
               // 5. Why Choose Section
               _buildWhyChooseSection(),
 
               const SizedBox(height: 80),
             ],
           ),
        ),
      ),
    );
  }
 
  Widget _buildStatCard(String value, String label, IconData icon, bool highlight) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.crimsonSilk, size: 24),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.softBlush)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), textAlign: TextAlign.center, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1.0)),
        ],
      ),
    );
  }
 
  Widget _buildVendorCard(Map<String, dynamic> vendor, double width) {
    final isBusy = vendor['status'] == 'Busy';
    final statusColor = isBusy ? AppColors.rubyRed : AppColors.emerald;
 
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Image & Badges
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: Stack(
                children: [
                   ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.black.withValues(alpha: 0.5), Colors.transparent],
                        stops: const [0.0, 0.6, 1.0],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(
                      vendor['image'],
                      height: 240,
                      width: width,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)]
                      ),
                      child: Row(children: [const Icon(Icons.shield, size: 14, color: Colors.white), const SizedBox(width: 6), Text('VERIFIED', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.white, letterSpacing: 1.0))]),
                    ),
                  ),
                   Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(vendor['status'].toUpperCase(), style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                  ),
                   Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.black.withValues(alpha: 0.6),
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Colors.white10),
                       ),
                      child: Row(children: [const Icon(Icons.star, color: AppColors.crimsonSilk, size: 14), const SizedBox(width: 6), Text('${vendor['rating']} LUXE RATING', style: GoogleFonts.outfit(color: AppColors.softBlush, fontSize: 10, fontWeight: FontWeight.bold))]),
                    ),
                  ),
                ],
              ),
            ),
 
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     vendor['type'].toUpperCase(), 
                     style: GoogleFonts.outfit(color: AppColors.crimsonSilk, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.5)
                   ),
                   const SizedBox(height: 12),
                   Text(
                     vendor['name'], 
                     style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.softBlush, height: 1.1)
                   ),
                   const SizedBox(height: 12),
                   Row(children: [Icon(Icons.location_on, size: 14, color: Colors.white.withValues(alpha: 0.3)), const SizedBox(width: 8), Text(vendor['location'], style: GoogleFonts.outfit(color: Colors.white38, fontSize: 13))]),
                   const SizedBox(height: 24),
                   Wrap(
                     spacing: 10,
                     runSpacing: 10,
                     children: (vendor['tags'] as List).map<Widget>((tag) => Container(
                       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), 
                       decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.03), 
                         borderRadius: BorderRadius.circular(10),
                         border: Border.all(color: Colors.white.withValues(alpha: 0.05))
                       ), 
                       child: Text(tag, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11))
                     )).toList(),
                   ),
                   const SizedBox(height: 32),
                   Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.luxuryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: AppColors.crimsonSilk.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))
                        ]
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                           context.push('/vendor_profile', extra: vendor);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('RESERVE NOW', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 13)),
                      ),
                   ),
                ],
              ),
            ),
        ],
      ),
    );
  }
 
  Widget _buildWhyChooseSection() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24),
       child: Column(
         children: [
            Text(
              'THE EBONY STANDARD', 
              style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.softBlush, letterSpacing: 2.0)
            ),
            const SizedBox(height: 16),
            Text(
              'Stringent curation ensures your celebration is managed by the industry\'s most distinguished professionals.', 
              textAlign: TextAlign.center, 
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 15, height: 1.6)
            ),
            const SizedBox(height: 56),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 _buildWhyItem(Icons.verified_user_outlined, 'VETTED ELITE', 'Strict background curation'),
                 _buildWhyItem(Icons.auto_awesome_outlined, 'BESPOKE QUALITY', 'Curated for high-profile events'),
                 _buildWhyItem(Icons.support_agent_outlined, 'WHITE GLOVE', 'Dedicated concierge support'),
              ],
            ),
         ],
       ),
     );
  }
 
  Widget _buildWhyItem(IconData icon, String title, String subtitle) {
     return Expanded(
       child: Column(
         children: [
            Icon(icon, color: AppColors.crimsonSilk, size: 36),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.softBlush, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.white24, fontSize: 11, height: 1.4)),
          ],
        ),
      );
   }
}
