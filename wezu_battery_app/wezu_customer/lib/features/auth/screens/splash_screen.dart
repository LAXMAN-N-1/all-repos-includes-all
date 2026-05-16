import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/routing/app_router.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _particleController;
  late final AnimationController _textController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _pulse;

  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    if (mounted) _textController.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() async {
    if (_navigationScheduled) return;
    _navigationScheduled = true;

    // Minimum display time so the splash doesn't flash away instantly
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // Wait briefly for auth initialization so we don't route to login
    // before secure-storage restoration completes.
    for (int i = 0; i < 40 && mounted; i++) {
      final state = ref.read(authProvider);
      if (state.isInitialized) break;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated &&
        authState.token != null &&
        authState.token != 'guest_token') {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1628),
              Color(0xFF0D1F3C),
              Color(0xFF0F2A52),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _particleController,
              builder: (context, _) => CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: MediaQuery.of(context).size,
              ),
            ),

            // Glowing accent circles
            _buildAccentCircle(
              alignment: const Alignment(-1.2, -1.4),
              size: 400,
              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            ),
            _buildAccentCircle(
              alignment: const Alignment(1.3, 1.5),
              size: 350,
              color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo container
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, child) => Transform.scale(
                          scale: _pulse.value,
                          child: child,
                        ),
                        child: _buildLogo(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Text
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          Text(
                            'WEZU',
                            style: GoogleFonts.outfit(
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Battery Swap, Simplified',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.55),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Loading indicator
                  FadeTransition(
                    opacity: _textOpacity,
                    child: _buildLoadingBar(),
                  ),
                ],
              ),
            ),

            // Bottom badge
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textOpacity,
                child: Text(
                  'Powered by WEZU Technologies',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            blurRadius: 40,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.bolt_rounded,
        size: 58,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLoadingBar() {
    return SizedBox(
      width: 160,
      child: AnimatedBuilder(
        animation: _particleController,
        builder: (context, _) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: null, // indeterminate
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF3B82F6).withValues(alpha: 0.8),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccentCircle({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

// ─── Particle Painter ────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  final double progress;
  static const int _count = 30;

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _count; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final radius = 1.0 + rng.nextDouble() * 2.5;
      final alpha = 0.05 + rng.nextDouble() * 0.15;

      final t = (progress * speed + i * 0.1) % 1.0;
      final y = (baseY - t * size.height * 0.4 + size.height) % size.height;
      final opacity = (math.sin(t * math.pi)).clamp(0.0, 1.0) * alpha;

      paint.color = const Color(0xFF3B82F6).withValues(alpha: opacity);
      canvas.drawCircle(Offset(baseX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
