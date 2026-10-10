import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class MilestoneProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? activeColor;

  const MilestoneProgressBar({
    super.key,
    required this.progress,
    this.height = 10,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = activeColor ?? AppColors.primaryEmerald;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            // Track
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Filled bar
            FractionallySizedBox(
              widthFactor: clamped,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            // Milestone points at 25%, 50%, 75%
            ...[0.25, 0.50, 0.75].map((ms) {
              final isPassed = clamped >= ms;
              return Positioned(
                left: null,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment(ms * 2 - 1, 0),
                      child: Container(
                        width: height + 4,
                        height: height + 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPassed ? color : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          border: Border.all(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('%0', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            Text('%25', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            Text('%50 (Yarısı)', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            Text('%75', style: TextStyle(fontSize: 10, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight)),
            Text('%100 (Hedef)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }
}
