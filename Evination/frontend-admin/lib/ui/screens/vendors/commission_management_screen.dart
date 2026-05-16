import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CommissionManagementScreen extends StatelessWidget {
  const CommissionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Commission Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text('Set global and category-specific commission rates', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            // Global Settings Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Global Base Commission', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: '10',
                            decoration: const InputDecoration(
                              labelText: 'Default Percentage (%)',
                              border: OutlineInputBorder(),
                              suffixText: '%',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text('Update Global'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Specific Settings
            const Text('Category-Specific Rates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (ctx, i) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final categories = ['Venues', 'Catering', 'Photography', 'Decor', 'Entertainment'];
                  final rates = ['12', '10', '15', '10', '8'];
                  return ListTile(
                    title: Text(categories[i], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Current Rate: ${rates[i]}%'),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: TextFormField(
                                initialValue: rates[i],
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('%'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
