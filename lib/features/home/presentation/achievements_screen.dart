import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_challenges.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/animated_progress.dart';
import '../../../shared/components/empty_state.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final achievements = MockChallenges.achievements;

    final completed = achievements.where((a) => a['is_completed'] as bool).toList();
    final inProgress = achievements.where((a) => !(a['is_completed'] as bool)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencapaian'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark, achievements),
            SizedBox(height: 24.h),
            if (completed.isNotEmpty) ...[
              SectionHeader(title: 'Terkunci (${completed.length})'),
              SizedBox(height: 12.h),
              ...completed.asMap().entries.map((e) => _buildAchievementCard(context, isDark, e.value, index: e.key)),
              SizedBox(height: 24.h),
            ],
            if (inProgress.isNotEmpty) ...[
              SectionHeader(title: 'Dalam Progres (${inProgress.length})'),
              SizedBox(height: 12.h),
              ...inProgress.asMap().entries.map((e) => _buildAchievementCard(context, isDark, e.value, index: e.key)),
            ],
            if (achievements.isEmpty)
              const EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'Belum Ada Pencapaian',
                message: 'Lakukan penjemputan sampah untuk membuka pencapaian',
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, List<Map<String, dynamic>> achievements) {
    final completedCount = achievements.where((a) => a['is_completed'] as bool).length;
    final totalCount = achievements.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold, AppColors.warning],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pencapaian', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text('$completedCount / $totalCount', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 8.h),
                AnimatedProgressBar(value: progress.clamp(0.0, 1.0), height: 8, color: AppColors.gold),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.gold)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildAchievementCard(BuildContext context, bool isDark, Map<String, dynamic> ach, {int index = 0}) {
    final isCompleted = ach['is_completed'] as bool;
    final progress = (ach['progress'] as int) / (ach['target'] as int);
    final color = Color(ach['icon_color'] as int);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: isCompleted
                    ? Border.all(color: AppColors.gold.withValues(alpha: 0.3), width: 2)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isCompleted ? 1.0 : 0.4,
                    child: Icon(
                      ach['icon'] as IconData,
                      color: isCompleted ? AppColors.gold : color,
                      size: 28,
                    ),
                  ),
                  if (isCompleted)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? AppColors.cardDark : Colors.white, width: 2),
                        ),
                        child: Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ).animate(
              effects: isCompleted
                  ? [ShakeEffect(duration: 500.ms, delay: 200.ms)]
                  : [],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ach['title'] as String,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: isCompleted
                                ? AppColors.gold
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Selesai',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.success),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    ach['description'] as String,
                    style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedProgressBar(
                          value: progress.clamp(0.0, 1.0),
                          height: 6,
                          color: isCompleted ? AppColors.gold : color,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        '${ach['progress']}/${ach['target']}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? AppColors.gold : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted && ach['completed_date'] != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Dicapai: ${ach['completed_date']}',
                      style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).slideX(begin: 20, duration: 300.ms);
  }

  List<Map<String, dynamic>> get achievements => MockChallenges.achievements;
}
