import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';
import 'package:evination_customer_app/app/routes.dart';
import 'package:evination_customer_app/presentation/providers/auth/auth_notifier.dart';
import 'package:evination_customer_app/presentation/widgets/logo/eve_nation_animated_logo.dart';

class NewSplashScreen extends ConsumerStatefulWidget {
  const NewSplashScreen({super.key});

  @override
  ConsumerState<NewSplashScreen> createState() => _NewSplashScreenState();
}

class _NewSplashScreenState extends ConsumerState<NewSplashScreen> {
  // Stages: 'logo', 'features', 'ready'
  String _stage = 'logo';
  int _currentFeature = 0;

  final List<Map<String, dynamic>> _features = [
    {'icon': LucideIcons.heart, 'text': 'Easy Event Planning'},
    {'icon': LucideIcons.shield, 'text': 'Verified Vendors Only'},
    {'icon': LucideIcons.award, 'text': 'Best Price Guarantee'},
    {'icon': LucideIcons.sparkles, 'text': 'Unforgettable Experiences'},
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onLogoAnimationComplete() {
    setState(() {
      _stage = 'features';
    });
    _startFeatureCycle();
  }

  void _startFeatureCycle() async {
    for (int i = 0; i < _features.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentFeature = i;
      });
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    
    if (mounted) {
      setState(() {
        _stage = 'ready';
      });
      await Future.delayed(const Duration(seconds: 2));
      _checkAuthAndNavigate();
    }
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.authenticated) {
      context.go(AppRouter.home);
    } else {
      context.go(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sunflowerYellow.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sunflowerYellow.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 4.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
             .rotate(duration: 20.seconds),
          ),
          
           Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.goldenAmber.withValues(alpha: 0.08),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.goldenAmber.withValues(alpha: 0.05),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .scale(duration: 5.seconds, begin: const Offset(1.2, 1.2), end: const Offset(1, 1))
             .rotate(duration: 15.seconds),
          ),

          // Content
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildCurrentStage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStage() {
    switch (_stage) {
      case 'logo':
        return EveNationAnimatedLogo(
          key: const ValueKey('logo'),
          onAnimationComplete: _onLogoAnimationComplete,
        );
      
      case 'features':
        final feature = _features[_currentFeature];
        return KeyedSubtree(
          key: ValueKey('feature_$_currentFeature'), 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.sunflowerYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.4), blurRadius: 30),
                  ],
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  size: 48,
                  color: Colors.white,
                ),
              ).animate()
               .scale(duration: 500.ms, curve: Curves.easeOutBack)
               .fadeIn(duration: 300.ms),
               
              const SizedBox(height: 32),
              
              Text(
                feature['text'] as String,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkCharcoal,
                ),
              ).animate()
               .slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOut)
               .fadeIn(duration: 300.ms),

               const SizedBox(height: 40),
               
               // Progress Dots
               Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: List.generate(_features.length, (index) {
                   final isActive = index <= _currentFeature;
                   return AnimatedContainer(
                     duration: const Duration(milliseconds: 300),
                     margin: const EdgeInsets.symmetric(horizontal: 4),
                     width: isActive ? 12 : 8,
                     height: 8,
                     decoration: BoxDecoration(
                       color: isActive ? AppColors.sunflowerYellow : Colors.grey[300],
                       borderRadius: BorderRadius.circular(4),
                     ),
                   );
                 }),
               )
            ],
          ),
        );

      case 'ready':
        return Column(
          key: const ValueKey('ready'),
          mainAxisSize: MainAxisSize.min,
          children: [
             Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.sunflowerYellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 5),
                  ],
                ),
                child: const Icon(LucideIcons.sparkles, size: 60, color: Colors.white),
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5))
               .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut)
               .then(delay: 1.seconds)
               .scale(begin: const Offset(1.1,1.1), end: const Offset(1, 1), duration: 1.seconds),
               
               const SizedBox(height: 32),
               
               Text(
                 'Welcome to\nEVE NATION!',
                 textAlign: TextAlign.center,
                 style: GoogleFonts.outfit(
                   fontSize: 36,
                   height: 1.2,
                   fontWeight: FontWeight.w900,
                   color: AppColors.sunflowerYellow,
                 ),
               ).animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
