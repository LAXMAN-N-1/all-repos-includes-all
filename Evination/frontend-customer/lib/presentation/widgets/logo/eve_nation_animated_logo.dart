import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:evination_customer_app/core/constants/app_colors.dart';

class EveNationAnimatedLogo extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const EveNationAnimatedLogo({super.key, this.onAnimationComplete});

  @override
  State<EveNationAnimatedLogo> createState() => _EveNationAnimatedLogoState();
}

class _EveNationAnimatedLogoState extends State<EveNationAnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Animation Phases
  late Animation<double> _particleOpacity;
  late Animation<double> _hexRing1Rotation;
  late Animation<double> _hexRing2Rotation;
  late Animation<double> _hexOpacity;
  
  // The "E" Construction
  late Animation<double> _barVerticalProgress;
  late Animation<double> _barTopProgress;
  late Animation<double> _barMiddleProgress;
  late Animation<double> _barBottomProgress;
  late Animation<double> _diamondOpacity;
  
  // Text Reveal
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  
  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    _initializeParticles();
    _setupAnimations();

    _controller.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  void _initializeParticles() {
    for (int i = 0; i < 50; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        speed: _random.nextDouble() * 0.5 + 0.2,
        angle: _random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  void _setupAnimations() {
    _particleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.1, curve: Curves.easeIn)),
    );

    _hexOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.2, curve: Curves.easeIn)),
    );
    _hexRing1Rotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 1.0, curve: Curves.linear)),
    );
    _hexRing2Rotation = Tween<double>(begin: 0.0, end: -2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 1.0, curve: Curves.linear)),
    );

    _barVerticalProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.4, curve: Curves.easeOut)),
    );
    _barTopProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.5, curve: Curves.easeOut)),
    );
    _barMiddleProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.45, 0.55, curve: Curves.easeOut)),
    );
    _barBottomProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.6, curve: Curves.easeOut)),
    );
    _diamondOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.7, curve: Curves.easeIn)),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 0.85, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 0.85, curve: Curves.easeOutCubic)),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 400,
          height: 600,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Particle Field
              Opacity(
                opacity: _particleOpacity.value,
                child: CustomPaint(
                  painter: _ParticlePainter(_particles, _controller.value),
                  size: const Size(400, 400),
                ),
              ),

              // 2. Rotating Hex Rings
              Opacity(
                opacity: _hexOpacity.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: _hexRing1Rotation.value,
                      child: CustomPaint(
                        painter: _HexagonPainter(color: AppColors.sunflowerYellow.withValues(alpha: 0.3), padding: 0),
                        size: const Size(200, 200),
                      ),
                    ),
                    Transform.rotate(
                      angle: _hexRing2Rotation.value,
                      child: CustomPaint(
                        painter: _HexagonPainter(color: AppColors.sunflowerYellow.withValues(alpha: 0.2), padding: 10),
                        size: const Size(200, 200),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. The "E" Logo Construction
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: _ELogoPainter(
                    verticalProgress: _barVerticalProgress.value,
                    topProgress: _barTopProgress.value,
                    middleProgress: _barMiddleProgress.value,
                    bottomProgress: _barBottomProgress.value,
                    diamondOpacity: _diamondOpacity.value,
                  ),
                ),
              ),

              // 4. Text Reveal
              Positioned(
                bottom: 80,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          'EVE NATION',
                          style: TextStyle(
                            fontFamily: 'Poppins', 
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sunflowerYellow,
                            letterSpacing: 4.0,
                            shadows: [
                              Shadow(color: AppColors.sunflowerYellow.withValues(alpha: 0.3), blurRadius: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeTransition(
                          opacity: _taglineOpacity,
                          child: Text(
                            'Every Celebration, Perfectly Planned',
                            style: TextStyle(
                              color: AppColors.greyMedium,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Particle {
  double x, y, size, speed, angle;
  _Particle({required this.x, required this.y, required this.size, required this.speed, required this.angle});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.sunflowerYellow.withValues(alpha: 0.3);
    
    for (var p in particles) {
      final dx = (p.x * size.width) + math.cos(p.angle + animationValue * 5) * 10;
      final dy = (p.y * size.height) + math.sin(p.angle + animationValue * 5) * 10;
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final double padding;

  _HexagonPainter({required this.color, required this.padding});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - padding;

    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * math.pi / 180;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ELogoPainter extends CustomPainter {
  final double verticalProgress;
  final double topProgress;
  final double middleProgress;
  final double bottomProgress;
  final double diamondOpacity;

  _ELogoPainter({
    required this.verticalProgress,
    required this.topProgress,
    required this.middleProgress,
    required this.bottomProgress,
    required this.diamondOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF5A623), Color(0xFFE8960C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final w = size.width;
    final h = size.height;
    final thickness = w * 0.15;

    if (verticalProgress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.1, thickness, h * 0.8 * verticalProgress),
        paint,
      );
    }

    if (topProgress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.1, (w * 0.6) * topProgress, thickness),
        paint,
      );
    }

    if (middleProgress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.425, (w * 0.45) * middleProgress, thickness),
        paint,
      );
    }

    if (bottomProgress > 0) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.2, h * 0.9 - thickness, (w * 0.6) * bottomProgress, thickness),
        paint,
      );
    }

    if (diamondOpacity > 0) {
      final diamondPaint = Paint()..color = const Color(0xFFF5A623).withValues(alpha: diamondOpacity);
      final path = Path();
      path.moveTo(w * 0.85, h * 0.2);
      path.lineTo(w * 0.9, h * 0.25);
      path.lineTo(w * 0.85, h * 0.3);
      path.lineTo(w * 0.8, h * 0.25);
      path.close();
      canvas.drawPath(path, diamondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
