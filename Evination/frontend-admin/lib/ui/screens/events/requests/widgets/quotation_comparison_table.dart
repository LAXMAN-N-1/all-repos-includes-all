import 'package:flutter/material.dart';
import 'package:admin_panel/theme/app_theme.dart';

class QuotationComparisonWidget extends StatelessWidget {
  const QuotationComparisonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('Vendor Quotations Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text('Invite More Vendors')),
             ],
           ),
           const SizedBox(height: 24),
           
           SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // Labels Column
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const SizedBox(height: 180), // Spacer for header cards
                     _buildLabel('Total Amount'),
                     _buildLabel('Advance Required'),
                     _buildLabel('Services Included'),
                     _buildLabel('Cancellation Policy'),
                     _buildLabel('Vendor Rating'),
                     _buildLabel('Commission (Platform Estimate)'),
                   ],
                 ),
                 
                 // Vendor 1
                 _buildVendorColumn(
                   context,
                   'Elegant Caterers',
                   '₹1,25,000',
                   'Recommended',
                   Colors.green,
                   items: [
                     '₹1,25,000',
                     '40%',
                     'Food, Service, Cutlery',
                     'Flexible (90% refund)',
                     '4.8 ⭐',
                     '₹12,500 (10%)',
                   ],
                 ),
                 // Vendor 2
                 _buildVendorColumn(
                   context,
                   'Grand Feast',
                   '₹1,15,000',
                   'Lowest Price',
                   Colors.blue,
                   items: [
                     '₹1,15,000',
                     '50%',
                     'Food only',
                     'Strict (0% refund < 7 days)',
                     '4.2 ⭐',
                     '₹11,500 (10%)',
                   ],
                 ),
                 // Vendor 3
                 _buildVendorColumn(
                   context,
                   'Royal Kitchens',
                   '₹1,40,000',
                   'Premium',
                   Colors.amber,
                   items: [
                      '₹1,40,000',
                      '30%',
                      'Food, Live Counter, Drinks',
                      'Moderate',
                      '4.9 ⭐',
                      '₹14,000 (10%)',
                   ],
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      height: 50,
      width: 200,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildVendorColumn(BuildContext context, String name, String price, String tag, Color tagColor, {required List<String> items}) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Header
          Container(
             padding: const EdgeInsets.all(16),
             decoration: BoxDecoration(
               color: tagColor.withOpacity(0.05),
               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
             ),
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(4)),
                   child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                 ),
                 const SizedBox(height: 12),
                 Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 const SizedBox(height: 4),
                 Text(price, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary700)),
                 const SizedBox(height: 12),
                 ElevatedButton(
                   onPressed: (){}, 
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppTheme.primary500,
                     foregroundColor: Colors.white,
                     minimumSize: const Size(double.infinity, 36),
                   ),
                   child: const Text('Select Quote'),
                 ),
               ],
             ),
          ),
          
          // Items
          ...items.map((item) => Container(
            height: 50,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
               border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
          )),
        ],
      ),
    );
  }
}
