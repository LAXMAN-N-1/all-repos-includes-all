import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import '../../../core/api/api_client.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Timer? _pollTimer;
  bool _loading = true;
  String _currentStage = 'APPLICATION_SUBMITTED';
  String? _error;

  static const _stages = [
    _OnboardingStage(
      id: 'APPLICATION_SUBMITTED',
      title: 'Application Submitted',
      description: 'Your dealer application has been submitted and is in the queue for review.',
      icon: LucideIcons.send,
      duration: 'Day 0-1 (15 mins)',
    ),
    _OnboardingStage(
      id: 'AUTOMATED_CHECKS',
      title: 'Automated Checks',
      description: 'GST verification, PAN validation, and business background checks.',
      icon: LucideIcons.searchCheck,
      duration: 'Day 1 (4 hours)',
    ),
    _OnboardingStage(
      id: 'KYC_CAPTURE',
      title: 'KYC Document Capture',
      description: 'Upload required identity and business documents for verification.',
      icon: LucideIcons.camera,
      duration: 'Day 1-2 (30 mins)',
    ),
    _OnboardingStage(
      id: 'KYC_VERIFICATION',
      title: 'KYC Verification',
      description: 'Our compliance team verifies your submitted documents.',
      icon: LucideIcons.shieldCheck,
      duration: 'Day 2-3 (24 hours)',
    ),
    _OnboardingStage(
      id: 'FIELD_VISIT_SCHEDULED',
      title: 'Field Visit Scheduled',
      description: 'A WEZU representative will visit your proposed station site.',
      icon: LucideIcons.calendar,
      duration: 'Day 3-5',
    ),
    _OnboardingStage(
      id: 'FIELD_VISIT_COMPLETED',
      title: 'Field Visit Completed',
      description: 'Site inspection report is under evaluation by the regional team.',
      icon: LucideIcons.checkCircle,
      duration: 'Day 5-6',
    ),
    _OnboardingStage(
      id: 'AGREEMENT_PENDING',
      title: 'Agreement Signing',
      description: 'Digital dealer agreement is ready for your review and e-signature.',
      icon: LucideIcons.fileSignature,
      duration: 'Day 6-7 (15 mins)',
    ),
    _OnboardingStage(
      id: 'TRAINING_SCHEDULED',
      title: 'Training & Go-Live',
      description: 'Complete the online training module and activate your dealer portal.',
      icon: LucideIcons.graduationCap,
      duration: 'Day 7-8 (2 hours)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
    _fetchStatus();
    // Poll every 30 seconds for status updates
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchStatus());
  }

  @override
  void dispose() {
    _c.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.get(ApiConstants.onboardingStatus);
      final data = res.data is Map ? res.data : {};
      setState(() {
        _currentStage = data['current_stage']?.toString() ?? 'APPLICATION_SUBMITTED';
        _loading = false;
        _error = null;
      });

      // If fully approved, redirect to dashboard
      if (_currentStage == 'APPROVED' || _currentStage == 'COMPLETED') {
        _pollTimer?.cancel();
        if (mounted) context.go('/dashboard');
      }
    } catch (e) {
      log('Onboarding status error: $e');
      setState(() { _loading = false; _error = 'Could not fetch status'; });
    }
  }

  int _stageIndex(String stage) {
    final i = _stages.indexWhere((s) => s.id == stage);
    return i < 0 ? 0 : i;
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.1; final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(animation: _c, builder: (c, _) {
      final t = Curves.easeOut.transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
      return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child));
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _stageIndex(_currentStage);
    final progress = ((currentIndex + 1) / _stages.length * 100).round();

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Column(children: [
              // Header Card
              _stagger(0, child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.shellBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.primaryGlow, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
                      child: const Icon(LucideIcons.batteryCharging, size: 24, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Dealer Onboarding', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('$progress% complete — Stage ${currentIndex + 1} of ${_stages.length}', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ])),
                    TextButton.icon(
                      icon: const Icon(LucideIcons.logOut, size: 14),
                      label: const Text('Skip to Portal'),
                      onPressed: () => context.go('/dashboard'),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / _stages.length,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: AppColors.primary,
                    ),
                  ),
                ]),
              )),
              const SizedBox(height: 24),

              if (_loading)
                const Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())
              else if (_error != null)
                _stagger(1, child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.red.withValues(alpha: 0.3))),
                  child: Row(children: [
                    const Icon(LucideIcons.alertCircle, color: AppColors.red),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.red))),
                    TextButton(onPressed: _fetchStatus, child: const Text('Retry')),
                  ]),
                ))
              else
                // Stage list
                ..._stages.asMap().entries.map((entry) {
                  final i = entry.key;
                  final stage = entry.value;
                  final isCompleted = i < currentIndex;
                  final isActive = i == currentIndex;
                  final isPending = i > currentIndex;

                  return _stagger(i + 1, child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Timeline
                      Column(children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppColors.primary
                                : isActive
                                    ? AppColors.primaryGlow
                                    : AppColors.cardBg,
                            border: Border.all(
                              color: isCompleted || isActive ? AppColors.primary : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: isCompleted
                              ? const Icon(LucideIcons.check, size: 16, color: Colors.white)
                              : isActive
                                  ? Container(
                                      width: 10, height: 10, margin: const EdgeInsets.all(11),
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                    )
                                  : Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textTertiary))),
                        ),
                        if (i < _stages.length - 1)
                          Container(width: 2, height: 50, color: isCompleted ? AppColors.primary : AppColors.border),
                      ]),
                      const SizedBox(width: 16),
                      // Card
                      Expanded(child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary.withValues(alpha: 0.05) : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: (isCompleted ? AppColors.primary : isActive ? AppColors.primary : AppColors.textTertiary).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(stage.icon, size: 18, color: isCompleted ? AppColors.primary : isActive ? AppColors.primary : AppColors.textTertiary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(stage.title, style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: isPending ? AppColors.textTertiary : AppColors.textPrimary,
                              ))),
                              if (isCompleted)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('COMPLETED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                )
                              else if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('IN PROGRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.amber)),
                                ),
                            ]),
                            const SizedBox(height: 4),
                            Text(stage.description, style: TextStyle(fontSize: 12, color: isPending ? AppColors.textMuted : AppColors.textSecondary, height: 1.4)),
                            const SizedBox(height: 4),
                            Text(stage.duration, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          ])),
                        ]),
                      )),
                    ]),
                  ));
                }),
            ]),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStage {
  final String id, title, description, duration;
  final IconData icon;
  const _OnboardingStage({required this.id, required this.title, required this.description, required this.icon, required this.duration});
}
