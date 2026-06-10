import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class InitialAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool showStatus;
  final bool isOnline;

  static const List<Color> _palette = [
    Color(0xFF1B8B3C), Color(0xFF4CAF50), Color(0xFF66BB6A),
    Color(0xFF2196F3), Color(0xFF42A5F5), Color(0xFFFF6B35),
    Color(0xFFAB47BC), Color(0xFFE91E63), Color(0xFF00BCD4),
    Color(0xFFFFA726),
  ];

  const InitialAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.showStatus = false,
    this.isOnline = false,
  });

  Color _resolveColor() {
    final hash = name.codeUnits.fold(0, (prev, e) => prev + e);
    return _palette[hash % _palette.length];
  }

  String _getInitials() {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = _resolveColor();
    final initials = _getInitials();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: isDark
              ? bgColor.withValues(alpha: 0.3)
              : bgColor.withValues(alpha: 0.15),
          child: Text(
            initials,
            style: TextStyle(
              fontSize: radius * 0.6,
              fontWeight: FontWeight.w700,
              color: isDark ? bgColor : bgColor,
            ),
          ),
        ),
        if (showStatus)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
