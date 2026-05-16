import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

/// Circular health score gauge (0-100)
class StationHealthGauge extends StatelessWidget {
  final double score;
  final double size;

  const StationHealthGauge({super.key, required this.score, this.size = 140});

  Color get _color {
    if (score >= 80) return AppColors.primary;
    if (score >= 60) return AppColors.cyan;
    if (score >= 40) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: CustomPaint(
        painter: _GaugePainter(score: score, color: _color),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(score.toStringAsFixed(0), style: TextStyle(
              fontSize: size * 0.25, fontWeight: FontWeight.w800, color: _color,
            )),
            Text('Health', style: TextStyle(
              fontSize: size * 0.08, color: AppColors.textTertiary, fontWeight: FontWeight.w500,
            )),
          ]),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double score;
  final Color color;
  _GaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;
    const startAngle = 2.4; // ~135 degrees
    const sweepAngle = 4.5; // ~260 degrees arc

    // Background arc
    final bgPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false, bgPaint,
    );

    // Value arc
    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progress = (score / 100).clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * progress, false, valuePaint,
    );

    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * progress, false, glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.score != score || old.color != color;
}
