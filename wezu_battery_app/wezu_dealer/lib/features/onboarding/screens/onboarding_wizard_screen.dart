import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../providers/onboarding_provider.dart';
import '../models/onboarding_state.dart';

class OnboardingWizardScreen extends ConsumerStatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  ConsumerState<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends ConsumerState<OnboardingWizardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final currentStage = OnboardingStage.fromCode(state.status?.currentStage ?? 'SUBMITTED');

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Row(
        children: [
          // ── Left Side: Stage Info & Progress ──
          Container(
            width: 320,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.shellBg,
              border: Border(right: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(LucideIcons.batteryCharging, color: AppColors.primary, size: 22),
                ),
                const SizedBox(height: 32),
                const Text('Verification\nJourney', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.1)),
                const SizedBox(height: 12),
                const Text('Complete these steps to activate your dealer account and start operations.', 
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                const SizedBox(height: 48),
                Expanded(
                  child: ListView.builder(
                    itemCount: OnboardingStage.values.length,
                    itemBuilder: (context, index) {
                      final stage = OnboardingStage.values[index];
                      return _StageNavItem(
                        stage: stage,
                        isCurrent: stage == currentStage,
                        isCompleted: stage.index < currentStage.index || currentStage == OnboardingStage.active,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () => ref.read(onboardingProvider.notifier).refresh(),
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: const Text('Refresh Status', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // ── Right Side: Stage Actions & Details ──
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(60),
              child: state.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildStageContent(currentStage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent(OnboardingStage stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text('STAGE ${stage.index + 1} OF 8', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: 1)),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(stage.title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(stage.description, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        const SizedBox(height: 48),
        
        // Dynamic Action Area based on Stage
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.shellBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
            ),
            child: _getActionForStage(stage),
          ),
        ),
      ],
    );
  }

  Widget _getActionForStage(OnboardingStage stage) {
    switch (stage) {
      case OnboardingStage.submitted:
        return _ActionCard(
          title: 'Automated Checks Pending',
          msg: 'We need to verify your GST and basic business identity through our automated systems.',
          icon: LucideIcons.scan,
          buttonText: 'Run Automated Checks',
          onPressed: () => ref.read(onboardingProvider.notifier).triggerAutomatedChecks(),
        );
      case OnboardingStage.automatedChecks:
        return _ActionCard(
          title: 'KYC Documents Required',
          msg: 'Please upload your Proof of Identity, Address, and Business PAN in the Documents section.',
          icon: LucideIcons.filePlus,
          buttonText: 'Submit KYC',
          onPressed: () => ref.read(onboardingProvider.notifier).submitKyc(),
          secondaryButtonText: 'Go to Documents',
          onSecondaryPressed: () => context.go('/documents'),
        );
      case OnboardingStage.kycSubmitted:
        return const _WaitCard(
          title: 'Manual Review in Progress',
          msg: 'Our back-office team is verifying your documentation. This usually takes 1-2 business days.',
          icon: LucideIcons.userCheck,
        );
      case OnboardingStage.manualReview:
        return const _WaitCard(
          title: 'Scheduling Field Visit',
          msg: 'Your application looks great! An officer will soon be assigned to visit your premise.',
          icon: LucideIcons.calendar,
        );
      case OnboardingStage.visitScheduled:
        return const _WaitCard(
          title: 'Awaiting Site Verification',
          msg: 'The field verification is scheduled. Please ensure space and power requirements are met.',
          icon: LucideIcons.mapPin,
        );
      case OnboardingStage.visitCompleted:
        return const _WaitCard(
          title: 'Final Approval Pending',
          msg: 'The field report is being reviewed by the operations head for final sign-off.',
          icon: LucideIcons.checkCircle,
        );
      case OnboardingStage.approved:
        return _ActionCard(
          title: 'Setup & Training',
          msg: 'Access our training modules to learn about battery handling, station ops, and swapping protocols.',
          icon: LucideIcons.graduationCap,
          buttonText: 'Complete Training',
          onPressed: () => ref.read(onboardingProvider.notifier).completeTraining(),
        );
      case OnboardingStage.training:
        return const _WaitCard(
          title: 'Inventory Handover',
          msg: 'Final step! Your initial battery stock and branding kit are being dispatched.',
          icon: LucideIcons.truck,
        );
      case OnboardingStage.active:
        return _ActionCard(
          title: 'All Systems Go!',
          msg: 'Congratulations! Your dealer portal is fully activated. You can now access all features.',
          icon: LucideIcons.partyPopper,
          buttonText: 'Go to Dashboard',
          onPressed: () => context.go('/dashboard'),
        );
    }
  }
}

class _StageNavItem extends StatelessWidget {
  final OnboardingStage stage;
  final bool isCurrent, isCompleted;
  const _StageNavItem({required this.stage, required this.isCurrent, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppColors.primary : (isCurrent ? AppColors.textPrimary : AppColors.textMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.primary : Colors.transparent,
              border: Border.all(color: isCompleted || isCurrent ? AppColors.primary : AppColors.border, width: 2),
            ),
            child: isCompleted ? const Icon(LucideIcons.check, size: 10, color: Colors.white) : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(stage.title, style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500, color: color)),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title, msg, buttonText; final String? secondaryButtonText; final IconData icon;
  final VoidCallback onPressed; final VoidCallback? onSecondaryPressed;
  const _ActionCard({required this.title, required this.msg, required this.buttonText, required this.icon, required this.onPressed, this.secondaryButtonText, this.onSecondaryPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppColors.primary.withValues(alpha: 0.5)),
        const SizedBox(height: 24),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (secondaryButtonText != null) ...[
              OutlinedButton(onPressed: onSecondaryPressed, child: Text(secondaryButtonText!)),
              const SizedBox(width: 12),
            ],
            ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ],
    );
  }
}

class _WaitCard extends StatelessWidget {
  final String title, msg; final IconData icon;
  const _WaitCard({required this.title, required this.msg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(strokeWidth: 2),
        const SizedBox(height: 32),
        Icon(icon, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
      ],
    );
  }
}
