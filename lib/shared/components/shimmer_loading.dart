import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : AppColors.shimmerBase,
      ).animate(onPlay: (controller) => controller.repeat()).shimmer(
        duration: 1200.ms,
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : AppColors.shimmerHighlight,
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  final int lineCount;

  const ShimmerCard({super.key, this.lineCount = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerLoading(width: 44, height: 44, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading(height: 14, borderRadius: 6),
                    const SizedBox(height: 8),
                    ShimmerLoading(height: 10, width: 100, borderRadius: 6),
                  ],
                ),
              ),
            ],
          ),
          if (lineCount > 1) ...[
            const SizedBox(height: 12),
            for (int i = 0; i < lineCount - 1; i++) ...[
              ShimmerLoading(
                height: 10,
                width: i == lineCount - 2 ? 180 : double.infinity,
                borderRadius: 6,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}
