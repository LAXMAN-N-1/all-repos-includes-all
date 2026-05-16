import 'package:flutter/material.dart';
import '../../widgets/common_input.dart';
import '../../widgets/common_button.dart';

class VerifiedVendorsScreen extends StatefulWidget {
  const VerifiedVendorsScreen({super.key});

  @override
  State<VerifiedVendorsScreen> createState() => _VerifiedVendorsScreenState();
}

class _VerifiedVendorsScreenState extends State<VerifiedVendorsScreen> {
  final List<Map<String, dynamic>> verifiedVendors = [
    {
      'id': 1,
      'companyName': 'Elegant Caterers Inc.',
      'category': 'Catering',
      'rating': 4.8,
      'verifiedDate': 'Jan 15, 2023',
      'successRate': 98,
      'badges': ['Certified', 'Top Rated'],
      'image': 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
    },
    // ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verified Vendors', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFfdb913))),
            const Text('Vendors with verified credentials and high success rates', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            
            const CommonInput(placeholder: 'Search verified vendors...', prefixIcon: Icon(Icons.search)),
            const SizedBox(height: 24),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                childAspectRatio: 0.8,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: verifiedVendors.length,
              itemBuilder: (context, index) {
                final vendor = verifiedVendors[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Stack(
                          children: [
                            Image.network(
                              vendor['image'],
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(height: 150, color: Colors.grey[200]),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text('Verified', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(vendor['companyName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(vendor['category'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.orange, size: 16),
                                Text('${vendor['rating']}'),
                                const Spacer(),
                                Text('${vendor['successRate']}% Success', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              children: (vendor['badges'] as List).map((badge) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(4)),
                                  child: Text(badge, style: TextStyle(color: Colors.orange[800], fontSize: 10)),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
