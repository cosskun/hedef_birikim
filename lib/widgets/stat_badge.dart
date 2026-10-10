import 'package:flutter/material.dart';

class StatBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final Color? textColor;
  final double fontSize;
  final EdgeInsets padding;

  const StatBadge({
    super.key,
    required this.text,
    this.icon,
    required this.color,
    this.textColor,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor ?? color,
            ),
          ),
        ],
      ),
    );
  }
}
