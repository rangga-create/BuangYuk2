import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final String type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  Color get _color {
    switch (type) {
      case 'success':
      case 'selesai':
      case 'completed':
      case 'active':
      case 'available':
      case 'open':
      case 'high':
        return AppColors.success;
      case 'warning':
      case 'in_progress':
      case 'dalam_perjalanan':
      case 'dijemput':
      case 'medium':
        return AppColors.warning;
      case 'error':
      case 'cancelled':
      case 'inactive':
      case 'critical':
        return AppColors.error;
      case 'info':
      case 'assigned':
      case 'menunggu':
      case 'pending':
      case 'low':
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: isDark ? _color : _color.withValues(alpha: 0.9),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(label, style: textStyle),
          ],
        ),
      ),
    );
  }
}
