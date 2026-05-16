import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';

class VendorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> vendorData;

  const VendorProfileScreen({super.key, required this.vendorData});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Default data if mostly empty (since we're passing limited data from previous screen)
    final data = widget.vendorData;
    final name = data['name'] ?? 'Vendor Name';
    final type = data['type'] ?? 'Service';
    final location = data['location'] ?? 'Location';
    final rating = data['rating']?.toString() ?? '4.9';
    final reviews = data['reviews']?.toString() ?? '100';
    final image = data['image'] ?? 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&q=80';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Image Header
            Stack(
              children: [
                Image.network(
                  image,
                  height: 350,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 24,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                       icon: const Icon(Icons.arrow_back, color: Colors.black),
                       onPressed: () => context.pop(),
                    ),
                  ),
                ),
                 Positioned(
                  top: 50,
                  right: 24,
                  child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(
                       color: const Color(0xFF2196F3),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const Row(
                       children: [
                         Icon(Icons.verified, color: Colors.white, size: 16),
                         SizedBox(width: 8),
                         Text('Verified Vendor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                       ],
                     ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Main Info & Pricing Card Row (Responsive)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: _buildMainInfo(name, type, rating, reviews, location)),
                            const SizedBox(width: 40),
                            Expanded(flex: 1, child: _buildPricingCard()),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                             _buildMainInfo(name, type, rating, reviews, location),
                             const SizedBox(height: 32),
                             _buildPricingCard(),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                  // 3. Protection Badges
                  _buildProtectionBadges(),

                   const SizedBox(height: 40),

                  // 4. Tabs
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(4),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                         // Simple responsive tabs
                         final width = constraints.maxWidth;
                         final isSmall = width < 500;
                         return Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: ['About', 'Services', 'Portfolio', 'Reviews'].asMap().entries.map((entry) {
                              final isSelected = _selectedTabIndex == entry.key;
                              return Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _selectedTabIndex = entry.key),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: isSmall ? 4 : 16),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                                    ),
                                    child: Text(
                                      entry.value,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.black : Colors.grey[600],
                                        fontSize: isSmall ? 12 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                           }).toList(),
                         );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 5. Tab Content (About Only for now as per image)
                  if (_selectedTabIndex == 0) _buildAboutContent(name),
                  if (_selectedTabIndex != 0) Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('${['About', 'Services', 'Portfolio', 'Reviews'][_selectedTabIndex]} content coming soon...', style: TextStyle(color: Colors.grey[500])))),

                  const SizedBox(height: 60),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(String name, String type, String rating, String reviews, String location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(type, style: const TextStyle(color: Color(0xFFAA00FF), fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
             Row(mainAxisSize: MainAxisSize.min, children: [ const Icon(Icons.star, color: Color(0xFFFDB913)), const SizedBox(width: 8), Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(width: 4), Text('($reviews reviews)', style: const TextStyle(color: Colors.grey))]),
             const Row(mainAxisSize: MainAxisSize.min, children: [ Icon(Icons.calendar_month, color: Colors.grey), SizedBox(width: 8), Text('12 years experience', style: TextStyle(color: Colors.grey, fontSize: 16))]),
          ],
        ),
         const SizedBox(height: 16),
         Row(children: [const Icon(Icons.people_outline, color: Colors.grey), const SizedBox(width: 8), const Text('850+ events', style: TextStyle(color: Colors.grey, fontSize: 16))]),
         const SizedBox(height: 16),
         Row(children: [const Icon(Icons.location_on_outlined, color: Colors.grey), const SizedBox(width: 8), Text(location, style: const TextStyle(color: Colors.grey, fontSize: 16))]),
         const SizedBox(height: 16),
         Row(children: [const Icon(Icons.phone_outlined, color: Colors.grey), const SizedBox(width: 8), const Text('+91 98765 43210', style: TextStyle(color: Colors.grey, fontSize: 16))]),
         const SizedBox(height: 16),
          Row(children: [const Icon(Icons.email_outlined, color: Colors.grey), const SizedBox(width: 8), const Text('rajesh@catering.com', style: TextStyle(color: Colors.grey, fontSize: 16))]),

      ],
    );
  }
  
  Widget _buildPricingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9F5), // Light cream bg
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('Starting from', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('₹25,000', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Up to ₹1,50,000', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
             child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.schedule, color: Color(0xFF2E7D32), size: 16), SizedBox(width: 8), Text('Available', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold))]),
          ),
          const SizedBox(height: 24),
           SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFAA00FF), Color(0xFFFF6D00)]), // Purple to Orange
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _showBookingModal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
           ),
           const SizedBox(height: 16),
           SizedBox(
             width: double.infinity,
             child: OutlinedButton(
               onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFAA00FF),
                  side: const BorderSide(color: Color(0xFFAA00FF)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
               child: const Text('Request Quote', style: TextStyle(fontWeight: FontWeight.bold)),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildProtectionBadges() {
    return Container(
       decoration: BoxDecoration(
         color: const Color(0xFFF5FDF9),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFE0F2F1)),
       ),
       padding: const EdgeInsets.all(24),
       child: LayoutBuilder(
         builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 600;
            return Flex(
              direction: isSmall ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  flex: isSmall ? 0 : 1,
                  child: Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(color: const Color(0xFF2196F3), borderRadius: BorderRadius.circular(12)),
                         child: const Icon(Icons.shield_outlined, color: Colors.white),
                       ),
                       const SizedBox(width: 16),
                       const Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Customer Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           Text('100% money-back guarantee', style: TextStyle(color: Colors.grey, fontSize: 12)),
                         ],
                       ),
                    ],
                  ),
                ),
                if (isSmall) const SizedBox(height: 24),
                Expanded(
                  flex: isSmall ? 0 : 1,
                  child: Row(
                    children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(12)),
                         child: const Icon(Icons.verified_user_outlined, color: Colors.white),
                       ),
                       const SizedBox(width: 16),
                       const Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('Vendor Protection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                           Text('Secure payment & fraud cover', style: TextStyle(color: Colors.grey, fontSize: 12)),
                         ],
                       ),
                    ],
                  ),
                ),
              ],
            );
         },
       ),
    );
  }

  Widget _buildAboutContent(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About $name', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text(
          'Premier catering service specializing in both celebration and solemn events. We understand the importance of every occasion and provide customized menu options with the highest quality ingredients and presentation.',
          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 16),
        ),
         const SizedBox(height: 32),
         
        const Text('Specialties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            'Indian Cuisine', 'Continental', 'Live Counters', 'Dessert Stations', 'Multi-cuisine', 'Customized Menus'
          ].map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5), // Light purple
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(tag, style: const TextStyle(color: Color(0xFFAA00FF), fontWeight: FontWeight.w500)),
          )).toList(),
        ),

        const SizedBox(height: 32),

        const Text('Cancellation Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50], // Light grey
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('Free cancellation up to 7 days before event. 50% refund for 3-7 days. No refund within 3 days.', style: TextStyle(color: Colors.grey[700])),
        ),
      ],
    );
  }

  void _showBookingModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text('Book Rajesh Kumar Catering', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 16),
                 Text("Fill in your event details and we'll get back to you within 24 hours.", style: TextStyle(color: Colors.grey[600])),
                 const SizedBox(height: 32),
                 _buildTextField('Your Name'),
                 const SizedBox(height: 16),
                 _buildTextField('Email Address'),
                 const SizedBox(height: 16),
                 _buildTextField('Phone Number'),
                 const SizedBox(height: 16),
                 _buildTextField('03/01/2026'), // Mock Date Picker
                 const SizedBox(height: 16),
                 _buildTextField('Event Details', maxLines: 3),
                 const SizedBox(height: 32),
                 Row(
                   children: [
                     Expanded(
                       child: OutlinedButton(
                         onPressed: () => Navigator.pop(context),
                         style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           foregroundColor: Colors.black,
                         ),
                         child: const Text('Cancel'),
                       ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: Container(
                         decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFAA00FF), Color(0xFFFF6D00)]),
                            borderRadius: BorderRadius.circular(12),
                         ),
                         child: ElevatedButton(
                           onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Sent!')));
                           },
                           style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                           ),
                           child: const Text('Submit Request'),
                         ),
                       ),
                     ),
                   ],
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
