import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../theme/app_theme.dart';

class KYCVerificationScreen extends StatelessWidget {
  const KYCVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'KYC Verification',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete your profile verification to start bidding on prime events.',
            style: TextStyle(color: AppTheme.gray600, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Status Card
          _buildStatusCard(context),
          const SizedBox(height: 32),

          // Document List
          const Text(
            'Required Documents',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDocumentItem(
            context,
            'Business License',
            'Valid trade license or registration certificate',
            'Uploaded',
            LucideIcons.fileText,
            true,
          ),
          _buildDocumentItem(
            context,
            'Tax Registration (GST/VAT)',
            'Tax Identification Number certificate',
            'Pending',
            LucideIcons.percent,
            false,
          ),
          _buildDocumentItem(
            context,
            'Identity Proof',
            'Passport, Aadhar or Government ID',
            'Not Started',
            LucideIcons.user,
            false,
          ),
          
          const SizedBox(height: 32),
          
          // Guidelines
          _buildGuidelines(context),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGold, AppTheme.darkGold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(LucideIcons.shieldCheck, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verification Status: Pending',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your profile is 65% complete. Upload the remaining documents to finish.',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    IconData icon,
    bool isCompleted,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gray200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: AppTheme.gray600, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.success.withOpacity(0.1) : AppTheme.gray100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isCompleted ? AppTheme.success : AppTheme.gray600,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (!isCompleted)
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Upload', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelines(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundTint.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.info, color: AppTheme.darkGold, size: 20),
              SizedBox(width: 8),
              Text('Verification Guidelines', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkGold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem('Documents must be clear and legible.'),
          _buildGuidelineItem('Accepted formats: PDF, JPG, PNG (Max 5MB).'),
          _buildGuidelineItem('Verification typically takes 2-3 business days.'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: AppTheme.gray400, shape: BoxShape.circle)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: AppTheme.gray600, fontSize: 13))),
        ],
      ),
    );
  }
}
