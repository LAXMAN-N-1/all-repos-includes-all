import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_navigator.dart';
import '../../widgets/app_scaffold.dart';
import '../auth/providers/auth_providers.dart';

/// Animated splash screen that checks for existing session.
/// Routes to dashboard if authenticated, login otherwise.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _ambientController;
  late Animation<double> _logoOpacity;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowScaleAnimation;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleOpacity;
  double _sessionProgress = 0.02;
  String _sessionMessage = 'Starting secure checks...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _ambientController = AnimationController(
      duration: const Duration(milliseconds: 4200),
      vsync: this,
    )..repeat();

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.56, curve: Curves.easeOutBack),
      ),
    );

    _glowScaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.12, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.86, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.32, 0.88, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Attempt to restore session
    _checkSession();
  }

  void _updateSessionStage({
    required double progress,
    required String message,
  }) {
    if (!mounted) return;
    final normalized = progress.clamp(0.0, 1.0);
    setState(() {
      _sessionProgress = math.max(_sessionProgress, normalized);
      _sessionMessage = message;
    });
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 260));

    if (!mounted) return;

    _updateSessionStage(progress: 0.12, message: 'Checking saved session...');

    // Try to restore existing session
    await ref
        .read(authStateProvider.notifier)
        .restoreSessionWithProgress(
          onProgress: (progress) {
            _updateSessionStage(
              progress: progress.value,
              message: progress.message,
            );
          },
        );

    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    final routeToDashboard = authState.when(
      initial: () {
        _updateSessionStage(progress: 1.0, message: 'No active session');
        return false;
      },
      loading: () {
        _updateSessionStage(progress: 1.0, message: 'Finishing setup...');
        return false;
      },
      loaded: (_) {
        _updateSessionStage(progress: 1.0, message: 'Welcome back');
        return true;
      },
      error: (_) {
        _updateSessionStage(progress: 1.0, message: 'Sign in required');
        return false;
      },
    );

    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;

    if (routeToDashboard) {
      AppNavigator.toDashboard(context);
      return;
    }
    AppNavigator.toLogin(context);
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      useSafeArea: false,
      statusBarBrightness: Brightness.light,
      backgroundColor: const Color(0xFF041833),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF041833),
                  Color(0xFF0A2A4A),
                  Color(0xFF0E7A5F),
                ],
                stops: [0, 0.68, 1],
              ),
            ),
          ),
          Positioned(
            top: -90,
            left: -70,
            child: _AmbientOrb(
              size: 220,
              color: const Color(0x5542D7B6),
              introAnimation: _controller,
              ambientAnimation: _ambientController,
              driftX: 10,
              driftY: 8,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _AmbientOrb(
              size: 260,
              color: const Color(0x445FA7FF),
              introAnimation: _controller,
              ambientAnimation: _ambientController,
              driftX: -12,
              driftY: 9,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: AnimatedBuilder(
                        animation: _ambientController,
                        builder: (context, child) {
                          final phase = _ambientController.value * 2 * math.pi;
                          final lift = math.sin(phase) * 5;
                          final pulse = 1 + (math.sin(phase) * 0.06);
                          return Transform.translate(
                            offset: Offset(0, lift),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.scale(
                                  scale: pulse,
                                  child: ScaleTransition(
                                    scale: _glowScaleAnimation,
                                    child: Container(
                                      width: 170,
                                      height: 170,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Color(0x6643DEC0),
                                            Color(0x0043DEC0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 116,
                                  height: 116,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF24CF9B),
                                        Color(0xFF1392BB),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF0F8F94,
                                        ).withValues(alpha: 0.45),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF082649),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.local_shipping_rounded,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  FadeTransition(
                    opacity: _titleOpacity,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: Column(
                        children: [
                          Text(
                            'WEZU',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'LOGISTICS',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFD8FDF2),
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 52,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _subtitleOpacity,
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.22),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: Text(
                      _sessionMessage,
                      key: ValueKey(_sessionMessage),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LoadingPulseStrip(
                    animation: _ambientController,
                    progress: _sessionProgress,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPulseStrip extends StatelessWidget {
  const _LoadingPulseStrip({required this.animation, required this.progress});

  final Animation<double> animation;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      width: 132,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFF8AFDE1),
                              Color(0xFF53E7C5),
                              Color(0xFF42D7B6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                  if (value > 0.02)
                    AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final shimmerTravel = ((animation.value * 2.4) - 1.2)
                            .clamp(-1.2, 1.2);
                        return Align(
                          alignment: Alignment(shimmerTravel, 0),
                          child: FractionallySizedBox(
                            widthFactor: math.min(0.35, value),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AmbientOrb extends StatelessWidget {
  const _AmbientOrb({
    required this.size,
    required this.color,
    required this.introAnimation,
    required this.ambientAnimation,
    required this.driftX,
    required this.driftY,
  });

  final double size;
  final Color color;
  final Animation<double> introAnimation;
  final Animation<double> ambientAnimation;
  final double driftX;
  final double driftY;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([introAnimation, ambientAnimation]),
      builder: (context, child) {
        final introScale = 0.92 + (introAnimation.value * 0.08);
        final phase = ambientAnimation.value * 2 * math.pi;
        final driftOffset = Offset(
          math.sin(phase) * driftX,
          math.cos(phase) * driftY,
        );
        return Transform.translate(
          offset: driftOffset,
          child: Transform.scale(scale: introScale, child: child),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
