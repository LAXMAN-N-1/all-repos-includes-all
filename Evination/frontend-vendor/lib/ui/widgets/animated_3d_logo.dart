import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class Animated3DLogo extends StatefulWidget {
  final double size;
  final bool animateStory; 
  final VoidCallback? onAnimationComplete;

  const Animated3DLogo({
    super.key, 
    this.size = 200,
    this.animateStory = true,
    this.onAnimationComplete,
  });

  @override
  State<Animated3DLogo> createState() => _Animated3DLogoState();
}

class _Animated3DLogoState extends State<Animated3DLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Act 1: Assembly (0-1s)
  late Animation<double> _assemblyScale;
  late Animation<double> _assemblyRotation;
  late Animation<double> _assemblyOpacity;

  // Act 2: The Weave (1-2.5s)
  late Animation<double> _shimmerOpacity;

  // Act 3: The Burst (2.5-3.5s)
  late Animation<double> _burstScale;
  late Animation<double> _burstOpacity;

  // Act 4: The Reveal (3.5-4s)
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 4000), // 4 Seconds Total
    );

    // --- Act 1: Assembly (Coming together) ---
    _assemblyOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.25, curve: Curves.easeOut)),
    );
    _assemblyScale = Tween<double>(begin: 1.2, end: 1.05).animate( // Start slightly larger
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );
    _assemblyRotation = Tween<double>(begin: 0.1, end: 0.0).animate( // Subtle tilt correction
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );

    // --- Act 2: The Weave (Shimmer/Pulse) ---
    // Simulates light moving across the platinum edges
    _shimmerOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeInOut)),
    );

    // --- Act 3: The Burst ( Celebration ) ---
    // Logo settles into final position
    _burstOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
       CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.7, curve: Curves.easeOut)),
    );
    _burstScale = Tween<double>(begin: 0.5, end: 2.0).animate(
       CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.9, curve: Curves.easeOutExpo)),
    );

    // --- Act 4: The Reveal --
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeIn)),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 10), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.85, 1.0, curve: Curves.easeOutCubic)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
           widget.onAnimationComplete?.call();
        });
      }
    });

    if (widget.animateStory) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5, 
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                   // Act 3: The Burst (Behind Logo)
                   Opacity(
                     opacity: _burstOpacity.value,
                     child: Transform.scale(
                       scale: _burstScale.value,
                       child: CustomPaint(
                         size: Size(widget.size * 1.5, widget.size * 1.5),
                         painter: CelebrationBurstPainter(),
                       ),
                     ),
                   ),

                   // Acts 1 & 2: The Logo itself
                   Opacity(
                    opacity: _assemblyOpacity.value,
                    child: Transform.scale(
                      scale: _assemblyScale.value,
                      child: Transform.rotate(
                        angle: _assemblyRotation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                               // Subtle Rose Gold Glow
                               BoxShadow(
                                 color: const Color(0xFFD4AF37).withOpacity(0.3 * _assemblyOpacity.value),
                                 blurRadius: 40,
                                 spreadRadius: -5,
                               ),
                            ]
                          ),
                          child: Stack(
                            alignment: Alignment.center, 
                            children: [
                               Image.asset(
                                'assets/evination_infinite_knot.png',
                                width: widget.size,
                                fit: BoxFit.contain,
                              ),
                              // Act 2: Shimmer Overlay
                              Opacity(
                                opacity: _shimmerOpacity.value,
                                child: Container(
                                  width: widget.size,
                                  height: widget.size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.0),
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: widget.size * 0.15),

              // Act 4: The Reveal (Typography)
              Opacity(
                opacity: _textOpacity.value,
                child: Transform.translate(
                  offset: _textSlide.value,
                  child: Column(
                    children: [
                      // "EVENATION" Wordmark - Custom Geometric Look
                      Text(
                        "EVENATION", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond( // Elegant Serif, but we track it out for "Geometric" feel
                          fontSize: widget.size * 0.14,
                          color: const Color(0xFFE5CCAA), // Soft Rose Gold / Ivory mix
                          letterSpacing: widget.size * 0.04, // "Abundance"
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: widget.size * 0.06),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Act 3: Custom Painter for the Light Burst
class CelebrationBurstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw radial lines
    for (int i = 0; i < 12; i++) {
       final angle = (i * 30) * math.pi / 180;
       paint.color = const Color(0xFFD4AF37).withOpacity(0.2); // Gold rays
       
       final start = center + Offset(math.cos(angle) * 40, math.sin(angle) * 40);
       final end = center + Offset(math.cos(angle) * size.width/2, math.sin(angle) * size.height/2);
       
       canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
