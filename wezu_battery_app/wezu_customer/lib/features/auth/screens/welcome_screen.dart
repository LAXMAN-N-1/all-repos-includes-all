import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wezu_customer_app/core/routing/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated dark gradient background ────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    -1.0 + _bgController.value * 0.4,
                    -1.0,
                  ),
                  end: Alignment(
                    1.0 - _bgController.value * 0.4,
                    1.0,
                  ),
                  colors: const [
                    Color(0xFF0A1628),
                    Color(0xFF0D1F3C),
                    Color(0xFF0C1833),
                  ],
                ),
              ),
            ),
          ),

          // ── Glow orbs ────────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, _) {
              final t = _bgController.value;
              return Stack(
                children: [
                  Positioned(
                    left: -80 + t * 40,
                    top: size.height * 0.1 - t * 30,
                    child: _GlowOrb(
                      size: 320,
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                    ),
                  ),
                  Positioned(
                    right: -60 + t * 30,
                    bottom: size.height * 0.15 + t * 40,
                    child: _GlowOrb(
                      size: 280,
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.14),
                    ),
                  ),
                  Positioned(
                    left: size.width * 0.3,
                    top: size.height * 0.5 - t * 20,
                    child: _GlowOrb(
                      size: 200,
                      color: const Color(0xFF06B6D4).withValues(alpha: 0.08),
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Grid lines (subtle tech aesthetic) ───────────────────────────
          CustomPaint(
            painter: _GridPainter(),
            size: Size(size.width, size.height),
          ),

          // ── Main content ─────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Top badge
                  _Badge(label: 'WEZU TECHNOLOGIES')
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideX(begin: -0.2, end: 0),

                  const Spacer(flex: 2),

                  // Hero icon
                  Center(
                    child: _HeroIcon()
                        .animate()
                        .scale(
                          begin: const Offset(0.4, 0.4),
                          end: const Offset(1.0, 1.0),
                          delay: 300.ms,
                          duration: 700.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(delay: 300.ms, duration: 400.ms),
                  ),

                  const SizedBox(height: 48),

                  // Main headline
                  Text(
                    'Power Your\nRide Today',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  Text(
                    'Swap EV batteries in seconds.\nAlways charged, always moving.',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.6,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 650.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 16),

                  // Feature pills
                  _FeaturePills()
                      .animate()
                      .fadeIn(delay: 750.ms, duration: 500.ms),

                  const Spacer(flex: 3),

                  // CTA buttons
                  _PremiumButton(
                    label: 'Get Started',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    isPrimary: true,
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 14),

                  _PremiumButton(
                    label: 'I already have an account',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                    isPrimary: false,
                  )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 32),

                  // Terms
                  Center(
                    child: Text(
                      'By continuing you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1100.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Subwidgets ───────────────────────────────────────────────────────────────

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF93C5FD),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
              width: 1,
            ),
          ),
        ),
        // Middle ring
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
        ),
        // Core
        Container(
          width: 100,
          height: 100,
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
            ],
          ),
          child: const Icon(
            Icons.bolt_rounded,
            size: 52,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FeaturePills extends StatelessWidget {
  const _FeaturePills();

  static const _features = [
    ('⚡', 'Instant Swap'),
    ('📍', 'Nearby Stations'),
    ('💳', 'Easy Payments'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: _features
          .map(
            (f) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    f.$2,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _PremiumButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
          color: Colors.white.withValues(alpha: 0.05),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ),
    );
  }
}

// ─── Grid Painter ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;

    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
