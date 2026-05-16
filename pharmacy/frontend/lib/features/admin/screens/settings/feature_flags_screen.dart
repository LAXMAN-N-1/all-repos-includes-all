import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_settings.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureFlagsScreen extends StatefulWidget {
  const FeatureFlagsScreen({Key? key}) : super(key: key);

  @override
  State<FeatureFlagsScreen> createState() => _FeatureFlagsScreenState();
}

class _FeatureFlagsScreenState extends State<FeatureFlagsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Feature Flags", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add Flag"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.separated(
                itemCount: mockFeatureFlags.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final flag = mockFeatureFlags[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AuraColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AuraColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(flag.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'monospace')),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                                    child: Text("${flag.rolloutPercentage}% Rollout", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(flag.name, style: const TextStyle(color: AuraColors.primary, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(flag.description, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            ],
                          ),
                        ),
                        Switch(
                          value: flag.isEnabled,
                          onChanged: (val) {
                            setState(() => flag.isEnabled = val);
                          },
                          activeColor: AuraColors.success,
                        ),
                        IconButton(icon: const Icon(Icons.settings, color: Colors.white24), onPressed: () {}),
                      ],
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
