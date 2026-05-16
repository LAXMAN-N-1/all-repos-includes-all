import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/theme/app_theme.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String lastUpdated;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.sections,
  });

  factory LegalDocumentScreen.terms() {
    return LegalDocumentScreen(
      title: 'Terms of Service',
      lastUpdated: 'April 26, 2026',
      sections: const [
        LegalSection(
          heading: '1. Service Scope',
          content:
              'WEZU provides battery swap, rental, and related wallet services through the customer app and partner stations.',
        ),
        LegalSection(
          heading: '2. Account Responsibility',
          content:
              'You are responsible for maintaining account security, accuracy of profile details, and lawful usage of the platform.',
        ),
        LegalSection(
          heading: '3. Rentals and Charges',
          content:
              'Rental fees, late fees, and damage penalties may apply based on active pricing rules and station policies.',
        ),
        LegalSection(
          heading: '4. Device and Safety',
          content:
              'Only compatible vehicles and approved usage conditions are allowed. Misuse can lead to suspension and liability.',
        ),
        LegalSection(
          heading: '5. Changes to Terms',
          content:
              'WEZU may update these terms with notice in the app. Continued use after update constitutes acceptance.',
        ),
      ],
    );
  }

  factory LegalDocumentScreen.privacy() {
    return LegalDocumentScreen(
      title: 'Privacy Policy',
      lastUpdated: 'April 26, 2026',
      sections: const [
        LegalSection(
          heading: '1. Data We Collect',
          content:
              'We collect profile details, authentication metadata, location used for station search, and transaction/rental activity.',
        ),
        LegalSection(
          heading: '2. Why We Use Data',
          content:
              'Data is used to provide rentals, improve station recommendations, secure accounts, prevent fraud, and support customer service.',
        ),
        LegalSection(
          heading: '3. Sharing and Access',
          content:
              'Data is shared only with authorized WEZU systems, operational partners, and legal authorities when required by law.',
        ),
        LegalSection(
          heading: '4. Retention and Security',
          content:
              'We use encryption, access controls, and periodic audits. Data is retained only as long as operational or legal needs require.',
        ),
        LegalSection(
          heading: '5. Your Controls',
          content:
              'You can update profile details, manage permissions, and request support for privacy-related concerns from the Help Center.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.shadowLight,
            ),
            child: Text(
              'Last updated: $lastUpdated',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...sections.map((section) => _buildSection(context, section)),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, LegalSection section) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.content,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final String content;

  const LegalSection({required this.heading, required this.content});
}
