import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? borderColor;
  final Color? backgroundColor;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.gradient,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final defaultBorder = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (backgroundColor ?? defaultBg) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor ?? defaultBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
