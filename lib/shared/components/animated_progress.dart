import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  final bool showLabel;

  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = color ?? (isDark ? AppColors.secondary : AppColors.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(value * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: barColor,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : barColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: height,
          ),
        ),
      ],
    );
  }
}

class CircularProgressWithLabel extends StatelessWidget {
  final double value;
  final Color? color;
  final double size;
  final Widget? label;

  const CircularProgressWithLabel({
    super.key,
    required this.value,
    this.color,
    this.size = 80,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = color ?? (isDark ? AppColors.secondary : AppColors.primary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : barColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          label ??
              Text(
                '${(value * 100).toInt()}%',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }
}
