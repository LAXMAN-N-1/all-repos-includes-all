import 'package:flutter/material.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_select.dart';
import '../../widgets/common_button.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  final List<Map<String, dynamic>> vendors = [
    {
      'id': 1,
      'name': 'Elegant Caterers Inc.',
      'category': 'Catering',
      'rating': 4.8,
      'reviews': 156,
      'location': 'Mumbai, Maharashtra',
      'phone': '+91 98765 43210',
      'email': 'contact@elegantcaterers.com',
      'status': 'Active',
      'totalEvents': 245,
      'eventsCompleted': 245,
      'joinedDate': 'Jan 2023',
      'revenue': '₹45,00,000',
      'verified': true,
      'description': 'Professional catering services for all types of events with a focus on quality and presentation',
      'profileImage': 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
      'yearsExperience': 8,
      'portfolio': [
        {'image': 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=400', 'title': 'Wedding Buffet'},
        {'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=400', 'title': 'Corporate Event'},
        {'image': 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=400', 'title': 'Gourmet Plating'},
      ],
    },
    {
      'id': 2,
      'name': 'Picture Perfect Studios',
      'category': 'Photography',
      'rating': 4.9,
      'reviews': 203,
      'location': 'Delhi, NCR',
      'phone': '+91 98765 43211',
      'email': 'info@pictureperfect.com',
      'status': 'Active',
      'totalEvents': 389,
      'eventsCompleted': 389,
      'joinedDate': 'Mar 2022',
      'revenue': '₹67,50,000',
      'verified': true,
      'description': 'Professional photography and videography capturing your special moments with artistic vision',
      'profileImage': 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800',
      'yearsExperience': 12,
      'portfolio': [
        {'image': 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400', 'title': 'Wedding Photography'},
        {'image': 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400', 'title': 'Portrait Session'},
        {'image': 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400', 'title': 'Event Coverage'},
      ],
    },
     // ... more vendors (truncated for brevity, but mimicking data structure)
  ];

  String searchTerm = '';
  String filterCategory = 'All';
  String filterStatus = 'All';

  void _showVendorDetails(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: 900,
          constraints: const BoxConstraints(maxHeight: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              // Header Image & Close Button
              Stack(
                children: [
                   ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      vendor['profileImage'],
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300], height: 250, child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: vendor['status'] == 'Active' ? Colors.green[100] : Colors.orange[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            vendor['status'],
                            style: TextStyle(
                              color: vendor['status'] == 'Active' ? Colors.green[800] : Colors.orange[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (vendor['verified']) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green[600],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Verified', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
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
                              Text(vendor['name'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFfef3d4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(vendor['category'], style: const TextStyle(color: Color(0xFFe5a711), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(vendor['description'], style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      const SizedBox(height: 24),
                      // Stats Grid
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildDetailStat('Rating', '${vendor['rating']}', Icons.star, Colors.yellow[700]!),
                          _buildDetailStat('Events', '${vendor['eventsCompleted']}', Icons.calendar_today, const Color(0xFFfdb913)),
                          _buildDetailStat('Experience', '${vendor['yearsExperience']} years', Icons.emoji_events, const Color(0xFFfdb913)),
                          _buildDetailStat('Revenue', vendor['revenue'], Icons.attach_money, const Color(0xFFfdb913)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Contact Info
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFe5a711))),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 24,
                              runSpacing: 16,
                              children: [
                                _buildContactItem(Icons.phone, vendor['phone']),
                                _buildContactItem(Icons.email, vendor['email']),
                                _buildContactItem(Icons.location_on, vendor['location']),
                                _buildContactItem(Icons.calendar_today, 'Joined ${vendor['joinedDate']}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Portfolio
                      const Text('Portfolio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFe5a711))),
                      const SizedBox(height: 16),
                      GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: (vendor['portfolio'] as List).length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = vendor['portfolio'][index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  item['image'], 
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                                ),
                                Container(
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
                                  alignment: Alignment.center,
                                  child: Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Footer Actions
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: 'Contact Vendor',
                        onPressed: () {},
                        // gradient background implied, default solid black for now or customized
                      ),
                    ),
                    const SizedBox(width: 16),
                    CommonButton(
                      text: 'Edit',
                      variant: ButtonVariant.outline,
                      icon: Icons.edit,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 16),
                    CommonButton(
                      text: 'Delete',
                      variant: ButtonVariant.destructive,
                      icon: Icons.delete,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFfef9e7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color == Colors.yellow[700] ? Colors.black : const Color(0xFFe5a711))),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFFfdb913)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientShaderCallback = (Rect bounds) => const LinearGradient(colors: [Color(0xFFfdb913), Color(0xFFe5a711)]).createShader(bounds);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: gradientShaderCallback,
              child: const Text('Vendor List', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Text('Manage all vendors and their details', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            const SizedBox(height: 24),

            // Top Stats
            Row(
              children: [
                _buildTopStat('Total Vendors', '${vendors.length}', gradientShaderCallback),
                const SizedBox(width: 16),
                _buildTopStat('Active Vendors', '${vendors.where((v) => v['status'] == 'Active').length}', gradientShaderCallback),
                const SizedBox(width: 16),
                _buildTopStat('Avg Rating', '4.7', gradientShaderCallback),
                const SizedBox(width: 16),
                _buildTopStat('Total Revenue', '₹2.4Cr', gradientShaderCallback),
              ],
            ),
            const SizedBox(height: 24),

            // Filters
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CommonInput(
                      placeholder: 'Search vendors...',
                      prefixIcon: const Icon(Icons.search),
                      onChanged: (val) => setState(() => searchTerm = val),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: CommonSelect<String>(
                      items: ['All', 'Catering', 'Photography', 'Decoration'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      value: filterCategory,
                      onChanged: (val) => setState(() => filterCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 200,
                    child: CommonSelect<String>(
                      items: ['All', 'Active', 'Pending', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      value: filterStatus,
                      onChanged: (val) => setState(() => filterStatus = val!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Grid
            LayoutBuilder(
              builder: (context, constraints) {
                double width = (constraints.maxWidth - 48) / 3;
                if (constraints.maxWidth < 1000) width = (constraints.maxWidth - 24) / 2;
                if (constraints.maxWidth < 600) width = constraints.maxWidth;

                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: vendors.map((vendor) {
                    return InkWell(
                      onTap: () => _showVendorDetails(vendor),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[100]!),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                  child: Image.network(
                                    vendor['profileImage'],
                                    height: 192,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(height: 192, color: Colors.grey[200]),
                                  ),
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: vendor['status'] == 'Active' ? Colors.green[100] : Colors.orange[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(vendor['status'], style: TextStyle(color: vendor['status'] == 'Active' ? Colors.green[800] : Colors.orange[800], fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFfdb913), borderRadius: BorderRadius.circular(12)),
                                    child: Text(vendor['category'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vendor['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 8),
                                  Text(vendor['description'], style: TextStyle(color: Colors.grey[600], fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 12),
                                  // Rating
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) => Icon(Icons.star, size: 16, color: index < (vendor['rating'] as double).floor() ? Colors.yellow[700] : Colors.grey[300])),
                                      const SizedBox(width: 8),
                                      Text('${vendor['rating']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(' (${vendor['reviews']} reviews)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Icons: Loc, Events, Exp
                                  _buildMiniInfo(Icons.location_on, vendor['location']),
                                  _buildMiniInfo(Icons.calendar_today, '${vendor['eventsCompleted']} events'),
                                  _buildMiniInfo(Icons.emoji_events, '${vendor['yearsExperience']} years'),
                                  const SizedBox(height: 16),
                                  CommonButton(
                                    text: 'View Full Profile',
                                    icon: Icons.visibility,
                                    onPressed: () => _showVendorDetails(vendor),
                                    fullWidth: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStat(String label, String value, ShaderCallback shaderCallback) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: shaderCallback,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniInfo(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
