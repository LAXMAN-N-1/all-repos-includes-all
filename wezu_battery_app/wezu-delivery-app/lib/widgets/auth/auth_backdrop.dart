import 'dart:ui';

import 'package:flutter/material.dart';

class AuthBackdrop extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AuthBackdrop({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _GradientLayer()),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final wave = Curves.easeInOut.transform(animation.value);
                final drift = (wave - 0.5) * 60;
                return Stack(
                  children: [
                    _Orb(
                      top: -130 + drift,
                      left: -90,
                      size: 320,
                      color: const Color(0x5542D7B6),
                    ),
                    _Orb(
                      top: 120,
                      right: -120 - drift,
                      size: 280,
                      color: const Color(0x445FA7FF),
                    ),
                    _Orb(
                      bottom: -120 + (drift * 0.7),
                      left: -80,
                      size: 260,
                      color: const Color(0x444EBAAA),
                    ),
                    _Orb(
                      bottom: -110 - (drift * 0.45),
                      right: -70,
                      size: 240,
                      color: const Color(0x335472D3),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.8, sigmaY: 1.8),
              child: Container(color: Colors.black.withValues(alpha: 0.08)),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GradientLayer extends StatelessWidget {
  const _GradientLayer();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF041833), Color(0xFF0A2A4A), Color(0xFF0E7A5F)],
          stops: [0, 0.68, 1],
        ),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final double size;
  final Color color;

  const _Orb({
    this.top,
    this.right,
    this.bottom,
    this.left,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}
