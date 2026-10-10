import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0 (or > 1.0)
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? centerChild;

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 8,
    this.progressColor,
    this.backgroundColor,
    this.centerChild,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: clampedProgress,
              strokeWidth: strokeWidth,
              progressColor: progressColor ?? AppColors.primaryEmerald,
              backgroundColor: backgroundColor ?? (isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated),
            ),
          ),
          ?centerChild,
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Active progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [
            progressColor.withOpacity(0.8),
            progressColor,
          ],
          startAngle: 0.0,
          endAngle: math.pi * 2,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
